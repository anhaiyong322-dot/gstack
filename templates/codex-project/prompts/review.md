# gstack Codex Review Prompt

Run `gstack-review` on the current branch.

Expectations:
- Findings first, ordered by severity.
- Focus on regressions, data loss, race conditions, security, and missing tests.
- If an issue is obvious and low-risk, fix it. Otherwise report it with precise file references.
- Keep the final answer in review format: findings, open questions, then short summary.
