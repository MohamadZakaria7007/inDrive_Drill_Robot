# inDrive_Drill_Robot

API + UI tests for the Toolshop demo shop ([Power Tools](https://practicesoftwaretesting.com/category/power-tools)),
in Robot Framework 7: SeleniumLibrary (Chrome) for UI, RequestsLibrary (`requests`) for the REST API.

## Run

```bash
pip install -r requirements.txt
cp .env.example .env            # public URLs are defaults; demo credentials only for login tests
python -m robot -A robot.args tests                      # everything -> results/log.html
python -m robot -A robot.args -i api tests               # API only
python -m robot -A robot.args -i ui --variable HEADLESS:False tests   # watch the browser
python -m robot -A robot.args -i ui --variable HEADLESS:False --variable SELENIUM_SPEED:1.5s tests  # demo pace
robocop check . && robocop format --check .              # lint
```

## Layout

| Path | What |
|---|---|
| `variables/settings.py` | only config source (CLI > env > `.env` > defaults) |
| `resources/api/` | `api_session` (session, retries on 502/503/504, TLS verify on), `catalog_api` (categories, products) |
| `resources/ui/` | `browser` (lifecycle, explicit waits), `category_page` (page object, `data-test` locators) |
| `schemas/` | strict JSON-schema contracts (`additionalProperties: false`) |
| `tests/api`, `tests/ui` | suites; tags `api`, `ui`, `smoke`, `known-bug` |

## Known bugs

- **PRICE-FORMAT**: the category grid shows `$46.5` instead of `$46.50` (test U6, reported as SKIP while the bug exists; it FAILS once fixed so the marker gets removed).

## CI

Two jobs: "Unit + API tests" runs on every push. "UI tests" is **manual only** (Actions > tests >
Run workflow): the UI host is behind Cloudflare and GitHub-hosted runners get its
"Just a moment..." bot check instead of the app (every UI test logged
`Page at failure: ... | title: Just a moment...`). That is the environment, not the tests, and we
don't bypass bot protection: UI runs locally, or in CI against a copy of the app we control
(the app is open source and ships a docker-compose setup).

The login suite needs repository secrets `CUSTOMER_EMAIL` / `CUSTOMER_PASSWORD` (the published
demo customer); without them it is reported as SKIPPED with that reason.
