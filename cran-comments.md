# Update (v0.1.3)

This is a maintenance and feature update. Changes:

* New download function `get_speech_tokens()`: pre-tokenized morphemes
  for the `speeches` dataset (665,055 rows, ~1.3 MB download), produced
  with the Kiwi morphological analyzer. Served remotely and cached, so
  the installed package size is unchanged.
* Both existing download functions now download to a temporary file and
  move it into the cache only on success, so a failed or partial
  download no longer leaves a corrupt cached file. On network failure
  they return NULL invisibly with an informative message instead of
  erroring, per CRAN policy on unavailable internet resources.
* Fixed two bugs in the bundled tutorials (an `etable()` call that
  received an `lm` object, and a `slice_sample()` idiom that errors
  under dplyr >= 1.1.0).
* Documentation corrections (dataset coverage years and counts) and a
  new tutorial section on morphological analysis.

## R CMD check results

0 errors | 0 warnings | 2 notes

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Kyusik Yang <kyusik.yang@nyu.edu>'

* checking installed package size ... NOTE
    installed size is 7.2Mb
    sub-directories of 1Mb or more:
      data    4.6Mb
      extdata 1.1Mb

  This is a data package (similar to palmerpenguins) providing seven
  curated datasets from the Korean National Assembly for teaching
  quantitative methods in political science. The data size is necessary
  to provide meaningful real-world datasets for classroom exercises
  spanning regression, panel data, text analysis, and network analysis.
  No data was added in this release.

## Test environments

* macOS (latest, R release) - GitHub Actions
* Windows (latest, R release) - GitHub Actions
* Ubuntu (latest, R release) - GitHub Actions
* Ubuntu (latest, R devel) - GitHub Actions
* Ubuntu (latest, R oldrel-1) - GitHub Actions
* local macOS: R CMD check --as-cran --run-donttest

## Downstream dependencies

None.
