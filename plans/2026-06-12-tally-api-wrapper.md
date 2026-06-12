# tallyr: R package wrapping the Tally.so API

> When implementation starts, copy this plan to `plans/2026-06-12-tally-api-wrapper.md` in the project, and add `^plans$` to `.Rbuildignore`.

## Context

`tallyr` is a fresh package skeleton (DESCRIPTION, LICENSE, empty `R/`) at `/Users/ellakaye/Projects/mine/packages/tallyr`. Goal for the first version: authenticate against the Tally.so API and import form data into R. Agreed scope: **auth + import only** — API key handling, `tally_whoami()`, `tally_forms()`, `tally_submissions()` returning a **wide tibble** (one row per submission, one column per question).

Design follows the **sitrep pattern** from [drmowinckels.io/blog/2026/sitrep-functions](https://drmowinckels.io/blog/2026/sitrep-functions/): small checking functions with structured returns (not booleans, no side effects), reused both for early validation inside API functions and by a `tally_sitrep()` diagnostic report; settings resolved via the hierarchy R option > env var.

## Tally API facts (verified from developers.tally.so)

- Base URL: `https://api.tally.so`
- Auth: API key (format `tly-xxxx`, created at Tally Settings → API keys) sent as `Authorization: Bearer <key>`. **No OAuth** — "logging in" = supplying an API key.
- Rate limit: 100 requests/minute.
- `GET /users/me` — current authenticated user (verifies the key works).
- `GET /forms` — paginated (`page`, `limit` ≤ 500, `workspaceIds`); response: `{ items, page, limit, total, hasMore }`; form fields: `id`, `name`, `workspaceId`, `status` (BLANK/DRAFT/PUBLISHED/DELETED), `numberOfSubmissions`, `isClosed`, `createdAt`, `updatedAt`.
- `GET /forms/{formId}/submissions` — params `page`, `limit` (≤ 500), `filter` (all/completed/partial), `startDate`, `endDate` (ISO 8601); response: `{ page, limit, hasMore, totalNumberOfSubmissionsPerFilter, questions[], submissions[] }`. Each submission: `id`, `formId`, `isCompleted`, `submittedAt`, `responses[]` where each response has `questionId`, `answer` (type-varying), `formattedAnswer` (string). `questions[]` gives `id`, `title`, `type` — use for column names/order.

## Design

Modern httr2-based wrapper, tidyverse conventions, testthat 3e.

**Dependencies (Imports):** httr2, cli, tibble, purrr, rlang, curl (for `has_internet()` in sitrep)
**Suggests:** testthat (>= 3.0.0), httptest2, withr

### Files

**`R/tallyr-package.R`** — package-level doc (`"_PACKAGE"`), shared roxygen imports.

**`R/api-key.R`** — checking functions, sitrep-style (structured returns, no side effects):
- `tally_api_key()` (exported): resolves the key via hierarchy `getOption("tallyr.api_key")` → `TALLY_API_KEY` env var; `cli::cli_abort()` with guidance if unset (point to Tally Settings → API keys and `usethis::edit_r_environ()`).
- `tally_api_key_status()` (internal): returns `list(value, source, valid)` — `value` the key (or `NA`), `source` one of `"R option: tallyr.api_key"` / `"Environment variable: TALLY_API_KEY"` / `"Not found"`, `valid` = found and matches `^tly-` format. Never errors, never prints. `tally_api_key()` is a thin wrapper over this that aborts when `!valid`.
- `has_tally_api_key()` (internal): `tally_api_key_status()$valid` — used for early validation and to skip live tests/examples.

**`R/request.R`** (internal plumbing)
- `tally_request(endpoint)`: checks `has_tally_api_key()` first, aborting with "set your API key" guidance; then `httr2::request("https://api.tally.so")` + `req_url_path_append()` + `req_auth_bearer_token()` + `req_user_agent("tallyr (https://github.com/EllaKaye/tallyr)")` + `req_throttle(rate = 100/60)` + `req_error(body = )` pulling the API's error message for readable failures.
- `tally_paginate(req)`: `httr2::req_perform_iterative()` with `iterate_with_offset("page")` and `resp_complete = \(resp) !isTRUE(resp_body_json(resp)$hasMore)`; returns combined parsed pages. Always request `limit = 500` to minimise calls.

**`R/whoami.R`**
- `tally_whoami()`: `GET /users/me`; cli message confirming who you're authenticated as; invisibly returns the parsed user list. Doubles as the connectivity test inside `tally_sitrep()` — factor the quiet fetch into an internal `tally_user(error = FALSE)` so both share one code path.

**`R/sitrep.R`**
- `tally_sitrep()` (exported): cli situation report, no errors regardless of state, invisibly returns the collected status. Sections:
  - `cli_h1("tallyr Situation Report")`
  - **API key**: from `tally_api_key_status()` — found/missing (✔/✖), source (option vs env var), format check (`tly-` prefix) without ever printing the key itself.
  - **Connectivity**: `curl::has_internet()`, then if a key is present, live `GET /users/me` via `tally_user(error = FALSE)` — ✔ "Authenticated as {name} ({email})" or ✖ with the API error.
  - **Recommendations**: if key missing → how to set it (`TALLY_API_KEY` via `usethis::edit_r_environ()`, or `options(tallyr.api_key = )` for a session); if key invalid → regenerate at Tally Settings → API keys; else ✔ "tallyr setup looks good!".

**`R/forms.R`**
- `tally_forms(workspace_ids = NULL)`: paginates `GET /forms`; returns tibble with snake_case columns: `id`, `name`, `status`, `number_of_submissions`, `is_closed`, `workspace_id`, `created_at`/`updated_at` parsed to POSIXct.

**`R/submissions.R`**
- `tally_submissions(form_id, filter = c("all", "completed", "partial"), start_date = NULL, end_date = NULL)`:
  - Validates args (`rlang::arg_match()`; dates coerced to ISO 8601).
  - Paginates `GET /forms/{form_id}/submissions`.
  - Builds **wide tibble**: metadata columns `submission_id`, `submitted_at` (POSIXct), `is_completed`, then one column per question, named by question `title`, ordered as in the API's `questions[]` array (form order).
  - Cell values: `formattedAnswer` (consistent character representation across question types); `NA` where a submission has no response for a question.
  - Duplicate question titles disambiguated (`vctrs::vec_as_names(..., repair = "unique")` style or suffix with question id).
- Internal parsing helper kept separate from the HTTP call so it can be unit-tested on fixture JSON directly.

### Housekeeping
- DESCRIPTION: real Title ("Import Form Data from 'Tally'") and Description paragraph; add Imports/Suggests; `Config/testthat/edition: 3`. (`RoxygenNote: 8.0.0` is current — leave for `devtools::document()` to manage.)
- `.Rbuildignore`: add `^plans$` (and `^README\.Rmd$` if applicable).
- `usethis::use_testthat(3)`; README.md (brief: install, set `TALLY_API_KEY`, `tally_sitrep()`, `tally_whoami()`, `tally_forms()`, `tally_submissions()`); NEWS.md not needed yet.

### Tests (testthat 3e)
- `tally_api_key_status()`: option set / env var set / both (option wins) / neither; format validity — via `withr::local_envvar()` + `withr::local_options()`. `tally_api_key()` errors informatively when unset.
- Submission/forms parsing: unit-test the pure parsing helpers against small in-repo JSON fixtures mirroring the documented response shapes (covers wide pivot, missing answers, duplicate titles, date parsing) — no network needed.
- `tally_sitrep()`: snapshot test of output with no key set (network section skipped when offline/keyless, so deterministic).
- Request building: assert URL/auth header on the httr2 request object, or `httptest2::with_mock_dir()` for an end-to-end mocked `tally_forms()` call.

## Verification
1. `devtools::document()` then `devtools::check()` — clean (0 errors/warnings).
2. `devtools::test()` — all tests pass without network.
3. Live smoke test if `TALLY_API_KEY` is available in the session: `tally_sitrep()`, `tally_whoami()`, `tally_forms()`, and `tally_submissions()` on one of Ella's real forms; confirm wide tibble shape.
