# Changelog

## assemblykor 0.1.2

- Fixed donttest example failure reported in CRAN ‘Additional issues’.
  The remote parquet files served by
  [`get_bill_texts()`](https://kyusik-yang.github.io/assemblykor/reference/get_bill_texts.md)
  and
  [`get_proposers()`](https://kyusik-yang.github.io/assemblykor/reference/get_proposers.md)
  were re-encoded from ZSTD to GZIP compression so that CRAN’s default
  arrow build (which does not include the ZSTD codec) can read them
  without error.
- Examples for
  [`get_bill_texts()`](https://kyusik-yang.github.io/assemblykor/reference/get_bill_texts.md)
  and
  [`get_proposers()`](https://kyusik-yang.github.io/assemblykor/reference/get_proposers.md)
  now write the cache file to
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) rather than the
  user cache directory, so R CMD check runs no longer leave files
  behind.

## assemblykor 0.1.1

CRAN release: 2026-04-07

- Replaced all `\dontrun{}` in examples per CRAN reviewer request:
  - [`get_bill_texts()`](https://kyusik-yang.github.io/assemblykor/reference/get_bill_texts.md),
    [`get_proposers()`](https://kyusik-yang.github.io/assemblykor/reference/get_proposers.md):
    changed to `\donttest{}` (download functions).
  - [`open_tutorial()`](https://kyusik-yang.github.io/assemblykor/reference/open_tutorial.md),
    [`run_tutorial()`](https://kyusik-yang.github.io/assemblykor/reference/run_tutorial.md),
    [`set_ko_font()`](https://kyusik-yang.github.io/assemblykor/reference/set_ko_font.md):
    changed to `if (interactive()) {}` (interactive or system-dependent
    functions).

## assemblykor 0.1.0

- Initial CRAN release.
- Seven built-in datasets: `legislators`, `bills`, `wealth`, `seminars`,
  `speeches`, `votes`, `roll_calls`.
- Two download functions for larger datasets:
  [`get_bill_texts()`](https://kyusik-yang.github.io/assemblykor/reference/get_bill_texts.md),
  [`get_proposers()`](https://kyusik-yang.github.io/assemblykor/reference/get_proposers.md).
- Nine Korean-language interactive tutorials (learnr) and plain R
  Markdown versions covering tidyverse, visualization, regression, panel
  data, text analysis, network analysis, roll call analysis, bill
  success prediction, and speech pattern analysis.
- Utility functions:
  [`set_ko_font()`](https://kyusik-yang.github.io/assemblykor/reference/set_ko_font.md),
  [`path_to_file()`](https://kyusik-yang.github.io/assemblykor/reference/path_to_file.md),
  [`list_tutorials()`](https://kyusik-yang.github.io/assemblykor/reference/list_tutorials.md),
  [`open_tutorial()`](https://kyusik-yang.github.io/assemblykor/reference/open_tutorial.md),
  [`run_tutorial()`](https://kyusik-yang.github.io/assemblykor/reference/run_tutorial.md).
