# Upstream Sync Guide

Updated: 2026-04-04

This fork is maintained as an overlay on top of upstream `garrytan/gstack`, not as a permanently diverging codebase.

## Mental Model

```text
latest upstream gstack
        +
Codex + Windows overlay
        =
this fork's releasable main branch
```

The overlay keeps three kinds of changes:

- full-file ownership for new Codex and Windows tooling
- patch ownership for upstream files that still need local changes
- upstream metadata so you can see which upstream commit the fork was last reviewed against

## Directory Layout

| Path | Purpose |
|---|---|
| `overlay/manifest.json` | Declares which files the overlay owns and which upstream files are patched |
| `overlay/upstream.json` | Stores the upstream repo, branch, and last reviewed upstream SHA |
| `overlay/files/` | Snapshot copies for overlay-owned files |
| `overlay/patches/` | Patch files that re-apply local changes to upstream-owned files |
| `scripts/apply-codex-overlay.ps1` | Applies the overlay to a clean checkout |
| `scripts/check-upstream-overlay.ps1` | Checks whether upstream `main` has advanced |
| `scripts/export-codex-overlay.ps1` | Refreshes `overlay/files/` and `overlay/patches/` from the current repo |
| `scripts/sync-upstream-overlay.ps1` | Fetches upstream and creates a trial worktree with the overlay applied |

## What Is Overlay-Owned Today

Full-file ownership:

- `install-codex.ps1`
- `bootstrap-codex-project.ps1`
- `scripts/doctor-codex.ps1`
- `scripts/scaffold-codex-project.ps1`
- `scripts/sync-agents-md.ps1`
- the overlay scripts themselves
- Codex quickstart docs and this guide
- the upstream watch workflow

Patch ownership:

- `setup`
- `README.md`

The rule is simple: if upstream is likely to keep evolving the file, prefer a patch over a full overwrite.

## Recommended Maintenance Loop

### 1. Check whether upstream moved

```powershell
Set-Location E:\Codex-gstack
.\scripts\check-upstream-overlay.ps1
```

If the script exits with code `2`, upstream is ahead of `overlay/upstream.json`.

### 2. Create a trial worktree from the latest upstream commit

```powershell
Set-Location E:\Codex-gstack
.\scripts\sync-upstream-overlay.ps1
```

This creates a fresh worktree under `.gstack-worktrees\upstream-<sha>` and applies the overlay there.

### 3. Validate the trial worktree

Typical checks:

- run `.\scripts\doctor-codex.ps1`
- run `.\install-codex.ps1 -RepoLocal -ProjectRoot <test-project>`
- rebuild and smoke-test any changed setup path

### 4. Refresh overlay artifacts if you changed the customization layer

```powershell
Set-Location E:\Codex-gstack\.gstack-worktrees\upstream-<sha>
.\scripts\export-codex-overlay.ps1 -UpdateReviewedSha
```

This copies the current overlay-owned files into `overlay/files/` and regenerates patch files for `README.md` and `setup`.

### 5. Promote the tested result

Once the trial worktree is healthy:

1. commit the trial worktree changes
2. merge or fast-forward that result into your release branch
3. push to GitHub
4. re-bootstrap project-local copies when you want projects to consume the new version

## Monitoring Upstream Automatically

This repo includes `.github/workflows/upstream-overlay-watch.yml`.

It runs on a schedule and on manual dispatch. When upstream `main` moves past the SHA in `overlay/upstream.json`, the workflow opens or updates a GitHub issue named `Upstream gstack sync available`.

That gives you a lightweight reminder without auto-merging unreviewed upstream changes.

## Why This Design

This layout is intentionally conservative:

- upstream stays easy to re-fetch
- local Codex and Windows changes stay reviewable
- full overwrites are limited to files that this fork truly owns
- risky files like `setup` remain patch-based so upstream improvements are not silently lost
