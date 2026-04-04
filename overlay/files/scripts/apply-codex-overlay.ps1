[CmdletBinding()]
param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
  [string]$SourceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
  [switch]$SkipOwnedFiles,
  [switch]$SkipPatches,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Read-JsonFile {
  param([string]$Path)
  return (Get-Content -Raw -Path $Path | ConvertFrom-Json)
}

function Ensure-ParentDirectory {
  param([string]$Path)
  $parent = Split-Path -Parent $Path
  if ($parent -and -not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
}

function Copy-OverlayItem {
  param(
    [string]$SourcePath,
    [string]$TargetPath
  )

  $resolvedSource = [IO.Path]::GetFullPath($SourcePath)
  $resolvedTarget = [IO.Path]::GetFullPath($TargetPath)

  if ($resolvedSource.Equals($resolvedTarget, [System.StringComparison]::OrdinalIgnoreCase)) {
    return
  }

  Ensure-ParentDirectory $resolvedTarget
  Copy-Item -LiteralPath $resolvedSource -Destination $resolvedTarget -Force -Recurse
}

function Test-PatchAlreadyApplied {
  param(
    [string]$GitRepoRoot,
    [string]$PatchPath
  )

  & git -C $GitRepoRoot apply --reverse --check --whitespace=nowarn $PatchPath 2>$null
  return ($LASTEXITCODE -eq 0)
}

$resolvedRepoRoot = (Resolve-Path $RepoRoot).Path
$resolvedSourceRoot = (Resolve-Path $SourceRoot).Path
$manifestPath = Join-Path $resolvedSourceRoot 'overlay\manifest.json'

if (-not (Test-Path $manifestPath)) {
  throw "overlay manifest not found: $manifestPath"
}

if (-not (Test-Path (Join-Path $resolvedRepoRoot '.git'))) {
  throw "target repo root does not look like a git checkout: $resolvedRepoRoot"
}

$manifest = Read-JsonFile $manifestPath

Write-Host "Applying Codex overlay"
Write-Host "  source: $resolvedSourceRoot"
Write-Host "  target: $resolvedRepoRoot"

foreach ($ownedDirectory in @($manifest.ownedDirectories)) {
  $sourceDirectory = Join-Path $resolvedSourceRoot $ownedDirectory.source
  $targetDirectory = Join-Path $resolvedRepoRoot $ownedDirectory.target

  if ($DryRun) {
    Write-Host "  [dir]  $($ownedDirectory.target)"
    continue
  }

  Copy-OverlayItem -SourcePath $sourceDirectory -TargetPath $targetDirectory
}

if (-not $SkipOwnedFiles) {
  foreach ($ownedFile in @($manifest.ownedFiles)) {
    $sourcePath = Join-Path $resolvedSourceRoot $ownedFile.source
    $targetPath = Join-Path $resolvedRepoRoot $ownedFile.target

    if ($DryRun) {
      Write-Host "  [file] $($ownedFile.target)"
      continue
    }

    Copy-OverlayItem -SourcePath $sourcePath -TargetPath $targetPath
  }
}

if (-not $SkipPatches) {
  foreach ($patch in @($manifest.patches)) {
    $patchPath = Join-Path $resolvedRepoRoot $patch.path

    if (-not (Test-Path $patchPath)) {
      throw "patch file not found after overlay copy: $patchPath"
    }

    if (Test-PatchAlreadyApplied -GitRepoRoot $resolvedRepoRoot -PatchPath $patchPath) {
      Write-Host "  [skip] patch already applied: $($patch.target)"
      continue
    }

    if ($DryRun) {
      Write-Host "  [patch] $($patch.target)"
      continue
    }

    & git -C $resolvedRepoRoot apply --3way --whitespace=nowarn $patchPath
    if ($LASTEXITCODE -ne 0) {
      throw "failed to apply patch for $($patch.target): $patchPath"
    }

    Write-Host "  [patch] applied: $($patch.target)"
  }
}
