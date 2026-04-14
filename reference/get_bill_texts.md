# Download bill propose-reason texts

Downloads the full propose-reason texts (jean-iyu) for all 60,925 bills.
The file is approximately 25 MB and is cached locally after the first
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

A data frame with 60,925 rows and 3 variables:

- bill_id:

  Bill identifier (links to `bills$bill_id`)

- propose_reason:

  Full text of the propose-reason statement (Korean)

- scrape_status:

  Data collection status: "ok", "empty", "no_csrf", or "error"

## Examples

``` r
# \donttest{
if (requireNamespace("arrow", quietly = TRUE)) {
  texts <- get_bill_texts(cache_dir = tempdir())
  nchar_dist <- nchar(texts$propose_reason)
  hist(nchar_dist, breaks = 100, main = "Length of Propose-Reason Texts")
}
#> Downloading bill texts (~25 MB)...
#> Cached at: /tmp/RtmpRoItx8/bill_texts.parquet

# }
```
