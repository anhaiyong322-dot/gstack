[CmdletBinding()]
param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
  [string]$CodexSkillsRoot = (Join-Path $HOME '.codex\skills'),
  [switch]$RepoLocal,
  [string]$ProjectRoot
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

$projectRootResolved = $null
if ($PSBoundParameters.ContainsKey('ProjectRoot') -and $ProjectRoot) {
  $projectRootResolved = (Resolve-Path $ProjectRoot).Path
} elseif ($RepoLocal) {
  $projectRootResolved = (Resolve-Path (Join-Path $repoRoot '..\..\..')).Path
}

if ($projectRootResolved) {
  $agentsPath = Join-Path $projectRootResolved 'AGENTS.md'
  $playbookPath = Join-Path $projectRootResolved '.gstack\codex\GSTACK-CODEX.md'
  $reviewPromptPath = Join-Path $projectRootResolved '.gstack\codex\prompts\review.md'
  $qaPromptPath = Join-Path $projectRootResolved '.gstack\codex\prompts\qa.md'
  $shipPromptPath = Join-Path $projectRootResolved '.gstack\codex\prompts\ship.md'
  $autoplanPromptPath = Join-Path $projectRootResolved '.gstack\codex\prompts\autoplan.md'
  $agentsContent = if (Test-Path $agentsPath) { Get-Content $agentsPath -Raw } else { '' }
  $playbookContent = if (Test-Path $playbookPath) { Get-Content $playbookPath -Raw } else { '' }
  $hasManagedSection = $agentsContent -match '<!-- gstack:begin -->' -and $agentsContent -match '<!-- gstack:end -->'
  $hasBrowseHint = $agentsContent -match 'gstack-browse'
  $hasReviewHint = $agentsContent -match 'gstack-review'
  $hasShipHint = $agentsContent -match 'gstack-ship'
  $hasPlaybookReference = $agentsContent -match '\.gstack/codex/GSTACK-CODEX.md'
  $hasPlaybookReview = $playbookContent -match 'gstack-review'
  $hasPlaybookQa = $playbookContent -match 'gstack-qa'
  $hasPlaybookShip = $playbookContent -match 'gstack-ship'
  $hasPlaybookAutoplan = $playbookContent -match 'gstack-autoplan'

  Write-Host ''
  Write-Check -Label 'AGENTS.md' -Ok (Test-Path $agentsPath) -Detail $agentsPath
  Write-Check -Label 'gstack block' -Ok $hasManagedSection -Detail 'managed gstack section markers'
  Write-Check -Label 'browse hint' -Ok $hasBrowseHint -Detail 'contains gstack-browse guidance'
  Write-Check -Label 'review hint' -Ok $hasReviewHint -Detail 'contains gstack-review guidance'
  Write-Check -Label 'ship hint' -Ok $hasShipHint -Detail 'contains gstack-ship guidance'
  Write-Check -Label 'playbook ref' -Ok $hasPlaybookReference -Detail 'AGENTS points to .gstack/codex/GSTACK-CODEX.md'
  Write-Check -Label 'playbook' -Ok (Test-Path $playbookPath) -Detail $playbookPath
  Write-Check -Label 'review prompt' -Ok (Test-Path $reviewPromptPath) -Detail $reviewPromptPath
  Write-Check -Label 'qa prompt' -Ok (Test-Path $qaPromptPath) -Detail $qaPromptPath
  Write-Check -Label 'ship prompt' -Ok (Test-Path $shipPromptPath) -Detail $shipPromptPath
  Write-Check -Label 'autoplan prmpt' -Ok (Test-Path $autoplanPromptPath) -Detail $autoplanPromptPath
  Write-Check -Label 'playbook rvw' -Ok $hasPlaybookReview -Detail 'playbook contains gstack-review'
  Write-Check -Label 'playbook qa' -Ok $hasPlaybookQa -Detail 'playbook contains gstack-qa'
  Write-Check -Label 'playbook ship' -Ok $hasPlaybookShip -Detail 'playbook contains gstack-ship'
  Write-Check -Label 'playbook plan' -Ok $hasPlaybookAutoplan -Detail 'playbook contains gstack-autoplan'
  if (-not (Test-Path $agentsPath)) {
    $issues++
  }
  if (-not $hasManagedSection) {
    $issues++
  }
  if (-not $hasBrowseHint) {
    $issues++
  }
  if (-not $hasReviewHint) {
    $issues++
  }
  if (-not $hasShipHint) {
    $issues++
  }
  if (-not $hasPlaybookReference) {
    $issues++
  }
  if (-not (Test-Path $playbookPath)) {
    $issues++
  }
  if (-not (Test-Path $reviewPromptPath)) {
    $issues++
  }
  if (-not (Test-Path $qaPromptPath)) {
    $issues++
  }
  if (-not (Test-Path $shipPromptPath)) {
    $issues++
  }
  if (-not (Test-Path $autoplanPromptPath)) {
    $issues++
  }
  if (-not $hasPlaybookReview) {
    $issues++
  }
  if (-not $hasPlaybookQa) {
    $issues++
  }
  if (-not $hasPlaybookShip) {
    $issues++
  }
  if (-not $hasPlaybookAutoplan) {
    $issues++
  }
}

if ($issues -gt 0) {
  Write-Host ''
  Write-Host "Doctor found $issues blocking issue(s)." -ForegroundColor Yellow
  exit 1
}

Write-Host ''
Write-Host 'Doctor looks clean.' -ForegroundColor Green
