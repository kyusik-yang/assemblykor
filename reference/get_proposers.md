# Download bill co-sponsorship records

Downloads the complete proposer records (825,283 rows) listing every
legislator who proposed, co-proposed or supported each of the 64,900
bills in
[`bills`](https://kyusik-yang.github.io/assemblykor/reference/bills.md).
Requires the arrow package.

## Usage

``` r
get_proposers(cache_dir = NULL, force_download = FALSE)
```

## Arguments

- cache_dir:

  Directory to cache downloaded files. Defaults to
  `tools::R_user_dir("assemblykor", "cache")`.

- force_download:

  Logical. If `TRUE`, re-download even if cached.

## Value

A data frame with 825,283 rows and 9 variables, or `NULL` (invisibly) if
the download fails (e.g., no internet connection):

- bill_id:

  Bill identifier (links to `bills$bill_id`)

- bill_no:

  Numeric bill number

- bill_name:

  Bill title in Korean

- propose_date:

  Proposal date

- proposer_name:

  Legislator name

- proposer_party:

  Party affiliation at the time of proposal

- member_id:

  Legislator identifier (links to `legislators$member_id`)

- is_lead:

  Logical: `TRUE` if lead (primary) proposer, `FALSE` if co-proposer or
  supporter (see `role`)

- role:

  Role on the bill in Korean, one of lead proposer (daepyo balui),
  co-proposer (gongdong balui) or supporter (chanseong). Supporters are
  the members counted in the "oe M in" part of the proposer text.

## Details

The records come from the official proposer list of each bill
(BILLINFOPPSR endpoint), as rebuilt in the kna project
(<https://github.com/kyusik-yang/kna>), release 0.8.1. Releases up to
0.1.3 of this package served an earlier file that stopped at 100 names
per bill, which left out 7,447 records of the 208 bills with more than
100 proposers and supporters, and whose `is_lead` was `FALSE` for the
lead proposer of 36 single-proposer bills. Bills with joint lead
proposers have more than one row with `is_lead = TRUE`.

## Examples

``` r
# \donttest{
if (requireNamespace("arrow", quietly = TRUE) &&
    requireNamespace("dplyr", quietly = TRUE)) {
  props <- get_proposers(cache_dir = tempdir())

  if (!is.null(props)) {
    # Build co-sponsorship edgelist
    leads <- dplyr::select(
      dplyr::filter(props, is_lead), bill_id, lead = member_id
    )
    cosponsors <- dplyr::select(
      dplyr::filter(props, !is_lead), bill_id, cosponsor = member_id
    )
    edges <- dplyr::inner_join(
      leads, cosponsors,
      by = "bill_id", relationship = "many-to-many"
    )
  }
}
#> Downloading proposer records (~3.6 MB)...
#> Cached at: /tmp/Rtmp7MNR73/proposers_v2.parquet
# }
```
