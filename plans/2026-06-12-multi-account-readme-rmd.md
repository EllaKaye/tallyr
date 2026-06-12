# tallyr: multi-account support + README.Rmd workflow

> When implementation starts, copy this plan to `plans/2026-06-12-multi-account-readme-rmd.md` in the project.

## Context

tallyr v0.0.0.9000 is built and checks cleanly (auth via single `TALLY_API_KEY`, `tally_whoami()`, `tally_sitrep()`, `tally_forms()`, `tally_submissions()`). Ella works with several Tally accounts, so the package needs first-class multi-account support. Agreed UX: **named keys in `.Renviron` + `tally_use_account()` session switcher + an `account` argument on every API function** for one-off calls. Separately, the README should be authored as `README.Rmd` and `README.md` generated with `devtools::build_readme()` — never edited directly.

## Part 1: Multi-account support

### Key storage and naming

Keys live in env vars: `TALLY_API_KEY` is the **default** account; additional accounts are `TALLY_API_KEY_<NAME>` (e.g. `TALLY_API_KEY_WORK` → account `"work"`). Account names are case-insensitive: normalise with `toupper()` + non-alphanumerics → `_` when building the env var name, report lowercase names to users.

### Resolution hierarchy (extends `tally_api_key_status()` in `R/api-key.R`)

`tally_api_key_status(account = NULL)`:
1. `account` argument (explicit per-call) — if `NULL`, fall back to `getOption("tallyr.account")` (the session switcher).
2. If an account is set (and isn't `"default"`): the key comes from `TALLY_API_KEY_<NAME>` only; `source` reports that env var. The `tallyr.api_key` option is **not** consulted when an account is active (switching accounts is the more intentional action; document this).
3. Otherwise (default account): existing behaviour — `tallyr.api_key` option → `TALLY_API_KEY` env var.

Returned status gains an `account` field (`"default"` or the account name). `tally_api_key(account = NULL)` and `has_tally_api_key(account = NULL)` pass it through; the missing-key abort message names the specific env var looked for and lists available accounts.

### New exported functions (`R/accounts.R`)

- `tally_accounts()`: scans `Sys.getenv()` names for `^TALLY_API_KEY(_.+)?$`; returns a character vector of account names (lowercase), `"default"` first if `TALLY_API_KEY` is set.
- `tally_use_account(account)`: validates the account's key exists (via `tally_api_key_status(account)`, aborting with the available accounts if not), sets `options(tallyr.account = )`, cli success message, invisibly returns the *previous* account (handy for restoring). `tally_use_account(NULL)` (or `"default"`) clears back to the default account.

### Threading the `account` argument

Add `account = NULL` as the final parameter, passed down to `tally_request()` → `tally_api_key()`:
- `tally_request(..., account = NULL)` in `R/request.R` (named arg after `...`, so path components are unaffected)
- `tally_forms(workspace_ids = NULL, account = NULL)` in `R/forms.R`
- `tally_submissions(form_id, filter, start_date, end_date, account = NULL)` in `R/submissions.R`
- `tally_whoami(account = NULL)` / internal `tally_user(account = NULL)` in `R/whoami.R`
- `tally_sitrep(account = NULL)` in `R/sitrep.R`

### Sitrep additions (`R/sitrep.R`)

New "Accounts" section before "API key": available accounts from `tally_accounts()`, and the active account (and whether it came from the `account` argument, `tally_use_account()`, or is the default). API key section then reports the *active* account's key status. Recommendations: if the active account's key is missing but others exist, suggest `tally_use_account()` with one of them. Returned list gains `accounts`.

### Tests

- `tests/testthat/test-accounts.R`: `tally_accounts()` finds/normalises names (`withr::local_envvar()` with several `TALLY_API_KEY_*`); `tally_use_account()` switches/clears/restores, snapshot of error for unknown account; precedence: `account` arg beats `tallyr.account` option beats default; active account ignores `tallyr.api_key` option.
- Extend `test-api-key.R` for `tally_api_key(account = )` and the env-var-specific abort message (snapshot).
- Update `helper.R` so `local_no_api_key()` / `local_fake_api_key()` also clear `tallyr.account` and any ambient `TALLY_API_KEY_*` vars (use `Sys.unsetenv` candidates via `withr::local_envvar(... = NA)` after scanning).
- Existing sitrep snapshots will change (new Accounts section) — review and accept.

## Part 2: README.Rmd workflow

- Create `README.Rmd` (usethis-style: `output: github_document`, chunk options block, badges placeholders) with the current README content plus a short "Multiple accounts" section. API-calling chunks use `eval = FALSE` (no key at build time), keeping the illustrative `#>` output inline as plain text.
- Add `^README\.Rmd$` to `.Rbuildignore`.
- Generate `README.md` with `devtools::build_readme()`; from now on only `README.Rmd` is edited.
- `devtools::build_readme()` needs `PKG_USE_BIOCONDUCTOR=FALSE` (Ella's workaround for a known bug since devtools 2.5.0). She has it set as an environment variable already (so it should be inherited via `.Renviron`/shell), but if `build_readme()` fails, set it explicitly for the call, e.g. `Sys.setenv(PKG_USE_BIOCONDUCTOR = "FALSE")` or `PKG_USE_BIOCONDUCTOR=FALSE Rscript -e 'devtools::build_readme()'`.
- Save cross-session memories: (1) README.Rmd is the source of truth; regenerate README.md with `devtools::build_readme()`; (2) the `PKG_USE_BIOCONDUCTOR=FALSE` workaround for `build_readme()`.
- If pandoc causes any issues when building the README (e.g. not found from `Rscript`, since RStudio's bundled pandoc isn't on the shell `PATH`), diagnose, fix (e.g. set `RSTUDIO_PANDOC` or point to a Homebrew pandoc), and **save the working fix as a persistent memory** so it doesn't reoccur in future sessions.

## Housekeeping

- roxygen updates for all touched functions; `devtools::document()` (new Rd files for `tally_use_account`, `tally_accounts`).

## Git commits

Commit at sensible points; immediately after **every** commit, run the bash command `cca` (Ella's alias that adds Claude Code as co-author — so do *not* add a Co-Authored-By trailer in the commit message itself). If `cca` isn't visible to the non-interactive shell, run it as `zsh -ic 'cca'`. Planned commit points:
1. The existing uncommitted package implementation (initial wrap of the Tally API).
2. Multi-account support (code + tests + docs).
3. README.Rmd workflow (README.Rmd, regenerated README.md, .Rbuildignore).

Also save a memory of this commit workflow preference (applies to future sessions).

## Verification

1. `devtools::document()`; `devtools::test()` — all pass, snapshots reviewed.
2. `devtools::check()` — 0 errors / 0 warnings / 0 notes.
3. `devtools::build_readme()` runs and regenerates `README.md`.
4. Live smoke test only if a real key is present (none in this environment): `tally_accounts()`, `tally_use_account()`, `tally_forms(account = )`.
