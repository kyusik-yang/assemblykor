# Download bill propose-reason texts

Downloads the full propose-reason texts (jean-iyu) for all 64,900 bills
in
[`bills`](https://kyusik-yang.github.io/assemblykor/reference/bills.md).
The file is approximately 26 MB and is cached locally after the first
download. Requires the arrow package to read parquet files.

## Usage

``` r
get_bill_texts(cache_dir = NULL, force_download = FALSE)
```

## Arguments

- cache_dir:

  Directory to cache downloaded files. Defaults to
  `tools::R_user_dir("assemblykor", "cache")`.

- force_download:

  Logical. If `TRUE`, re-download even if cached.

## Value

A data frame with 64,900 rows and 4 variables, or `NULL` (invisibly) if
the download fails (e.g., no internet connection):

- bill_id:

  Bill identifier (links to `bills$bill_id`)

- propose_reason:

  Full text of the propose-reason statement (Korean). `NA` for the 80
  bills that have no text in the source.

- scrape_status:

  Status of the web collection of the text: "ok", "empty", "no_csrf", or
  "error". `NA` for texts from the API.

- source:

  "likms_scrape" for the texts collected from the Legislative
  Information System (bills proposed by 2026-02-27), or "BPMBILLSUMMARY"
  for the texts of the Open Assembly API, which begin with a heading
  that the scraped texts lack. `NA` for the eight bills without any text
  record.

## Details

The texts are those of release 0.8.1 of the kna project
(<https://github.com/kyusik-yang/kna>), for the bills in
[`bills`](https://kyusik-yang.github.io/assemblykor/reference/bills.md).
Versions up to 0.1.3 downloaded the scraped texts of the
korean-assembly-bills dataset, which cover the bills proposed by
2026-02-27 and are unchanged here. Record `source` in text analyses.

## Examples

``` r
# \donttest{
if (requireNamespace("arrow", quietly = TRUE)) {
  texts <- get_bill_texts(cache_dir = tempdir())

  if (!is.null(texts)) {
    nchar_dist <- nchar(texts$propose_reason)
    hist(nchar_dist, breaks = 100, main = "Length of Propose-Reason Texts")
  }
}
#> Downloading bill texts (~26 MB)...
#> Cached at: /tmp/Rtmpy0nnMp/bill_texts_v2.parquet

# }
```
