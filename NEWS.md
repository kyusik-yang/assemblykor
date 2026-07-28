# assemblykor 0.1.3

* New download function `get_speech_tokens()`: morpheme tokens for the
  `speeches` dataset, produced with the Kiwi morphological analyzer
  (kiwipiepy). Content morphemes only (NNG/NNP/VV/VA/MAG/SL), verbs and
  adjectives lemmatized, keyed by `date` + `speech_order`. Students can
  do proper Korean tokenization without installing a morphological
  analyzer. Tutorial 05 gains a section comparing whitespace
  tokenization against morphological analysis.
* The startup message now points to the GitHub repository for the
  latest data and fixes, since CRAN releases may lag behind.
* Fixed tutorial 04 (panel data): `etable()` was called with an `lm`
  object, which `fixest::etable()` does not accept. The pooled OLS model
  is now re-estimated with `feols()` (identical estimates) before the
  comparison table. Fixed in all three tutorial formats (plain Rmd,
  learnr, shinyapps).
* Fixed tutorial 05 (text analysis): `slice_sample(n = min(5000, n()))`
  errors under dplyr >= 1.1.0, which requires `n` to be a constant.
  Replaced with `slice_sample(n = 5000)`, which silently truncates when
  fewer rows are available (same behavior).
* `get_bill_texts()` and `get_proposers()` now download to a temporary
  file first and only move it into the cache on success. Previously, a
  failed or partial download left a corrupt file that later calls
  treated as a valid cache. Both functions now fail gracefully with a
  message (returning `NULL` invisibly) instead of an error when the
  resource is unavailable, and raise the download timeout to at least
  300 seconds.
* Documentation corrections: `wealth` covers 772 members over 10
  disclosure years (2015-2024), not 773 over 13 periods (2015-2025);
  `seminars` covers the 17th-22nd assemblies (2004-2025), not the
  16th-22nd (2000-2025), and its `camp` variable has five levels
  (including centrist); the package overview now lists all seven
  built-in datasets.

# assemblykor 0.1.2

* Fixed donttest example failure reported in CRAN 'Additional issues'.
  The remote parquet files served by `get_bill_texts()` and
  `get_proposers()` were re-encoded from ZSTD to GZIP compression so
  that CRAN's default arrow build (which does not include the ZSTD
  codec) can read them without error.
* Examples for `get_bill_texts()` and `get_proposers()` now write the
  cache file to `tempdir()` rather than the user cache directory, so
  R CMD check runs no longer leave files behind.

# assemblykor 0.1.1

* Replaced all `\dontrun{}` in examples per CRAN reviewer request:
  - `get_bill_texts()`, `get_proposers()`: changed to `\donttest{}` (download functions).
  - `open_tutorial()`, `run_tutorial()`, `set_ko_font()`: changed to
    `if (interactive()) {}` (interactive or system-dependent functions).

# assemblykor 0.1.0

* Initial CRAN release.
* Seven built-in datasets: `legislators`, `bills`, `wealth`, `seminars`,
  `speeches`, `votes`, `roll_calls`.
* Two download functions for larger datasets: `get_bill_texts()`,
  `get_proposers()`.
* Nine Korean-language interactive tutorials (learnr) and plain R Markdown
  versions covering tidyverse, visualization, regression, panel data, text
  analysis, network analysis, roll call analysis, bill success prediction,
  and speech pattern analysis.
* Utility functions: `set_ko_font()`, `path_to_file()`, `list_tutorials()`,
  `open_tutorial()`, `run_tutorial()`.
