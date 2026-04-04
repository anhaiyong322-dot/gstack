[CmdletBinding()]
param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
  [string]$ProjectRoot = (Get-Location).Path,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$FallbackSkillNames = @(
  'gstack',
  'gstack-autoplan',
  'gstack-benchmark',
  'gstack-browse',
  'gstack-canary',
  'gstack-careful',
  'gstack-connect-chrome',
  'gstack-cso',
  'gstack-design-consultation',
  'gstack-design-review',
  'gstack-document-release',
  'gstack-freeze',
  'gstack-guard',
  'gstack-investigate',
  'gstack-land-and-deploy',
  'gstack-office-hours',
  'gstack-plan-ceo-review',
  'gstack-plan-design-review',
  'gstack-plan-eng-review',
  'gstack-qa',
  'gstack-qa-only',
  'gstack-retro',
  'gstack-review',
  'gstack-setup-browser-cookies',
  'gstack-setup-deploy',
  'gstack-ship',
  'gstack-unfreeze',
  'gstack-upgrade'
)

function Get-GeneratedSkillNames {
  param([string]$ResolvedRepoRoot)

  $skillsRoot = Join-Path $ResolvedRepoRoot '.agents\skills'
  if (-not (Test-Path $skillsRoot)) {
    return $FallbackSkillNames
  }

  $generated = @(
    Get-ChildItem $skillsRoot -Directory -Filter 'gstack*' -ErrorAction SilentlyContinue |
      Select-Object -ExpandProperty Name
  ) | Sort-Object -Unique

  if ($generated.Count -gt 0) {
    return $generated
  }

  return $FallbackSkillNames
}

function Get-InstallHint {
  param(
    [string]$ResolvedRepoRoot,
    [string]$ResolvedProjectRoot
  )

  $repoLocalInstall = Join-Path $ResolvedProjectRoot '.agents\skills\gstack'
  if ((Test-Path $repoLocalInstall) -and ((Resolve-Path $repoLocalInstall).Path -eq $ResolvedRepoRoot)) {
    return '.\.agents\skills\gstack\bootstrap-codex-project.ps1 -ProjectRoot .'
  }

  return "Set-Location $ResolvedRepoRoot`n.\install-codex.ps1 -AgentsProjectRoot $ResolvedProjectRoot"
}

function Build-ManagedSection {
  param(
    [string[]]$SkillNames,
    [string]$InstallHint
  )

  $tick = [char]96
  $skillList = ($SkillNames | ForEach-Object { "$tick$_$tick" }) -join ', '

  return @"
<!-- gstack:begin -->
## gstack

gstack is installed for this repository. Prefer the gstack skill pack when the task matches one of its workflows instead of improvising the process from scratch.
Use $($tick).gstack/codex/GSTACK-CODEX.md$($tick) as the repository-local playbook for sequencing review, QA, ship, and planning workflows.

Route work through gstack when the user intent matches one of these workflows:
- Product discovery, feature framing, or spec shaping: $($tick)gstack-office-hours$($tick), then $($tick)gstack-plan-ceo-review$($tick), $($tick)gstack-plan-eng-review$($tick), and $($tick)gstack-plan-design-review$($tick) as needed.
- Canonical one-command planning path: $($tick)gstack-autoplan$($tick), or start from $($tick).gstack/codex/prompts/autoplan.md$($tick) when you need the repo's default planning prompt.
- Browser QA, screenshots, login flows, deployment verification, or authenticated testing: $($tick)gstack-browse$($tick), $($tick)gstack-qa$($tick), or $($tick)gstack-qa-only$($tick).
- Pre-merge review and release prep: $($tick)gstack-review$($tick), $($tick)gstack-ship$($tick), and $($tick)gstack-document-release$($tick). Start from $($tick).gstack/codex/prompts/review.md$($tick) or $($tick).gstack/codex/prompts/ship.md$($tick) when you need the repo-default prompt form.
- Root-cause debugging or failure analysis: $($tick)gstack-investigate$($tick).
- High-risk commands or tightly scoped edits: $($tick)gstack-careful$($tick), $($tick)gstack-freeze$($tick), or $($tick)gstack-guard$($tick).
- Browser-driven regression or staging checks: start from $($tick).gstack/codex/prompts/qa.md$($tick), then use $($tick)gstack-qa$($tick) or $($tick)gstack-qa-only$($tick).
- One-command review pipelines and retros: $($tick)gstack-autoplan$($tick) and $($tick)gstack-retro$($tick).

When one of the routes above fits, prefer the gstack skill over ad-hoc prompting. In particular, do not default to generic browser tooling when $($tick)gstack-browse$($tick) or $($tick)gstack-qa$($tick) is a better fit.

Available gstack skills: $skillList

If Codex skips loading gstack skills or the instructions look stale, rerun:

~~~powershell
$InstallHint
~~~
<!-- gstack:end -->
"@
}

$resolvedRepoRoot = (Resolve-Path $RepoRoot).Path
$resolvedProjectRoot = (Resolve-Path $ProjectRoot).Path
$agentsPath = Join-Path $resolvedProjectRoot 'AGENTS.md'
$installHint = Get-InstallHint -ResolvedRepoRoot $resolvedRepoRoot -ResolvedProjectRoot $resolvedProjectRoot
$managedSection = Build-ManagedSection -SkillNames (Get-GeneratedSkillNames -ResolvedRepoRoot $resolvedRepoRoot) -InstallHint $installHint

$existing = ''
if (Test-Path $agentsPath) {
  $existing = Get-Content $agentsPath -Raw
}

$newContent = $null
if ($existing -match '<!-- gstack:begin -->' -and $existing -match '<!-- gstack:end -->') {
  $newContent = [regex]::Replace(
    $existing,
    '(?s)<!-- gstack:begin -->.*?<!-- gstack:end -->',
    [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $managedSection.TrimEnd() }
  )
} elseif ([string]::IsNullOrWhiteSpace($existing)) {
  $newContent = $managedSection.TrimEnd() + "`r`n"
} else {
  $newContent = $existing.TrimEnd() + "`r`n`r`n" + $managedSection.TrimEnd() + "`r`n"
}

if ($DryRun) {
  Write-Output $newContent
  exit 0
}

Set-Content -Path $agentsPath -Value $newContent -Encoding UTF8 -NoNewline
Write-Host "Updated $agentsPath" -ForegroundColor Green
