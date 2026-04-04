[CmdletBinding()]
param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
  [string]$WorktreeRoot,
  [switch]$ForceCreate
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Read-JsonFile {
  param([string]$Path)
  return (Get-Content -Raw -Path $Path | ConvertFrom-Json)
}

$resolvedRepoRoot = (Resolve-Path $RepoRoot).Path
$upstreamPath = Join-Path $resolvedRepoRoot 'overlay\upstream.json'
$applyScript = Join-Path $resolvedRepoRoot 'scripts\apply-codex-overlay.ps1'

if (-not (Test-Path $upstreamPath)) {
  throw "overlay upstream metadata not found: $upstreamPath"
}

if (-not (Test-Path $applyScript)) {
  throw "overlay apply script not found: $applyScript"
}

$upstream = Read-JsonFile $upstreamPath

if (-not $WorktreeRoot) {
  $WorktreeRoot = Join-Path $resolvedRepoRoot '.gstack-worktrees'
}

$resolvedWorktreeRoot = [IO.Path]::GetFullPath($WorktreeRoot)
if (-not (Test-Path $resolvedWorktreeRoot)) {
  New-Item -ItemType Directory -Path $resolvedWorktreeRoot -Force | Out-Null
}

Write-Host "Fetching upstream"
& git -C $resolvedRepoRoot fetch $upstream.repo $upstream.branch
if ($LASTEXITCODE -ne 0) {
  throw 'git fetch failed'
}

$latestSha = (& git -C $resolvedRepoRoot rev-parse FETCH_HEAD).Trim()
if (-not $latestSha) {
  throw 'unable to resolve FETCH_HEAD after git fetch'
}

if ($latestSha.Equals([string]$upstream.lastReviewedSha, [System.StringComparison]::OrdinalIgnoreCase) -and -not $ForceCreate) {
  Write-Host "Overlay already targets the latest reviewed upstream commit."
  Write-Host "Use -ForceCreate if you still want a fresh trial worktree."
  return
}

$trialName = "upstream-$($latestSha.Substring(0, 12))"
$trialRoot = Join-Path $resolvedWorktreeRoot $trialName

if (Test-Path $trialRoot) {
  throw "trial worktree already exists: $trialRoot"
}

Write-Host "Creating trial worktree: $trialRoot"
& git -C $resolvedRepoRoot worktree add --detach $trialRoot $latestSha
if ($LASTEXITCODE -ne 0) {
  throw 'git worktree add failed'
}

& $applyScript -RepoRoot $trialRoot -SourceRoot $resolvedRepoRoot
if ($LASTEXITCODE -ne 0) {
  throw 'apply-codex-overlay.ps1 failed'
}

Write-Host ''
Write-Host 'Trial worktree ready.'
Write-Host "  upstream sha : $latestSha"
Write-Host "  path         : $trialRoot"
Write-Host ''
Write-Host 'Suggested next steps:'
Write-Host "  1. cd $trialRoot"
Write-Host '  2. run build or doctor checks'
Write-Host '  3. fix conflicts or regressions if needed'
Write-Host '  4. run scripts/export-codex-overlay.ps1 -UpdateReviewedSha after the overlay is stable'
