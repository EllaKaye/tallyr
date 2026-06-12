# Plan: Vignettes for tallyr

## Context

tallyr (an R interface to the Tally form-builder API) has a README, full roxygen docs, and tests, but no vignettes. The goal is a "Get Started" vignette (`vignettes/tallyr.Rmd`) plus three deeper articles, cross-linked using pkgdown's auto-linking conventions (https://pkgdown.r-lib.org/articles/linking.html), so the pkgdown site (already configured in `_pkgdown.yml`) gains a proper articles section.

Key constraint: vignettes cannot call the live Tally API at build time (no key on CI/CRAN). The README (`README.Rmd`) already establishes the house style: `eval = FALSE` chunks with hand-written `#>` output. All vignettes follow that pattern. Realistic fake output can be modelled on the README examples and the test fixtures (`tests/testthat/fixtures/forms.json`, `submissions.json`).

## Infrastructure changes

1. **DESCRIPTION**: add `knitr` and `rmarkdown` to `Suggests`, add `VignetteBuilder: knitr` (this is what `usethis::use_vignette()` does; I'll make the edits directly).
2. **`.gitignore`**: add `inst/doc`; create `vignettes/.gitignore` with `*.html` and `*.R`.
3. **`_pkgdown.yml`**: add an `articles:` index ordering the three non-Get-Started articles (pkgdown treats `vignettes/tallyr.Rmd` as the navbar "Get started" link automatically because it matches the package name).
4. **Plan copy**: per global instructions, copy this plan to `plans/2026-06-12-vignettes.md` in the project and add `^plans$` to `.Rbuildignore`.

## Vignettes (4 files in `vignettes/`)

All use the standard `rmarkdown::html_vignette` YAML header with `%\VignetteIndexEntry`, a setup chunk matching README (`collapse = TRUE, comment = "#>"`), `library(tallyr)` early, and `eval = FALSE` on all API-calling chunks with hand-written `#>` output.

### 1. `tallyr.Rmd` — "Get started with tallyr"

- Installation (`pak::pak("EllaKaye/tallyr")`).
- Authentication: create key at Tally Settings > API keys, store as `TALLY_API_KEY` in `.Renviron` via `usethis::edit_r_environ()`; verify with `tally_whoami()`.
- List forms with `tally_forms()` (show the tibble, explain the columns, note you can also pass a form's Tally URL to `tally_submissions()`).
- Import submissions with `tally_submissions()`: one row per submission, one column per question; `filter = "completed"`, `start_date`/`end_date` examples.
- Brief notes: pagination is automatic; 100 req/min rate limit respected.
- Closing "Where next" section linking the other three vignettes via `vignette("multiple-accounts")`, `vignette("submission-data")`, `vignette("troubleshooting")` — pkgdown auto-links these. Function names in backticks with parens (e.g. `tally_forms()`) for reference auto-linking throughout.

### 2. `multiple-accounts.Rmd` — "Managing multiple Tally accounts"

- Motivation (personal vs work vs community accounts).
- Named keys: `TALLY_API_KEY_<NAME>` env vars; `tally_accounts()` to list them.
- Session switching with `tally_use_account()`, including restoring the previous account from its invisible return value.
- One-off `account` argument on every API function.
- Precedence rules: explicit `account` arg > `tallyr.account` option (set by `tally_use_account()`) > default; named accounts use only their env var (the `tallyr.api_key` option applies to the default account only).
- Checking a specific account: `tally_whoami(account = "work")`, `tally_sitrep(account = "work")`.

### 3. `submission-data.Rmd` — "Working with submission data"

- Anatomy of the returned tibble: `submission_id`, `submitted_at` (POSIXct, UTC), `is_completed`, then one column per question.
- Column names come from question titles; duplicate titles are repaired to be unique (show example).
- Answers use the API's formatted answer where available, falling back to the raw answer; unanswered questions are `NA`.
- Practical tidying patterns: renaming long question-title columns (`dplyr::rename()`), date handling/timezone conversion, counting/summarising responses. Keep dplyr/tidyr usage in `eval = FALSE` chunks so they don't need to be Suggests dependencies — or present base-R alternatives where natural.
- Filtering at import time (`filter`, `start_date`, `end_date`) vs filtering after import.

### 4. `troubleshooting.Rmd` — "Troubleshooting your Tally setup"

- `tally_sitrep()` as the never-erroring diagnostic; walk through what it reports (accounts found, key source, key format, connectivity, authentication).
- Scenario walkthroughs with mocked output, drawing on the snapshot tests (`tests/testthat/_snaps/`) for accurate message text: no key found; key found but malformed (no `tly-` prefix); offline; key rejected by the API (401).
- Fixes for each: editing `.Renviron`, restarting R after edits, regenerating keys.
- `tally_whoami()` as the quick check; where the key is looked up (option > env var; named accounts env-var only).

## Commits

Three commits, each followed by `zsh -ic 'cca'`:

1. Vignette infrastructure (DESCRIPTION, .gitignores, `_pkgdown.yml`, plans/ copy + `.Rbuildignore`).
2. Get Started vignette (`tallyr.Rmd`).
3. The three further vignettes.

## Verification

- `Rscript -e 'devtools::build_vignettes()'` with env vars from memory (`PKG_USE_BIOCONDUCTOR=FALSE`, `RSTUDIO_PANDOC=/Applications/quarto/bin/tools/aarch64`) to confirm all four knit cleanly.
- `Rscript -e 'devtools::check(vignettes = TRUE)'` (or at minimum `check_man` + vignette build) to confirm metadata (VignetteBuilder, Suggests) is right.
- `Rscript -e 'pkgdown::build_articles(preview = FALSE)'` to confirm pkgdown renders the articles and that `vignette("...")` and `tally_*()` references auto-link (inspect generated HTML for `<a href=` around the cross-references).
