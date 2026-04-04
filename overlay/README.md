# Codex Overlay

This directory turns the fork into a maintained overlay instead of a long-lived hard fork.

## Model

```text
latest garrytan/gstack
        +
Codex + Windows overlay
        =
this fork's main branch
```

The goal is to keep up with upstream quickly while preserving the Codex-first workflow, Windows fixes, and project bootstrap tools that live in this fork.

## What lives here

- `manifest.json`: overlay ownership map
- `upstream.json`: last reviewed upstream commit
- `files/`: snapshots for overlay-owned files that do not come from upstream
- `patches/`: git patches for files that still belong to upstream but need local changes

## Ownership rules

- Full-file ownership: new scripts, Windows installers, Codex quickstarts, maintenance docs, and the overlay workflow itself
- Patch ownership: files that upstream actively evolves and this fork still needs to modify, currently `setup` and `README.md`

## Main scripts

- `scripts/apply-codex-overlay.ps1`: apply the overlay to a clean upstream checkout
- `scripts/export-codex-overlay.ps1`: refresh `overlay/files/` and `overlay/patches/` from the current repo state
- `scripts/check-upstream-overlay.ps1`: compare `overlay/upstream.json` with the latest upstream commit
- `scripts/sync-upstream-overlay.ps1`: fetch upstream, create a trial worktree, and apply the overlay there

## Suggested workflow

1. Check whether upstream changed.
2. Create a trial worktree from the latest upstream commit.
3. Apply the overlay.
4. Fix any patch conflicts or behavior regressions.
5. Regenerate overlay artifacts if the customization layer changed.
6. Update `overlay/upstream.json` and merge the result into `main`.

The detailed operator guide lives in [docs/UPSTREAM-SYNC.md](../docs/UPSTREAM-SYNC.md).
