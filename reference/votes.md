# Plenary Vote Results in the Korean National Assembly (20th-22nd)

Bill-level vote tallies from plenary sessions of the 20th through 22nd
Korean National Assembly (2016-2026). Each row represents one bill that
went to a recorded floor vote.

## Usage

``` r
votes
```

## Format

A data frame with 8,050 rows and 13 variables:

- bill_id:

  Unique bill identifier (links to `bills$bill_id`)

- bill_no:

  Numeric bill number

- bill_name:

  Full bill title in Korean

- assembly:

  Assembly number (20, 21, or 22)

- committee:

  Standing committee to which the bill was referred

- vote_date:

  Date of the plenary vote

- result:

  Vote outcome in Korean (e.g., passed as-is, passed with amendments,
  rejected)

- bill_type:

  Type of bill (e.g., legislation, budget, resolution)

- total_members:

  Total number of assembly members at the time

- voted:

  Number of members who cast a vote

- yes:

  Number of yes votes

- no:

  Number of no votes

- abstain:

  Number of abstentions

## Source

Open National Assembly Information API (Republic of Korea), endpoint
`ncocpgfiaoituanbr`.

## Details

Not all bills go to a floor vote. Most bills are disposed of in
committee or expire at the end of the assembly term. The `votes` dataset
captures only those that reached the plenary floor for a recorded vote.

About 40\\ because `bills` only contains legislator-proposed bills while
`votes` also includes committee alternatives, budget bills, and
resolutions that have separate identifiers.

See
[`roll_calls`](https://kyusik-yang.github.io/assemblykor/reference/roll_calls.md)
for member-level voting records (22nd assembly), useful for ideal point
estimation or party discipline analysis.

## Examples

``` r
data(votes)

# Votes per assembly
table(votes$assembly)
#> 
#>   20   21   22 
#> 3492 3272 1286 

# Pass rate
table(votes$result)
#> 
#>     부결 수정가결 원안가결 
#>       26     2688     5336 

# Average yes rate
votes$yes_rate <- votes$yes / votes$voted
summary(votes$yes_rate)
#>     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#> 0.006369 0.961690 0.983784 0.961513 0.994143 1.000000 

# Contentious votes (yes rate < 70%)
contentious <- votes[votes$yes / votes$voted < 0.7, ]
nrow(contentious)
#> [1] 144
```
