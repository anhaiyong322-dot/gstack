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
    return '.\.agents\skills\gstack\install-codex.ps1 -RepoLocal -ProjectRoot .'
  }

  return "Set-Location $ResolvedRepoRoot`n.\install-codex.ps1"
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

Use $($tick)gstack-browse$($tick) for browser automation, screenshots, login flows, and QA against real sites. Use $($tick)gstack-review$($tick) before landing risky changes, $($tick)gstack-qa$($tick) after UI or workflow changes, $($tick)gstack-ship$($tick) when preparing a branch to land, $($tick)gstack-office-hours$($tick) for product discovery, and $($tick)gstack-plan-ceo-review$($tick), $($tick)gstack-plan-eng-review$($tick), $($tick)gstack-plan-design-review$($tick) when the work needs product, architecture, or design review. Use $($tick)gstack-careful$($tick), $($tick)gstack-freeze$($tick), or $($tick)gstack-guard$($tick) before risky operations.

Available gstack skills: $skillList

If Codex skips loading gstack skills or the instructions look stale, rerun:

```powershell
$InstallHint
```
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
