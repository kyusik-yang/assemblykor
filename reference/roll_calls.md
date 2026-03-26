# Member-Level Roll Call Votes (22nd Assembly)

Individual legislator voting records for all 1,233 bills that went to a
recorded plenary vote in the 22nd Korean National Assembly (2024-2026).
Each row represents one legislator's vote on one bill.

## Usage

``` r
roll_calls
```

## Format

A data frame with 368,210 rows and 8 variables:

- bill_id:

  Bill identifier (links to `votes$bill_id` and `bills$bill_id`)

- assembly:

  Assembly number (22)

- member_name:

  Legislator name in Korean

- member_id:

  Legislator identifier (MONA_CD, links to `legislators$member_id`)

- party:

  Party affiliation at time of vote

- district:

  Electoral district or proportional list position

- vote:

  Vote cast in Korean: one of four values meaning yes, no, abstain, or
  absent

- vote_date:

  Date of the vote

## Source

Open National Assembly Information API (Republic of Korea), endpoint
`nojepdqqaweusdfbi`.

## Details

The member-level roll call API is only available for the 22nd assembly.
For the 20th and 21st assemblies, use the bill-level
[`votes`](https://kyusik-yang.github.io/assemblykor/reference/votes.md)
dataset.

This dataset enables ideal point estimation (e.g., W-NOMINATE), party
unity scores, and analysis of legislative coalitions. Use `member_id` to
link with `legislators` for biographical metadata.

## See also

[`votes`](https://kyusik-yang.github.io/assemblykor/reference/votes.md)

## Examples

``` r
data(roll_calls)

# Vote distribution
table(roll_calls$vote)
#> 
#>   기권   반대   불참   찬성 
#>   4886   6827  87877 284149 

# Votes per party
head(sort(table(roll_calls$party), decreasing = TRUE))
#> 
#> 더불어민주당     국민의힘   조국혁신당       무소속       진보당     개혁신당 
#>       212993       137372        15430         7043         4471         3858 

# Number of unique legislators
length(unique(roll_calls$member_id))
#> [1] 304
```
