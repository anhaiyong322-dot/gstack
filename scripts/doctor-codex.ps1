[CmdletBinding()]
param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
  [string]$CodexSkillsRoot = (Join-Path $HOME '.codex\skills'),
  [switch]$RepoLocal
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-ToolPath {
  param([string]$Name)
  try {
    return (Get-Command $Name -ErrorAction Stop).Source
  } catch {
    return $null
  }
}

function Find-GitBash {
  $fromPath = Get-ToolPath 'bash'
  if ($fromPath) {
    return $fromPath
  }

  $candidates = @(
    (Join-Path $env:ProgramFiles 'Git\bin\bash.exe'),
    (Join-Path $env:ProgramFiles 'Git\usr\bin\bash.exe'),
    (Join-Path $env:LocalAppData 'Programs\Git\bin\bash.exe'),
    (Join-Path $env:LocalAppData 'Programs\Git\usr\bin\bash.exe')
  )

  if (${env:ProgramFiles(x86)}) {
    $candidates += @(
      (Join-Path ${env:ProgramFiles(x86)} 'Git\bin\bash.exe'),
      (Join-Path ${env:ProgramFiles(x86)} 'Git\usr\bin\bash.exe')
    )
  }

  foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path $candidate)) {
      return $candidate
    }
  }

  return $null
}

function Write-Check {
  param(
    [string]$Label,
    [bool]$Ok,
    [string]$Detail
  )

  $prefix = if ($Ok) { '[ok] ' } else { '[!!] ' }
  $color = if ($Ok) { 'Green' } else { 'Yellow' }
  Write-Host ($prefix + $Label.PadRight(16) + ' ' + $Detail) -ForegroundColor $color
}

$repoRoot = (Resolve-Path $RepoRoot).Path
$issues = 0

Write-Host "Codex gstack doctor"
Write-Host "Repo root: $repoRoot"
Write-Host ''

$toolChecks = @(
  @{ Label = 'git';   Value = (Get-ToolPath 'git') },
  @{ Label = 'bash';  Value = (Find-GitBash) },
  @{ Label = 'bun';   Value = (Get-ToolPath 'bun') },
  @{ Label = 'node';  Value = (Get-ToolPath 'node') },
  @{ Label = 'codex'; Value = (Get-ToolPath 'codex') }
)

foreach ($check in $toolChecks) {
  $ok = [bool]$check.Value
  Write-Check -Label $check.Label -Ok $ok -Detail ($(if ($ok) { $check.Value } else { 'missing' }))
  if (-not $ok -and $check.Label -ne 'codex') {
    $issues++
  }
}

$setupPath = Join-Path $repoRoot 'setup'
$doctorRepoMarkers = @(
  @{ Label = 'setup'; Value = $setupPath },
  @{ Label = 'browse'; Value = (Join-Path $repoRoot 'browse\dist\browse') },
  @{ Label = 'gen-docs'; Value = (Join-Path $repoRoot 'scripts\gen-skill-docs.ts') }
)

Write-Host ''
foreach ($marker in $doctorRepoMarkers) {
  $ok = Test-Path $marker.Value
  Write-Check -Label $marker.Label -Ok $ok -Detail $marker.Value
  if (-not $ok) {
    $issues++
  }
}

$generatedSkillsRoot = Join-Path $repoRoot '.agents\skills'
$generatedSkillDirs = @()
if (Test-Path $generatedSkillsRoot) {
  $generatedSkillDirs = @(Get-ChildItem $generatedSkillsRoot -Directory -Filter 'gstack*' -ErrorAction SilentlyContinue)
}
$generatedCount = $generatedSkillDirs.Count
$generatedRootSkill = Test-Path (Join-Path $generatedSkillsRoot 'gstack\SKILL.md')

Write-Host ''
Write-Check -Label 'generated' -Ok ($generatedCount -gt 0) -Detail ("{0} skill directories under {1}" -f $generatedCount, $generatedSkillsRoot)
if ($generatedCount -le 0) {
  $issues++
}
Write-Check -Label 'root skill' -Ok $generatedRootSkill -Detail (Join-Path $generatedSkillsRoot 'gstack\SKILL.md')
if (-not $generatedRootSkill) {
  $issues++
}

$installRoot = if ($RepoLocal) {
  (Resolve-Path (Join-Path $repoRoot '..')).Path
} else {
  $CodexSkillsRoot
}
$installedSkillDirs = @()
if (Test-Path $installRoot) {
  $installedSkillDirs = @(Get-ChildItem $installRoot -Directory -Filter 'gstack*' -ErrorAction SilentlyContinue)
}
$installedRootSkill = Test-Path (Join-Path $installRoot 'gstack\SKILL.md')

Write-Host ''
Write-Check -Label 'install root' -Ok (Test-Path $installRoot) -Detail $installRoot
Write-Check -Label 'installed' -Ok ($installedSkillDirs.Count -gt 0) -Detail ("{0} skill directories under {1}" -f $installedSkillDirs.Count, $installRoot)
Write-Check -Label 'root skill' -Ok $installedRootSkill -Detail (Join-Path $installRoot 'gstack\SKILL.md')
if (-not (Test-Path $installRoot)) {
  $issues++
}
if ($installedSkillDirs.Count -le 0) {
  $issues++
}
if (-not $installedRootSkill) {
  $issues++
}

if ($issues -gt 0) {
  Write-Host ''
  Write-Host "Doctor found $issues blocking issue(s)." -ForegroundColor Yellow
  exit 1
}

Write-Host ''
Write-Host 'Doctor looks clean.' -ForegroundColor Green
