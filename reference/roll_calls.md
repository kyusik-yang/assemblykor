# Member-Level Roll Call Votes (22nd Assembly)

Individual legislator voting records for all 1,286 bills that went to a
recorded plenary vote in the 22nd Korean National Assembly from July
2024 to March 12, 2026. Each row represents one legislator's vote on one
bill.

## Usage

``` r
roll_calls
```

## Format

A data frame with 383,792 rows and 9 variables:

- bill_id:

  Bill identifier (links to `votes$bill_id` and `bills$bill_id`)

- assembly:

  Assembly number (22)

- member_name:

  Legislator name in Korean

- member_id:

  Legislator identifier (MONA_CD, links to `legislators$member_id`)

- party:

  Party label reported by the API at data collection (March 2026). The
  API writes the member's party at that time onto every past vote, so a
  member who changed party during the term appears under the later party
  on all votes.

- party_elected:

  Party at election, as in `legislators$party_elected`. Members elected
  on the lists of the satellite parties (e.g., the People Future Party
  and the Democratic Alliance of Korea) carry the list party, although
  they sat with other parties. Two members who succeeded to proportional
  seats during the term carry the Democratic Party of Korea, the party
  into which the Democratic Alliance of Korea had merged (see
  [`legislators`](https://kyusik-yang.github.io/assemblykor/reference/legislators.md)).

- district:

  Electoral district or proportional list position

- vote:

  Vote cast in Korean: one of four values meaning yes, no, abstain, or
  absent

- vote_date:

  Date of the vote

## Source

Open National Assembly Information API (Republic of Korea), endpoint
`nojepdqqaweusdfbi`, with the corrections of kna 0.7.0.

## Details

This dataset covers the 22nd assembly. The same API endpoint also has
member-level votes of the 20th and 21st assemblies, which are left out
to keep the package small. Release 0.7.0 of the kna project
(<https://github.com/kyusik-yang/kna>) provides them. For the 20th and
21st assemblies, use the bill-level
[`votes`](https://kyusik-yang.github.io/assemblykor/reference/votes.md)
dataset.

Neither party column records the party at the time of each vote. Up to
version 0.1.3, `party` was documented as the party at the time of the
vote. Version 0.1.4 corrects that description, adds `party_elected`, and
restores 53 votes cast on 2026-03-12 by a member who had just taken up a
vacant proportional seat, which the March 2026 collection missed.

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
#>   4889   6827  87881 284195 

# Votes per party
head(sort(table(roll_calls$party), decreasing = TRUE))
#> 
#> 더불어민주당     국민의힘   조국혁신당       무소속       진보당     개혁신당 
#>       213046       137372        15430         7043         4471         3858 

# Number of unique legislators
length(unique(roll_calls$member_id))
#> [1] 305
```
