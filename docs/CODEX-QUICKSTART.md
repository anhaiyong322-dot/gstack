# Codex Quickstart

Updated: 2026-04-04

[中文版本](CODEX-QUICKSTART.zh-CN.md)

This is the practical install-and-usage guide for running gstack with Codex on Windows.

## 1. What You Are Installing

This fork does not replace native Codex. The stack is:

```text
OpenAI model brain + Codex runtime + gstack workflow pack
```

That means:

- Codex still runs as native Codex
- gstack adds skills, browser workflows, safety rails, and repo-local defaults
- this fork keeps upstream gstack behavior, but makes the Codex path easier to install and reuse on Windows

## 2. Before You Start

Install these tools first:

- Git for Windows, including Git Bash
- Bun
- Node.js
- Codex CLI

If you want a quick environment check from this repo later, run:

```powershell
Set-Location $HOME\gstack
.\scripts\doctor-codex.ps1
```

## 3. Choose an Install Mode

Use this rule:

```text
Want gstack in one repo only? -> project-local install
Want gstack available everywhere? -> global install
Want the least surprise? -> start project-local
```

### Project-Local Install: Recommended

This is the safest default for real repositories because it only affects one repo.

Run from PowerShell:

```powershell
git clone --single-branch --depth 1 https://github.com/anhaiyong322-dot/gstack.git $HOME\gstack
Set-Location $HOME\gstack
.\bootstrap-codex-project.ps1 -ProjectRoot E:\your-project
```

What this writes into the target repo:

- `.agents/skills/gstack`
- `.gstack/codex/GSTACK-CODEX.md`
- `.gstack/codex/prompts/review.md`
- `.gstack/codex/prompts/qa.md`
- `.gstack/codex/prompts/ship.md`
- `.gstack/codex/prompts/autoplan.md`
- `AGENTS.md`

What the bootstrap command also does for you:

- checks Git Bash, Bun, Node.js, and Codex CLI
- runs `./setup --host codex`
- generates the Codex skills
- runs `scripts/doctor-codex.ps1`

### Global Install: Optional

Use this only when you want gstack available in every Codex repo for the current user.

```powershell
git clone --single-branch --depth 1 https://github.com/anhaiyong322-dot/gstack.git $HOME\gstack
Set-Location $HOME\gstack
.\install-codex.ps1
```

Global install writes to:

- `~/.codex/skills/gstack`

Codex still stays native Codex. The difference is only that every repo can now see the gstack skills.

### Wire a Global Install into One Repo Later

If you already installed globally and later decide one repo should also get the managed `AGENTS.md` and `.gstack/codex/` files:

```powershell
Set-Location $HOME\gstack
.\install-codex.ps1 -AgentsProjectRoot E:\your-project
```

### Manual Repo-Local Setup: Advanced

If you want the raw upstream-style path instead of the PowerShell bootstrap:

```bash
git clone --single-branch --depth 1 https://github.com/anhaiyong322-dot/gstack.git .agents/skills/gstack
cd .agents/skills/gstack && ./setup --host codex
```

That works, but the PowerShell bootstrap is the cleaner Windows path because it also updates `AGENTS.md`, scaffolds `.gstack/codex/`, and runs `doctor-codex.ps1`.

## 4. Start Using It

After a project-local install:

```powershell
Set-Location E:\your-project
codex
```

If Codex was already open in that repo, restart it once so it reloads the installed skills and `AGENTS.md`.

## 5. First Commands to Type in Codex

Start with one concrete instruction at a time.

For planning:

```text
Use gstack-office-hours and help me sharpen this feature idea before we implement it.
```

```text
Use gstack-autoplan and create the implementation plan first.
```

For review:

```text
Use gstack-review and review the current branch.
```

For browser QA:

```text
Use gstack-qa and test https://staging.example.com.
```

For release prep:

```text
Use gstack-ship and prepare this branch to ship.
```

If you prefer repo-local prompt files:

```text
Use .gstack/codex/prompts/review.md and review the current branch.
```

```text
Use .gstack/codex/prompts/qa.md and test https://staging.example.com.
```

```text
Use .gstack/codex/prompts/ship.md and prepare this branch to ship.
```

## 6. Recommended Daily Workflow

For a new feature:

1. `gstack-office-hours`
2. `gstack-autoplan` or the `gstack-plan-*` skills
3. implementation
4. `gstack-review`
5. `gstack-qa`
6. `gstack-ship`

For a bug:

1. `gstack-investigate`
2. fix the root cause
3. `gstack-review`
4. `gstack-qa` or `gstack-qa-only`
5. `gstack-ship`

For browser-only validation:

1. `gstack-browse` or `gstack-connect-chrome`
2. `gstack-setup-browser-cookies` if auth is needed
3. `gstack-qa` or `gstack-qa-only`

## 7. What the System Can Do

In a project-local install, this setup gives you four layers:

- workflow routing through `AGENTS.md` and `.gstack/codex/GSTACK-CODEX.md`
- a reusable skill pack, usually namespaced as `gstack-*`
- browser automation for QA, screenshots, auth flows, staging checks, and performance checks
- repo-local prompt templates for review, QA, ship, and planning

In practice, it covers:

- feature framing and implementation planning
- code review and release preparation
- browser testing and authenticated QA flows
- debugging and root-cause investigation
- safety rails for risky commands and tightly scoped edits
- post-release checks, retros, and repeated repo workflows

## 8. Command Map

By default, this fork uses namespaced skill names such as `gstack-review`. If your install uses short names, drop the `gstack-` prefix.

### Planning and Design

| Command | Use it when |
|---|---|
| `gstack` | you want a general entry point and are not sure where to start |
| `gstack-office-hours` | the idea is still fuzzy and you need sharper problem framing |
| `gstack-plan-ceo-review` | you want product and founder-level challenge on the plan |
| `gstack-plan-eng-review` | you want architecture, failure modes, and test coverage challenged before implementation |
| `gstack-plan-design-review` | you want UX and interaction quality reviewed before implementation |
| `gstack-autoplan` | you want one command that turns an idea into a reviewed plan |
| `gstack-design-consultation` | you need a stronger design direction or system |
| `gstack-design-review` | the UI already exists and needs review on the real implementation |
| `gstack-retro` | you want to review a sprint, delivery cycle, or recent project rhythm |

### Code, Debugging, and Release

| Command | Use it when |
|---|---|
| `gstack-review` | the branch is ready for a pre-merge review |
| `gstack-investigate` | there is a bug or regression and you need root-cause analysis first |
| `gstack-ship` | you want release prep, test checks, and PR readiness |
| `gstack-land-and-deploy` | a change is approved and you want to merge and deploy |
| `gstack-document-release` | code shipped and docs need to match reality |
| `gstack-setup-deploy` | you need deployment assumptions configured before release automation |

### Browser, QA, and Performance

| Command | Use it when |
|---|---|
| `gstack-browse` | you need browser control, screenshots, clicks, or page inspection |
| `gstack-qa` | you want full browser QA and are willing to let the workflow fix issues |
| `gstack-qa-only` | you want QA findings only, without code changes |
| `gstack-benchmark` | you want performance and resource-size checks |
| `gstack-canary` | you want post-deploy observation for regressions |
| `gstack-connect-chrome` | you want to watch a visible Chrome session live |
| `gstack-setup-browser-cookies` | you need authenticated browser sessions |

### Security, Guardrails, and Maintenance

| Command | Use it when |
|---|---|
| `gstack-cso` | you want a security review or threat-model pass |
| `gstack-careful` | you want warnings before risky or destructive commands |
| `gstack-freeze` | you want to lock edits to a narrow directory or scope |
| `gstack-guard` | you want both command caution and edit-scope protection together |
| `gstack-unfreeze` | you want to remove a previous freeze boundary |
| `gstack-upgrade` | you want to update gstack itself |

## 9. Troubleshooting and Refresh

If setup says `bun` is missing:

```powershell
powershell -c "irm bun.sh/install.ps1|iex"
```

Then open a new PowerShell window, or re-run the installer from the same shell after Bun is on `PATH`.

If the project wiring drifted:

```powershell
Set-Location $HOME\gstack
.\install-codex.ps1 -AgentsProjectRoot E:\your-project
```

If the repo already vendors gstack under `.agents\skills\gstack` and you want to rebuild the local copy:

```powershell
.\.agents\skills\gstack\bootstrap-codex-project.ps1 -ProjectRoot .
```

If skills are present but behavior looks stale, restart Codex from the project root.

## 10. Appendix

### Relationship Diagram

```text
                    you type: codex
                         |
                         v
                  native Codex CLI
                         |
        -----------------------------------------
        |                                       |
        v                                       v
reads global skill roots                 reads current repo
`~/.codex/skills/...`                    `.agents/skills/gstack`
                                         `.gstack/codex/...`
                                         `AGENTS.md`
        \_______________________   _______________________/
                                \ /
                                 v
                 final behavior = native Codex
                                + optional gstack skills
                                + optional repo workflow rules
```

gstack does not replace Codex. It augments what native Codex can see and which defaults it follows.

### Native Codex vs Global gstack vs Project-Local gstack

| State | What exists | What changes |
|---|---|---|
| Native Codex only | no gstack install | Codex behaves like normal Codex |
| Global gstack | `~/.codex/skills/gstack` | all Codex sessions can see gstack skills |
| Project-local gstack | `.agents/skills/gstack`, `.gstack/codex/...`, `AGENTS.md` | only that repo gets the gstack workflow layer |

The safest default for most users is still project-local install.

### Upstream gstack vs This Fork

Upstream gstack already supports Codex. This fork does not invent Codex support from scratch; it makes the Codex path easier to deploy and more stable on Windows.

| Dimension | Upstream gstack | This fork |
|---|---|---|
| Codex support | already supported via `./setup --host codex` | same support, plus Windows-first onboarding |
| Installation | more generic and Unix-leaning | `install-codex.ps1` and `bootstrap-codex-project.ps1` |
| Project onboarding | possible, but more manual | managed `AGENTS.md` plus `.gstack/codex/` playbooks |
| Windows compatibility | workable, but rougher edges | fixes for Git Bash detection, Bun, and Playwright bootstrap |
| Validation | basic setup path | `doctor-codex.ps1` for install checks |
| Documentation | general-purpose | bilingual, Codex-first docs |

Short version:

- upstream gstack: Codex-compatible
- this fork: Codex-first and Windows-friendlier

### Keeping This Fork Current with Upstream

This fork now includes an overlay maintenance layer:

```text
latest upstream gstack
        +
this fork's overlay
        =
your maintained Codex-first fork
```

When you want to pull in new upstream changes, use [Upstream Sync Guide](UPSTREAM-SYNC.md).
