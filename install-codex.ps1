[CmdletBinding()]
param(
  [string]$RepoUrl = 'https://github.com/anhaiyong322-dot/gstack.git',
  [string]$InstallDir = (Join-Path $HOME 'gstack'),
  [switch]$RepoLocal,
  [string]$ProjectRoot = (Get-Location).Path,
  [string]$AgentsProjectRoot,
  [switch]$SkipSetup,
  [switch]$SkipDoctor,
  [switch]$SkipAgentsMd,
  [switch]$SkipProjectScaffold
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Write-Step {
  param([string]$Message)
  Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Info {
  param([string]$Message)
  Write-Host "  $Message"
}

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

function Convert-ToBashPath {
  param([string]$Path)
  return ($Path -replace '\\', '/')
}

function Get-RepoRootFromScript {
  $scriptRoot = Split-Path -Parent $PSCommandPath
  $setupPath = Join-Path $scriptRoot 'setup'
  if ((Test-Path $setupPath) -and (Test-Path (Join-Path $scriptRoot '.git'))) {
    return (Resolve-Path $scriptRoot).Path
  }
  return $null
}

function Update-Or-CloneRepo {
  param(
    [string]$RepoDir,
    [string]$RemoteUrl
  )

  $gitPath = Get-ToolPath 'git'
  if (-not $gitPath) {
    throw 'git is required to clone or update the gstack checkout. Install Git for Windows first.'
  }

  if (Test-Path $RepoDir) {
    if (-not (Test-Path (Join-Path $RepoDir '.git'))) {
      throw "Install directory already exists but is not a git checkout: $RepoDir"
    }

    $origin = (& git -C $RepoDir remote get-url origin 2>$null | Out-String).Trim()
    if ($origin -and $origin -ne $RemoteUrl) {
      throw "Existing checkout origin is '$origin', expected '$RemoteUrl'. Pick a different -InstallDir or fix the checkout."
    }

    $dirty = (& git -C $RepoDir status --porcelain | Out-String).Trim()
    if ($dirty) {
      throw "Existing checkout has local changes: $RepoDir. Commit or stash them before re-running the installer."
    }

    Write-Step 'Updating existing checkout'
    & git -C $RepoDir pull --ff-only
    if ($LASTEXITCODE -ne 0) {
      throw "git pull failed for $RepoDir"
    }
    return
  }

  Write-Step 'Cloning repository'
  $parent = Split-Path -Parent $RepoDir
  if ($parent) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }

  & git clone --single-branch --depth 1 $RemoteUrl $RepoDir
  if ($LASTEXITCODE -ne 0) {
    throw "git clone failed for $RemoteUrl"
  }
}

function Invoke-Setup {
  param(
    [string]$BashExe,
    [string]$RepoDir
  )

  $bashRepoDir = Convert-ToBashPath ((Resolve-Path $RepoDir).Path)
  $bashCommand = "cd `"$bashRepoDir`" && ./setup --host codex"

  Write-Step 'Running ./setup --host codex'
  & $BashExe -lc $bashCommand
  if ($LASTEXITCODE -ne 0) {
    throw "setup failed with exit code $LASTEXITCODE"
  }
}

$bashExe = Find-GitBash
$bunExe = Get-ToolPath 'bun'
$nodeExe = Get-ToolPath 'node'
$codexExe = Get-ToolPath 'codex'

Write-Step 'Checking prerequisites'
Write-Info ("bash : {0}" -f ($(if ($bashExe) { $bashExe } else { 'missing' })))
Write-Info ("bun  : {0}" -f ($(if ($bunExe) { $bunExe } else { 'missing' })))
Write-Info ("node : {0}" -f ($(if ($nodeExe) { $nodeExe } else { 'missing' })))
Write-Info ("codex: {0}" -f ($(if ($codexExe) { $codexExe } else { 'missing (installer can continue)' })))

if (-not $bashExe) {
  throw 'bash is required. Install Git for Windows or WSL, then re-run install-codex.ps1.'
}
if (-not $bunExe) {
  throw 'bun is required. Install Bun v1.x, then re-run install-codex.ps1.'
}
if (-not $nodeExe) {
  throw 'node is required on Windows because Playwright falls back to Node.js. Install Node.js, then re-run install-codex.ps1.'
}

$sourceRepoRoot = Get-RepoRootFromScript
$repoDir = $null

if ($RepoLocal) {
  $resolvedProjectRoot = (Resolve-Path $ProjectRoot).Path
  $repoDir = Join-Path $resolvedProjectRoot '.agents\skills\gstack'
  Update-Or-CloneRepo -RepoDir $repoDir -RemoteUrl $RepoUrl
} elseif ($sourceRepoRoot) {
  $repoDir = $sourceRepoRoot
  Write-Step 'Using current checkout as the install source'
  Write-Info $repoDir
} else {
  $repoDir = $InstallDir
  Update-Or-CloneRepo -RepoDir $repoDir -RemoteUrl $RepoUrl
}

if (-not $SkipSetup) {
  Invoke-Setup -BashExe $bashExe -RepoDir $repoDir
}

$managedAgentsRoot = $null
if ($RepoLocal) {
  $managedAgentsRoot = (Resolve-Path $ProjectRoot).Path
} elseif ($PSBoundParameters.ContainsKey('AgentsProjectRoot') -and $AgentsProjectRoot) {
  $managedAgentsRoot = (Resolve-Path $AgentsProjectRoot).Path
}

if (-not $SkipProjectScaffold -and $managedAgentsRoot) {
  $scaffoldScript = Join-Path $repoDir 'scripts\scaffold-codex-project.ps1'
  if (Test-Path $scaffoldScript) {
    Write-Step 'Scaffolding project Codex playbook'
    & $scaffoldScript -RepoRoot $repoDir -ProjectRoot $managedAgentsRoot
    if ($LASTEXITCODE -ne 0) {
      throw "scaffold-codex-project.ps1 failed with exit code $LASTEXITCODE"
    }
  }
}

if (-not $SkipAgentsMd -and $managedAgentsRoot) {
  $syncScript = Join-Path $repoDir 'scripts\sync-agents-md.ps1'
  if (Test-Path $syncScript) {
    Write-Step 'Updating project AGENTS.md'
    & $syncScript -RepoRoot $repoDir -ProjectRoot $managedAgentsRoot
    if ($LASTEXITCODE -ne 0) {
      throw "sync-agents-md.ps1 failed with exit code $LASTEXITCODE"
    }
  }
}

if (-not $SkipDoctor) {
  $doctorScript = Join-Path $repoDir 'scripts\doctor-codex.ps1'
  if (Test-Path $doctorScript) {
    Write-Step 'Running Codex doctor'
    if ($RepoLocal) {
      & $doctorScript -RepoRoot $repoDir -RepoLocal -ProjectRoot $managedAgentsRoot
    } else {
      if ($managedAgentsRoot) {
        & $doctorScript -RepoRoot $repoDir -ProjectRoot $managedAgentsRoot
      } else {
        & $doctorScript -RepoRoot $repoDir
      }
    }
    if ($LASTEXITCODE -ne 0) {
      throw "doctor-codex.ps1 reported issues (exit code $LASTEXITCODE)"
    }
  }
}

$codexSkillsRoot = if ($RepoLocal) {
  Join-Path (Resolve-Path $ProjectRoot).Path '.agents\skills'
} else {
  Join-Path $HOME '.codex\skills'
}

Write-Step 'Install complete'
Write-Info "Source repo : $repoDir"
Write-Info "Codex skills: $codexSkillsRoot"
if ($managedAgentsRoot) {
  Write-Info ("AGENTS.md   : {0}" -f (Join-Path $managedAgentsRoot 'AGENTS.md'))
  Write-Info ("Playbook    : {0}" -f (Join-Path $managedAgentsRoot '.gstack\codex\GSTACK-CODEX.md'))
}
if (-not $codexExe) {
  Write-Info 'Install Codex CLI before use: https://github.com/openai/codex'
}
