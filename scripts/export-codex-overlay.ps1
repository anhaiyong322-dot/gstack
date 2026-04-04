[CmdletBinding()]
param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
  [string]$UpstreamRef,
  [switch]$FetchUpstream,
  [switch]$UpdateReviewedSha
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Read-JsonFile {
  param([string]$Path)
  return (Get-Content -Raw -Path $Path | ConvertFrom-Json)
}

function Write-Utf8NoBom {
  param(
    [string]$Path,
    [string]$Content
  )

  $encoding = [System.Text.UTF8Encoding]::new($false)
  [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Ensure-ParentDirectory {
  param([string]$Path)
  $parent = Split-Path -Parent $Path
  if ($parent -and -not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
}

$resolvedRepoRoot = (Resolve-Path $RepoRoot).Path
$manifestPath = Join-Path $resolvedRepoRoot 'overlay\manifest.json'
$upstreamPath = Join-Path $resolvedRepoRoot 'overlay\upstream.json'

if (-not (Test-Path $manifestPath)) {
  throw "overlay manifest not found: $manifestPath"
}

$manifest = Read-JsonFile $manifestPath
$upstream = Read-JsonFile $upstreamPath

if ($FetchUpstream) {
  Write-Host "Fetching upstream baseline"
  & git -C $resolvedRepoRoot fetch $upstream.repo $upstream.branch
  if ($LASTEXITCODE -ne 0) {
    throw 'git fetch failed'
  }
  $UpstreamRef = 'FETCH_HEAD'
}

if (-not $UpstreamRef) {
  $UpstreamRef = [string]$upstream.lastReviewedSha
}

$resolvedUpstreamSha = (& git -C $resolvedRepoRoot rev-parse $UpstreamRef).Trim()
if ($LASTEXITCODE -ne 0 -or -not $resolvedUpstreamSha) {
  throw "unable to resolve upstream ref: $UpstreamRef"
}

Write-Host "Exporting overlay files"
Write-Host "  repo root    : $resolvedRepoRoot"
Write-Host "  upstream ref : $UpstreamRef ($resolvedUpstreamSha)"

foreach ($ownedFile in @($manifest.ownedFiles)) {
  $sourcePath = Join-Path $resolvedRepoRoot $ownedFile.target
  $snapshotPath = Join-Path $resolvedRepoRoot $ownedFile.source

  if (-not (Test-Path $sourcePath)) {
    throw "overlay-owned file missing from repo root: $sourcePath"
  }

  Ensure-ParentDirectory $snapshotPath
  Copy-Item -LiteralPath $sourcePath -Destination $snapshotPath -Force
  Write-Host "  [file] $($ownedFile.target)"
}

foreach ($patch in @($manifest.patches)) {
  $patchPath = Join-Path $resolvedRepoRoot $patch.path
  Ensure-ParentDirectory $patchPath

  $diffLines = & git -C $resolvedRepoRoot diff --binary $resolvedUpstreamSha -- $patch.target
  if ($LASTEXITCODE -ne 0) {
    throw "failed to generate patch for $($patch.target)"
  }

  $content = if ($diffLines) { (($diffLines -join "`n") + "`n") } else { '' }
  Write-Utf8NoBom -Path $patchPath -Content $content
  Write-Host "  [patch] $($patch.target)"
}

if ($UpdateReviewedSha) {
  $updated = [ordered]@{
    repo = $upstream.repo
    branch = $upstream.branch
    lastReviewedSha = $resolvedUpstreamSha
    lastReviewedDate = (Get-Date -Format 'yyyy-MM-dd')
    notes = $upstream.notes
  } | ConvertTo-Json -Depth 4

  Write-Utf8NoBom -Path $upstreamPath -Content ($updated + "`n")
  Write-Host "Updated overlay/upstream.json"
}
