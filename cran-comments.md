## Resubmission

This is a resubmission. In this version I have:

* Replaced all `\dontrun{}` in examples per reviewer request:
  - Download functions (`get_bill_texts()`, `get_proposers()`): changed to
    `\donttest{}`.
  - Interactive/system-dependent functions (`open_tutorial()`,
    `run_tutorial()`, `set_ko_font()`): changed to `if (interactive()) {}`.

### Previous resubmission changes

* Removed all `rsconnect/` deployment metadata directories from `inst/`
  (and added to `.Rbuildignore`) to fix the non-portable file paths NOTE.
* Removed the `https://open.assembly.go.kr/` URL from DESCRIPTION,
  `@source` fields, and README to fix the invalid URL NOTE (the API root
  returns HTTP 400 to automated checkers). The source is still identified
  by name.
* Fixed invalid URL in `speeches` documentation: replaced the 404 GitHub
  link with a text reference to the Open National Assembly Information API.
* Removed all Korean (hangul) Unicode characters from Rd files to fix
  the LaTeX PDF manual generation error.
* Replaced ordinals in DESCRIPTION ("20th-22nd") with
  "assemblies 20 through 22" to avoid the misspelled-word NOTE.

## R CMD check results

0 errors | 0 warnings | 2 notes

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Kyusik Yang <kyusik.yang@nyu.edu>'
  New submission
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

## Downstream dependencies

None. This is a new package.
