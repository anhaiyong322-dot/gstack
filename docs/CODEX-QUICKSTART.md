# Codex Quickstart

Updated: 2026-04-03

[中文版本](CODEX-QUICKSTART.zh-CN.md)

This guide is the shortest path to using gstack inside a real project with Codex.

## Prerequisites

- Git for Windows with Git Bash
- Bun
- Node.js
- Codex CLI

## First-Time Setup

From PowerShell:

```powershell
git clone --single-branch --depth 1 https://github.com/anhaiyong322-dot/gstack.git $HOME\gstack
Set-Location $HOME\gstack
.\bootstrap-codex-project.ps1 -ProjectRoot E:\your-project
```

What this does:

- installs or updates the gstack checkout
- runs `./setup --host codex`
- copies gstack into `E:\your-project\.agents\skills\gstack`
- writes or updates `E:\your-project\AGENTS.md`
- scaffolds `.gstack\codex\GSTACK-CODEX.md`
- scaffolds `.gstack\codex\prompts\review.md`
- scaffolds `.gstack\codex\prompts\qa.md`
- scaffolds `.gstack\codex\prompts\ship.md`
- scaffolds `.gstack\codex\prompts\autoplan.md`
- runs `scripts\doctor-codex.ps1`

## Start Codex

After setup finishes:

```powershell
Set-Location E:\your-project
codex
```

If Codex was already open for that repo, restart it so it reloads `AGENTS.md` and the installed skills.

## First Commands

Use one of these patterns in Codex:

- `Use the gstack workflow for this task.`
- `Run a gstack-style review of the current branch.`
- `Use .gstack/codex/prompts/review.md and review the current branch.`
- `Use .gstack/codex/prompts/qa.md and test https://staging.example.com.`
- `Use .gstack/codex/prompts/ship.md and prepare this branch to ship.`
- `Use .gstack/codex/prompts/autoplan.md and create the implementation plan first.`

## Default Mapping

Use these routes by default:

- feature shaping or discovery: `gstack-office-hours`, then the `gstack-plan-*` skills
- pre-merge code review: `gstack-review`
- browser validation or staging checks: `gstack-qa` or `gstack-qa-only`
- release prep: `gstack-ship`
- risky commands or scoped edits: `gstack-guard`, `gstack-careful`, or `gstack-freeze`

The repository-local source of truth is `.gstack/codex/GSTACK-CODEX.md`.

## Troubleshooting

If setup says `bun` is missing, install it from PowerShell:

```powershell
powershell -c "irm bun.sh/install.ps1|iex"
```

Then open a new PowerShell window, or re-run the installer from the same shell after Bun is on `PATH`.

If setup drifted, rerun:

```powershell
Set-Location $HOME\gstack
.\install-codex.ps1 -AgentsProjectRoot E:\your-project
```

If the repo uses a vendored copy under `.agents\skills\gstack`, rerun:

```powershell
.\.agents\skills\gstack\bootstrap-codex-project.ps1 -ProjectRoot .
```

If skills are present but behavior looks stale, restart Codex in the project root.

## Appendix

### Mental Model

When you run `codex`, the runtime is still native Codex. gstack does not replace the CLI or turn Codex into a different program.

The practical stack is:

- OpenAI model: the "brain" that reasons and writes
- Codex CLI: the local agent runtime and execution environment
- gstack: the skill pack and workflow layer on top

If you also use ChatGPT as your main interface, it is best to think of ChatGPT as the entry point and Codex as the runtime.

### Project-Local vs Global Install

There are two distinct install modes:

- project-local install: writes `.agents/skills/gstack`, `.gstack/codex/...`, and `AGENTS.md` into one repo
- global install: writes the Codex runtime root under `~/.codex/skills/gstack`

Project-local install is the safer default if you want gstack to affect only one repository. In that mode:

- `codex` inside that repo sees gstack
- `codex` in unrelated directories stays effectively native

Global install makes gstack skills visible to all Codex sessions for that user account, but Codex is still the native runtime.

### What This Fork Changes

Upstream gstack already supports Codex. This fork does not invent Codex support from scratch; it hardens the workflow for a Windows-first Codex setup.

The main additions in this fork are:

- `install-codex.ps1` for Windows-friendly installation
- `bootstrap-codex-project.ps1` for one-command project onboarding
- managed `AGENTS.md` routing for Codex workflow stages
- project-local playbooks under `.gstack/codex/`
- `doctor-codex.ps1` for environment and install checks
- Windows fixes for Bun, Git Bash, and Playwright bootstrap
- bilingual quickstart docs

In short:

- upstream gstack: Codex-compatible
- this fork: Codex-first and easier to deploy on Windows
