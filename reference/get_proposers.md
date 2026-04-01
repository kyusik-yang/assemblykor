# Download bill co-sponsorship records

Downloads the complete proposer records (769,773 rows) listing every
legislator who co-sponsored each bill. Requires the arrow package.

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

A data frame with 769,773 rows and 8 variables:

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

  Party affiliation at the time of co-sponsorship

- member_id:

  Legislator identifier (links to `legislators$member_id`)

- is_lead:

  Logical: `TRUE` if lead (primary) proposer, `FALSE` if co-sponsor

## Examples

``` r
# \donttest{
props <- get_proposers()
#> Downloading proposer records (~25 MB)...
#> Cached at: /home/runner/.cache/R/assemblykor/proposers.parquet

# Build co-sponsorship edgelist
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
leads <- props %>% filter(is_lead) %>% select(bill_id, lead = member_id)
cosponsors <- props %>% filter(!is_lead) %>% select(bill_id, cosponsor = member_id)
edges <- inner_join(leads, cosponsors, by = "bill_id")
#> Warning: Detected an unexpected many-to-many relationship between `x` and `y`.
#> ℹ Row 1 of `x` matches multiple rows in `y`.
#> ℹ Row 246619 of `y` matches multiple rows in `x`.
#> ℹ If a many-to-many relationship is expected, set `relationship =
#>   "many-to-many"` to silence this warning.
# }
```
