# Codex Quickstart

Updated: 2026-04-04

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

### 1. Relationship Diagram

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

The important point is that gstack does not replace Codex. It augments what native Codex can see and which workflow defaults it follows inside a repo.

### 2. Mental Model

When you run `codex`, the runtime is still native Codex. The practical stack is:

- OpenAI model: the "brain" that reasons and writes
- Codex CLI: the local agent runtime and execution environment
- gstack: the skill pack and workflow layer on top

If you also use ChatGPT as your main interface, the cleanest mental model is:

- ChatGPT: entry point and conversation surface
- Codex: local runtime and executor
- gstack: reusable workflow pack

Short version:

```text
OpenAI model brain + Codex runtime + gstack workflow pack
```

### 3. Native Codex vs Global gstack vs Project-Local gstack

There are three practical states:

| State | What exists | What changes |
|---|---|---|
| Native Codex only | no gstack install | Codex behaves like normal Codex |
| Global gstack | `~/.codex/skills/gstack` | all Codex sessions can see gstack skills |
| Project-local gstack | `.agents/skills/gstack`, `.gstack/codex/...`, `AGENTS.md` | only that repo gets the gstack workflow layer |

The safest default for most users is project-local install.

It gives you:

- gstack inside the target repo
- effectively native Codex outside the target repo
- a committed workflow that teammates can inherit

### 4. Project-Local vs Global Install

These two install modes are different in scope:

| Mode | Writes to | Affects | Best for |
|---|---|---|---|
| Project-local | `.agents/skills/gstack`, `.gstack/codex/...`, `AGENTS.md` | one repository | active production repos |
| Global | `~/.codex/skills/gstack` | all Codex sessions for that user | personal default setup across many repos |

Use project-local install when:

- you want repo-specific workflow rules
- you do not want to affect unrelated repos
- you want teammates to get the same behavior from committed files

Use global install when:

- you want gstack available everywhere
- you are comfortable with one user-wide Codex skill pack
- you still understand that Codex itself remains native Codex

### 5. Upstream gstack vs This Fork

Upstream gstack already supports Codex. This fork does not invent Codex support from scratch; it makes the Codex path easier to deploy and more stable on Windows.

| Dimension | Upstream gstack | This fork |
|---|---|---|
| Codex support | already supported via `./setup --host codex` | same support, plus Windows-first onboarding |
| Core skills | same gstack skills and browser workflow | same core skills and browser workflow |
| Installation | more generic and Unix-leaning | `install-codex.ps1` and `bootstrap-codex-project.ps1` |
| Project onboarding | possible, but more manual | managed `AGENTS.md` plus `.gstack/codex/` playbooks |
| Windows compatibility | workable, but rougher edges | fixes for Git Bash detection, Bun, and Playwright bootstrap |
| Validation | basic setup path | `doctor-codex.ps1` for install checks |
| Documentation | general-purpose | bilingual, Codex-first docs |

In short:

- upstream gstack: Codex-compatible
- this fork: Codex-first, Windows-friendlier, and easier to roll out repeatedly

### 6. Which Setup Should You Choose?

Use this quick rule:

```text
Want gstack in one repo only? -> project-local install
Want gstack available everywhere? -> global install
Want the least surprise in production repos? -> start project-local
```

For a Windows + Codex workflow, the recommended order is:

1. bootstrap one real project first
2. confirm the workflow feels right
3. add a global install later only if you want gstack in every repo

### 7. What This Setup Gives You

In a project-local Codex install, this setup gives you four layers of functionality:

- workflow routing: `AGENTS.md` and `.gstack/codex/GSTACK-CODEX.md` tell Codex when to switch into planning, review, QA, release, or safety modes
- reusable skill pack: 28 installed gstack skills, usually namespaced as `gstack-*`
- browser automation: real browser-driven QA, screenshots, login flows, staging checks, and performance checks
- repo-local prompts: `.gstack/codex/prompts/review.md`, `qa.md`, `ship.md`, and `autoplan.md`

In practice, that means this setup can handle:

- product framing and implementation planning
- code review and release preparation
- browser testing and authenticated QA flows
- debugging and root-cause investigation
- safety rails for risky commands or tightly scoped edits
- post-release checks, retros, and ongoing workflow reuse

### 8. Command Catalog

By default, the Codex path in this fork uses namespaced skill names such as `gstack-review`. If your install uses short names, drop the `gstack-` prefix.

#### Planning and Design

| Command | Use it when |
|---|---|
| `gstack` | you want the general entry point and are not sure which workflow to start with |
| `gstack-office-hours` | the product idea is still fuzzy and you need to sharpen the problem |
| `gstack-plan-ceo-review` | you want a product or founder-level challenge of the plan |
| `gstack-plan-eng-review` | you want architecture, edge cases, and tests reviewed before implementation |
| `gstack-plan-design-review` | you want interaction and UX quality reviewed before implementation |
| `gstack-autoplan` | you want one command that turns an idea into a reviewed implementation plan |
| `gstack-design-consultation` | you need a stronger design direction or system |
| `gstack-design-review` | the UI already exists and you want design feedback on the actual implementation |
| `gstack-retro` | you want to review a recent sprint, delivery cycle, or project rhythm |

#### Code, Debugging, and Release

| Command | Use it when |
|---|---|
| `gstack-review` | the branch is ready for a pre-merge code review |
| `gstack-investigate` | there is a bug or regression and you need root-cause analysis before fixing |
| `gstack-ship` | you want release preparation, test checks, and PR readiness |
| `gstack-land-and-deploy` | the change is approved and you want to merge and deploy |
| `gstack-document-release` | code has shipped and docs now need to match reality |
| `gstack-setup-deploy` | you need to configure deployment assumptions before using release automation |

#### Browser, QA, and Performance

| Command | Use it when |
|---|---|
| `gstack-browse` | you need browser control, screenshots, clicks, and page inspection |
| `gstack-qa` | you want end-to-end browser QA and are willing to let the workflow fix issues |
| `gstack-qa-only` | you want QA findings only, without code changes |
| `gstack-benchmark` | you want page-speed and resource-size checks |
| `gstack-canary` | you want post-deploy observation for regressions or failures |
| `gstack-connect-chrome` | you want to connect to a visible Chrome window and watch the flow live |
| `gstack-setup-browser-cookies` | you need authenticated browser sessions for QA or staging |

#### Security, Guardrails, and Maintenance

| Command | Use it when |
|---|---|
| `gstack-cso` | you want a security review or threat-model pass |
| `gstack-careful` | you want warnings before risky or destructive commands |
| `gstack-freeze` | you want to lock edits to a narrow directory or scope |
| `gstack-guard` | you want both command caution and edit-scope protection together |
| `gstack-unfreeze` | you want to remove a previous freeze boundary |
| `gstack-upgrade` | you want to update gstack itself |

### 9. Most Common Command Sequences

For a new feature:

1. `gstack-office-hours`
2. `gstack-autoplan` or the `gstack-plan-*` skills
3. implementation
4. `gstack-review`
5. `gstack-qa`
6. `gstack-ship`

For a production bug:

1. `gstack-investigate`
2. implement the fix
3. `gstack-review`
4. `gstack-qa` or `gstack-qa-only`
5. `gstack-ship`

For a browser-only validation pass:

1. `gstack-browse` or `gstack-connect-chrome`
2. `gstack-setup-browser-cookies` if authentication is needed
3. `gstack-qa` or `gstack-qa-only`

### 10. Repo-Local Prompt Shortcuts

Every bootstrapped repo also gets these prompt files:

- `.gstack/codex/prompts/review.md`
- `.gstack/codex/prompts/qa.md`
- `.gstack/codex/prompts/ship.md`
- `.gstack/codex/prompts/autoplan.md`

Use them when you want Codex to follow the repo's default framing for review, QA, shipping, or planning without re-explaining the workflow each time.

### 11. First Session in `E:\your-project`

After bootstrap, the shortest path is:

```powershell
Set-Location E:\your-project
codex
```

Then start with one concrete instruction, not five at once.

For a new feature, use one of these:

```text
Use gstack-office-hours and help me sharpen this feature idea before we implement it.
```

```text
Use gstack-autoplan and create the implementation plan first.
```

For a code review on your current branch:

```text
Use gstack-review and review the current branch.
```

For browser QA against a staging URL:

```text
Use gstack-qa and test https://staging.example.com.
```

For a bug that should be investigated before fixing:

```text
Use gstack-investigate and find the root cause before making changes.
```

If you prefer the repo-local prompt files, use:

```text
Use .gstack/codex/prompts/review.md and review the current branch.
```

```text
Use .gstack/codex/prompts/qa.md and test https://staging.example.com.
```

```text
Use .gstack/codex/prompts/ship.md and prepare this branch to ship.
```

The recommended first real session for most repos is:

1. start with `gstack-review` if code already exists and you want signal fast
2. start with `gstack-office-hours` if the task is still ambiguous
3. start with `gstack-qa` if the main risk is browser behavior
