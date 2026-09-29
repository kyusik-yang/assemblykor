# Member-Level Roll Call Votes (22nd Assembly)

Individual legislator voting records for all 1,847 bills that went to a
recorded plenary vote in the 22nd Korean National Assembly from July
2024 to September 17, 2026. Each row represents one legislator's vote on
one bill.

## Usage

``` r
roll_calls
```

## Format

A data frame with 549,513 rows and 9 variables:

- bill_id:

  Bill identifier (links to `votes$bill_id` and `bills$bill_id`)

- assembly:

  Assembly number (22)

- member_name:

  Legislator name in Korean

- member_id:

  Legislator identifier (MONA_CD, links to `legislators$member_id`)

- party:

  Party label reported by the API at data collection (September 2026).
  The API writes the member's party at that time onto every past vote,
  so a member who changed party during the term appears under the later
  party on all votes. For the votes taken from the LIKMS vote pages (see
  Source) it is the member's party in September 2026.

- party_elected:

  Party at election, as in `legislators$party_elected`. Members elected
  on the lists of the satellite parties (e.g., the People Future Party
  and the Democratic Alliance of Korea) carry the list party, although
  they sat with other parties. Three members who succeeded to
  proportional seats during the term carry the party into which the list
  party had merged, two the Democratic Party of Korea and one the People
  Power Party (see
  [`legislators`](https://kyusik-yang.github.io/assemblykor/reference/legislators.md)).

- district:

  Electoral district at the 2024 election, or the proportional list, as
  in `legislators$district`

- vote:

  Vote cast in Korean: one of four values meaning yes, no, abstain, or
  absent

- vote_date:

  Date of the vote

## Source

Open National Assembly Information API (Republic of Korea), endpoint
`nojepdqqaweusdfbi`, as collected by release 0.8.1 of the kna project
(<https://github.com/kyusik-yang/kna>) in September 2026. The votes of
the 16 members the API omits come from the vote pages of the Legislative
Information System (LIKMS), as in kna 0.8.0.

## Details

This dataset covers the 22nd assembly. The same API endpoint also has
member-level votes of the 20th and 21st assemblies, which are left out
to keep the package small. The kna project
(<https://github.com/kyusik-yang/kna>) provides them. For the 20th and
21st assemblies, use the bill-level
[`votes`](https://kyusik-yang.github.io/assemblykor/reference/votes.md)
dataset.

Neither party column records the party at the time of each vote. Up to
version 0.1.3, `party` was documented as the party at the time of the
vote. Version 0.1.4 corrects that description, adds `party_elected`, and
rebuilds the dataset from release 0.8.1 of the kna project, which adds
the votes of the 16 members seated in 2026 that the API omits. Every
member seated at a vote has a row for it, absent if the member did not
vote.

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
#>   6432   9919 141823 391339 

# Votes per party
head(sort(table(roll_calls$party), decreasing = TRUE))
#> 
#> 더불어민주당     국민의힘   조국혁신당       무소속       진보당     개혁신당 
#>       300844       198049        22162        12508         6715         5541 

# Number of unique legislators
length(unique(roll_calls$member_id))
#> [1] 321
```
