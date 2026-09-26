# Update (v0.1.4)

This is a data-correction update. Changes:

* Corrected values in the built-in datasets (legislator seniority and
  committees, results of vetoed bills, identifiers in `speeches`,
  member attributes in `seminars`), following errata in the upstream
  data source. Three datasets gain columns, and 48 duplicated rows of
  `speeches` were dropped. Details are in NEWS.md.
* `get_proposers()` now downloads a corrected file hosted in the package's
  GitHub repository. It still fails gracefully, returning NULL with a
  message, when the resource is unavailable.

## R CMD check results

0 errors | 0 warnings | 2 notes

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Kyusik Yang <kyusik.yang@nyu.edu>'

* checking installed package size ... NOTE
    installed size is 7.5Mb
    sub-directories of 1Mb or more:
      data    4.8Mb
      extdata 1.2Mb

  This is a data package (similar to palmerpenguins) providing seven
  curated datasets from the Korean National Assembly for teaching
  quantitative methods in political science. The data size is necessary
  to provide meaningful real-world datasets for classroom exercises
  spanning regression, panel data, text analysis, and network analysis.
  The data grew by about 0.2 MB in this release (new columns).

## Test environments

* macOS (latest, R release) - GitHub Actions
* Windows (latest, R release) - GitHub Actions
* Ubuntu (latest, R release) - GitHub Actions
* Ubuntu (latest, R devel) - GitHub Actions
* Ubuntu (latest, R oldrel-1) - GitHub Actions
* local macOS: R CMD check --as-cran --run-donttest

## Downstream dependencies

None.
