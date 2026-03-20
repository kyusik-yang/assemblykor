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
if (FALSE) { # \dontrun{
props <- get_proposers()

# Build co-sponsorship edgelist
library(dplyr)
leads <- props %>% filter(is_lead) %>% select(bill_id, lead = member_id)
cosponsors <- props %>% filter(!is_lead) %>% select(bill_id, cosponsor = member_id)
edges <- inner_join(leads, cosponsors, by = "bill_id")
} # }
```
