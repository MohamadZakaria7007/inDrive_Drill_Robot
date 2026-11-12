# CLAUDE.md — inDrive_Drill_Robot (Robot Framework 7 · SeleniumLibrary · RequestsLibrary · jsonschema)

I am the engineer; you are my pair in a live-coding interview. I must be able to explain every
line: small changes, follow existing patterns, one sentence of *why* for non-obvious choices.
Keep chat answers short — the interviewer is reading along. Global Python 3.13 install (no venv).

## Commands
- All: `python -m robot -A robot.args tests` → `results/log.html` · tag `-i smoke|ui|api|unit` · one `-t "Name*"`
- Override: `--variable UI_BASE_URL:https://...` · `--variable HEADLESS:False`
- Validate fast: `python -m robot --dryrun --output NONE --report NONE --log NONE tests`
  → always read the final "N tests, N passed" line, never a truncated head of the output.
- Lint/format: `robocop check .` · `robocop format .`
- Locators on a new page: `C:\Users\moham\Desktop\qa-interview-kit\.venv\Scripts\python C:\Users\moham\.claude\skills\qa-locators\scripts\locators.py <url> --aria`

## Working agreement
1. Plan before code: assumptions/questions → numbered test list (happy, negative, boundary, edge)
   → files to touch. Wait for my go.
2. 1–3 tests per step; dry-run, run, show the real summary. Never claim "passes" without running.
3. Discover locators, never guess.
4. Failure → diagnose first (app / locator / timing / data / environment / library behaviour)
   with evidence. Never weaken an assertion to go green.
5. Real app bug → expected behaviour in a keyword, called via
   `Known Bug    <bug>    <expected error glob>    <keyword>    <args>`, tag `known-bug`,
   draft a bug report (title, steps, expected, actual, severity).
6. No pip installs, no unrelated reformatting, no renames without asking.

## Structure & conventions
- `variables/settings.py` = only config source. `resources/ui/<page>.resource` = page objects:
  locators in Variables (`css:[data-testid="..."]` first; relative XPath anchored on test ids +
  exact text OK; positional XPath / hashed classes never), keywords named after user intent.
- `resources/api/api_session.resource` → sessions `anonymous` / `authorized`, cleanup registry
  (`Start Cleanup Tracking` / `Cleanup After Test` / `Run Cleanups`). One `<service>.resource`
  per API resource; every call takes `session=` and `expected_status=`.
- `libraries/*.py` = Python keywords (data builders, Money→Decimal, Contracts); `__all__` controls exports.
- `schemas/*.json` = strict JSON-schema contracts (`additionalProperties: false`, `$ref` by file name),
  checked with `Response Should Match Schema    ${response}    <name>`.
- Suites: `Test Tags` per layer, `[Tags]    smoke`, A/A/A blocks, data variations via `[Template]`
  or `Test Template` tables. No `Sleep`, no implicit wait: `Wait Until ...` keywords or
  `Wait Until Keyword Succeeds    5s    200ms    <assertion>`. One browser per suite + clean session per test.

## Git and CI
- Branch `main`; commit + push after every green slice once the user has given the standing OK.
- UI suites use `Test Teardown    Log Page State On Failure`: it prints
  `Page at failure: <url> | title: <title>` to the console (visible in CI logs).
- CI has two jobs, "Unit + API tests" and "UI tests". If only UI is red and the title is like
  "Just a moment...", bot protection is blocking GitHub's runners, not a test bug. Never bypass
  it: keep UI local (say why in the README) or run a copy of the app in CI.
- Public URLs can be workflow defaults: `${{ vars.UI_BASE_URL || 'https://...' }}`.

## Gotchas already hit (don't repeat them)
- RequestsLibrary 0.9.7 `Create Session    cookies=` is library-global → auth in per-session `headers=`.
- RF 7 Variables section has no multi-line `separator=` → `VAR    ${x}    a    b    separator=;` in a keyword.
- `$var` in `Evaluate` inside a keyword with EMBEDDED arguments breaks → use `'''${var}'''` there.
- Named args (`x=y`) stored in a list and expanded later become positional strings.
- Unused return values → `${_}`.

## Reference implementation (same conventions, fully working)
C:/Users/moham/Desktop/qa-interview-kit-robot — read a file there for a full example (page
resources, booking service keywords, Known Bug usage, data-driven kata tables).
