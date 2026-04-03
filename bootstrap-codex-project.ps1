[CmdletBinding()]
param(
  [string]$ProjectRoot = (Get-Location).Path,
  [string]$RepoUrl = 'https://github.com/anhaiyong322-dot/gstack.git',
  [switch]$SkipDoctor,
  [switch]$SkipAgentsMd
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-RepoRootFromScript {
  $scriptRoot = Split-Path -Parent $PSCommandPath
  $setupPath = Join-Path $scriptRoot 'setup'
  if ((Test-Path $setupPath) -and (Test-Path (Join-Path $scriptRoot '.git'))) {
    return (Resolve-Path $scriptRoot).Path
  }
  return $null
}

function Resolve-InstallerRepo {
  $repoRoot = Get-RepoRootFromScript
  if (-not $repoRoot) {
    throw 'bootstrap-codex-project.ps1 must be run from a gstack checkout.'
  }
  return $repoRoot
}

$resolvedProjectRoot = (Resolve-Path $ProjectRoot).Path
$repoRoot = Resolve-InstallerRepo
$installScript = Join-Path $repoRoot 'install-codex.ps1'

if (-not (Test-Path $installScript)) {
  throw "install-codex.ps1 not found under $repoRoot"
}

$params = @{
  RepoUrl = $RepoUrl
  RepoLocal = $true
  ProjectRoot = $resolvedProjectRoot
}

if ($SkipDoctor) {
  $params.SkipDoctor = $true
}
if ($SkipAgentsMd) {
  $params.SkipAgentsMd = $true
}

& $installScript @params
if ($LASTEXITCODE -ne 0) {
  throw "install-codex.ps1 failed with exit code $LASTEXITCODE"
}
