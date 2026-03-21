## Resubmission

This is a resubmission. In this version I have:

* Removed all Korean (hangul) Unicode characters from Rd files to fix
  the LaTeX PDF manual generation error.
* Replaced ordinals in DESCRIPTION ("20th-22nd") with
  "assemblies 20 through 22" to avoid the misspelled-word NOTE.
* Removed `\url{https://open.assembly.go.kr}` from `@source` fields
  (the API root returns HTTP 400 to automated checkers).

## R CMD check results

0 errors | 0 warnings | 2 notes

* checking package dependencies ... NOTE
  Package suggested but not available for checking: 'arrow'

  arrow is an optional dependency used only by two download functions
  (`get_bill_texts()`, `get_proposers()`). Both functions check for
  arrow with `requireNamespace()` and provide an informative error
  message if it is not installed.

* checking installed package size ... NOTE
    installed size is 6.6Mb
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

## Downstream dependencies

None. This is a new package.
