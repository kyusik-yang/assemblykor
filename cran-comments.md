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

## URL notes

https://open.assembly.go.kr (Korean National Assembly Open Data API)
returns HTTP 400 to automated URL checkers but is accessible in a
browser. This is the official data source for five of the seven
datasets in this package.

## Test environments

* macOS (latest, R release) - GitHub Actions
* Windows (latest, R release) - GitHub Actions
* Ubuntu (latest, R release) - GitHub Actions
* Ubuntu (latest, R devel) - GitHub Actions
* Ubuntu (latest, R oldrel-1) - GitHub Actions

## Downstream dependencies

None. This is a new package.
