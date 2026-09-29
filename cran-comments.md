# Update (v0.1.4)

This update corrects and extends the built-in data. Changes:

* Corrected values in the built-in datasets (legislator seniority and
  committees, results of vetoed bills, identifiers in `speeches`,
  member attributes in `seminars`, votes missing from `roll_calls`),
  following errata in the upstream data source. Three datasets gain
  columns, and 48 duplicated rows of `speeches` were dropped.
* The data of the current (22nd) National Assembly now run to September
  2026 instead of March 2026, and the asset declarations add the year
  2025. Details are in NEWS.md.
* `get_proposers()` and `get_bill_texts()` download files hosted in the
  package's GitHub repository. They still fail gracefully, returning NULL
  with a message, when the resource is unavailable, and the examples
  check for NULL.

## R CMD check results

0 errors | 0 warnings | 2 notes

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Kyusik Yang <kyusik.yang@nyu.edu>'

  Size of tarball: about 5.7 MB

  The tarball size has the same cause as the installed size NOTE below.

* checking installed package size ... NOTE
    installed size is 8.0Mb
    sub-directories of 1Mb or more:
      data    5.4Mb
      extdata 1.2Mb

  This is a data package (similar to palmerpenguins) providing seven
  curated datasets from the Korean National Assembly for teaching
  quantitative methods in political science. The data size is necessary
  to provide meaningful real-world datasets for classroom exercises
  spanning regression, panel data, text analysis, and network analysis.
  The data grew by about 0.6 MB in this release, because the records of
  the sitting Assembly were extended by six months. The data are saved
  with xz compression (LazyDataCompression: xz), and larger resources
  (bill texts, co-sponsorship records, morpheme tokens) are downloaded on
  demand instead of being shipped.

## Test environments

* macOS (latest, R release) - GitHub Actions
* Windows (latest, R release) - GitHub Actions
* Ubuntu (latest, R release) - GitHub Actions
* Ubuntu (latest, R devel) - GitHub Actions
* Ubuntu (latest, R oldrel-1) - GitHub Actions
* local macOS: R CMD check --as-cran --run-donttest

## Downstream dependencies

None.
