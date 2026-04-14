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
