# gstack Codex Playbook

<!-- Managed by gstack scaffold-codex-project.ps1. Re-run the installer to refresh. -->

This repository is wired to use gstack as the default Codex workflow layer.
Use this file as the project-local source of truth for when to route work into
gstack skills instead of improvising prompts from scratch.

## Workflow Routing

- Discovery, framing, and specs: `gstack-office-hours`, then `gstack-plan-ceo-review`, `gstack-plan-eng-review`, and `gstack-plan-design-review` as needed.
- One-command planning pipeline: `gstack-autoplan` when you want the reviewed plan in one pass.
- Debugging and root cause analysis: `gstack-investigate`.
- Pre-merge review: `gstack-review`.
- Browser QA, screenshots, staging checks, and authenticated flows: `gstack-browse`, `gstack-qa`, or `gstack-qa-only`.
- Release prep and shipping: `gstack-ship`, then `gstack-document-release`, `gstack-land-and-deploy`, and `gstack-canary` when the task reaches deployment.
- High-risk commands or tightly scoped edits: `gstack-careful`, `gstack-freeze`, `gstack-guard`, and `gstack-unfreeze`.

## Default Operating Rules

- For non-trivial feature work, plan before implementing unless the user explicitly tells you to skip planning.
- For any branch with meaningful changes, prefer `gstack-review` before `gstack-ship`.
- For a staging or production URL, use browser-based gstack skills instead of text-only inspection.
- For destructive commands, risky refactors, or scoped debugging, enable `gstack-guard` or `gstack-freeze` first.
- If a prompt template under `.gstack/codex/prompts/` fits the task, start from that template instead of inventing a new prompt.

## Prompt Templates

- Review: `.gstack/codex/prompts/review.md`
- QA: `.gstack/codex/prompts/qa.md`
- Ship: `.gstack/codex/prompts/ship.md`
- Autoplan: `.gstack/codex/prompts/autoplan.md`

## Suggested Session Order

1. Identify the workflow stage.
2. Pick the matching gstack skill or prompt template.
3. Run the skill and keep work inside that workflow until the outcome is clear.
4. Return findings, fixes, screenshots, or PR state based on the skill you used.

## Refresh

If this playbook or the generated skills drift, rerun one of these:

```powershell
.\.agents\skills\gstack\bootstrap-codex-project.ps1 -ProjectRoot .
```

or

```powershell
Set-Location <your-gstack-checkout>
.\install-codex.ps1 -AgentsProjectRoot <this-repo>
```
