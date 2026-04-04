[CmdletBinding()]
param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
  [switch]$Json,
  [switch]$AllowBehind
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Read-JsonFile {
  param([string]$Path)
  return (Get-Content -Raw -Path $Path | ConvertFrom-Json)
}

$resolvedRepoRoot = (Resolve-Path $RepoRoot).Path
$upstreamPath = Join-Path $resolvedRepoRoot 'overlay\upstream.json'

if (-not (Test-Path $upstreamPath)) {
  throw "overlay upstream metadata not found: $upstreamPath"
}

$upstream = Read-JsonFile $upstreamPath
$refName = "refs/heads/$($upstream.branch)"
$remoteLines = & git ls-remote $upstream.repo $refName

if ($LASTEXITCODE -ne 0 -or -not $remoteLines) {
  throw "failed to resolve upstream ref: $($upstream.repo) $refName"
}

$latestSha = (($remoteLines | Select-Object -First 1) -split '\s+')[0]
$reviewedSha = [string]$upstream.lastReviewedSha
$behind = -not $latestSha.Equals($reviewedSha, [System.StringComparison]::OrdinalIgnoreCase)
$state = if ($behind) { 'behind' } else { 'current' }

$result = [ordered]@{
  state = $state
  repo = $upstream.repo
  branch = $upstream.branch
  reviewedSha = $reviewedSha
  latestSha = $latestSha
  reviewedDate = $upstream.lastReviewedDate
  behind = $behind
}

if ($Json) {
  $result | ConvertTo-Json -Depth 4
} else {
  Write-Host "Overlay upstream check"
  Write-Host "  repo         : $($result.repo)"
  Write-Host "  branch       : $($result.branch)"
  Write-Host "  reviewed sha : $($result.reviewedSha)"
  Write-Host "  latest sha   : $($result.latestSha)"
  Write-Host "  state        : $($result.state)"
}

if ($behind -and -not $AllowBehind) {
  exit 2
}

exit 0
