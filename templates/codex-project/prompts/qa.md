# gstack Codex QA Prompt

Run `gstack-qa` against `<URL>`.

Expectations:
- Use the browser workflow, not text-only inspection.
- Reproduce the core user flow end to end.
- Check console errors, failed network requests, and visible regressions.
- Capture screenshots for important failures.
- Fix confirmed issues with atomic changes and regression coverage when practical.
