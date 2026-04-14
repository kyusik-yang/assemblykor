## Resubmission (v0.1.2)

This resubmission addresses the donttest failure reported in the CRAN
'Additional issues' check for v0.1.1:

> Error: NotImplemented: Support for codec 'zstd' not built

The remote parquet files served by `get_bill_texts()` and
`get_proposers()` were re-encoded from ZSTD to GZIP compression, which
is supported by every arrow build. The `\donttest{}` examples now run
without error on the CRAN donttest checker.

Additional changes in v0.1.2:

* Examples for both download functions pass `cache_dir = tempdir()` so
  that R CMD check runs no longer leave cache files in the user's home
  directory.
* File size descriptions in the Rd docs and `message()` calls updated
  to match the actual GZIP-compressed file sizes.

### Previous resubmission history (v0.1.1)

* Replaced all `\dontrun{}` in examples per reviewer request:
  - Download functions: `\donttest{}`.
  - Interactive/system-dependent functions: `if (interactive()) {}`.
* Removed `rsconnect/` deployment metadata from `inst/`.
* Removed the `https://open.assembly.go.kr/` URL from DESCRIPTION.
* Removed Korean Unicode from Rd files (LaTeX manual generation).
* Replaced ordinals in DESCRIPTION with "assemblies 20 through 22".

## R CMD check results

0 errors | 0 warnings | 2 notes

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Kyusik Yang <kyusik.yang@nyu.edu>'
  Possibly misspelled words in DESCRIPTION:
    Rosenthal (13:28)

  "Rosenthal" is a proper name (Poole and Rosenthal, 1985), referring to
  the spatial voting model paper cited in the DESCRIPTION.

* checking installed package size ... NOTE
    installed size is 6.9Mb
    sub-directories of 1Mb or more:
      data    4.6Mb
      extdata 1.1Mb

  This is a data package (similar to palmerpenguins) providing seven
  curated datasets from the Korean National Assembly for teaching
  quantitative methods in political science. The data size is necessary
  to provide meaningful real-world datasets for classroom exercises
  spanning regression, panel data, text analysis, and network analysis.

## Test environments

* macOS (latest, R release) - GitHub Actions
* Windows (latest, R release) - GitHub Actions
* Ubuntu (latest, R release) - GitHub Actions
* Ubuntu (latest, R devel) - GitHub Actions
* Ubuntu (latest, R oldrel-1) - GitHub Actions
* local macOS (R 4.4.1): R CMD check --as-cran --run-donttest

## Downstream dependencies

None.
