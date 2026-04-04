[CmdletBinding()]
param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
  [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$resolvedRepoRoot = (Resolve-Path $RepoRoot).Path
$resolvedProjectRoot = (Resolve-Path $ProjectRoot).Path
$templateRoot = Join-Path $resolvedRepoRoot 'templates\codex-project'
$targetRoot = Join-Path $resolvedProjectRoot '.gstack\codex'

if (-not (Test-Path $templateRoot)) {
  throw "Codex project template directory not found: $templateRoot"
}

$relativeFiles = @(
  'GSTACK-CODEX.md',
  'prompts\review.md',
  'prompts\qa.md',
  'prompts\ship.md',
  'prompts\autoplan.md'
)

foreach ($relativePath in $relativeFiles) {
  $sourcePath = Join-Path $templateRoot $relativePath
  $targetPath = Join-Path $targetRoot $relativePath

  if (-not (Test-Path $sourcePath)) {
    throw "Template file not found: $sourcePath"
  }

  $targetDir = Split-Path -Parent $targetPath
  if ($targetDir) {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
  }

  Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
}

Write-Host "Scaffolded Codex project files under $targetRoot" -ForegroundColor Green
