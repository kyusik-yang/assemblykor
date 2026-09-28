# Policy Seminar Activity by Legislator-Year (2004-2025)

Annual panel of policy seminar hosting activity for legislators in the
17th through 22nd Korean National Assembly. Policy seminars (jeongchaek
semina) are informal legislative events where MPs invite experts,
stakeholders, and colleagues from other parties to discuss policy
issues.

## Usage

``` r
seminars
```

## Format

A data frame with 5,962 rows and 18 variables:

- name:

  Legislator name in Korean

- member_id:

  Legislator identifier (MONA_CD, links to `legislators$member_id`).
  Available for 5,696 rows (95.5\\ and `NA` for unmatched or ambiguous
  (homonym) cases.

- year:

  Calendar year

- assembly:

  Assembly number (17-22), assigned from the calendar year (2004-2007 to
  the 17th, 2008-2011 to the 18th, and so on)

- party:

  Party affiliation

- camp:

  Political camp: "liberal", "conservative", "progressive", "centrist",
  or "other" (values are in Korean)

- seniority:

  Seniority at that assembly, that is, the number of terms served up to
  and including this one, counting terms before the 17th (1 =
  first-term)

- n_seminars:

  Number of policy seminars hosted that year

- n_cross_party:

  Number of seminars co-hosted with other-party legislators

- cross_party_ratio:

  Share of seminars that were cross-party (0-1)

- avg_coalition_size:

  Average number of co-hosts per seminar

- is_governing:

  Logical: belongs to the governing (presidential) party

- is_female:

  Logical: female legislator

- is_proportional:

  Logical: holds a proportional-representation seat in that assembly

- is_seoul:

  Logical: represents a Seoul district in that assembly

- province:

  Province or metropolitan city of the electoral district in that
  assembly, in Korean short form (e.g., Seoul, Gyeonggi). `NA` for
  proportional-representation members.

- total_terms:

  Total assembly terms served across the career, as of September 2026

- n_bills_led:

  Number of bills the legislator proposed as lead proposer in that
  assembly term (the same value in every year of the term)

## Source

National Assembly Seminar Database, collected via API. Member attributes
from kna 0.7.0 (<https://github.com/kyusik-yang/kna>).

## Details

Policy seminars are a distinctive feature of the Korean National
Assembly. Unlike floor speeches or committee hearings, seminars are
voluntary and allow legislators to signal policy expertise and build
cross-party ties. The `cross_party_ratio` variable captures how often a
legislator cooperates across party lines in this informal arena.

The `is_governing` variable enables difference-in-differences designs:
when a party transitions from opposition to governing (or vice versa),
does its members' cross-party collaboration change?

The member attributes `seniority`, `total_terms`, `is_female`,
`is_proportional`, `is_seoul` and `province` come from the member
records of release 0.7.0 of the kna project, matched on `member_id` and
`assembly`. Up to version 0.1.3 they were matched on the name alone and
counted only the terms from the 17th assembly on. They are `NA` when a
row has no `member_id`, and all but `total_terms` and `is_female` are
`NA` when the legislator did not serve in that assembly.

The panel counts seminars by name and year. Because a new assembly
begins on May 30 of an election year, the rows of an election year also
hold the activity of members of the outgoing assembly, under the new
assembly number. Legislators who share a name with another member of the
same assembly have one row per year for both of them, with `member_id`
`NA`.

## Examples

``` r
data(seminars)

# Cross-party collaboration by governing status
tapply(seminars$cross_party_ratio, seminars$is_governing, mean, na.rm = TRUE)
#>     FALSE      TRUE 
#> 0.3155702 0.2804488 

# Seminar activity over time
agg <- aggregate(n_seminars ~ year, data = seminars, FUN = sum)
plot(agg, type = "b", main = "Total Policy Seminars by Year")


# Gender gap in seminar hosting
tapply(seminars$n_seminars, seminars$is_female, median, na.rm = TRUE)
#> FALSE  TRUE 
#>     5     9 
```
