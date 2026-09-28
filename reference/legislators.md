# Members of the Korean National Assembly (20th-22nd)

Biographical and political metadata for 948 records of legislators who
served in the 20th (2016-2020), 21st (2020-2024), or 22nd (2024-2028)
Korean National Assembly. Some legislators appear in multiple
assemblies. The 22nd assembly covers the members seated by March 2026.

## Usage

``` r
legislators
```

## Format

A data frame with 948 rows and 15 variables:

- member_id:

  Unique legislator identifier (MONA_CD from the National Assembly API)

- assembly:

  Assembly number (20, 21, or 22)

- name:

  Name in Korean (hangul)

- name_hanja:

  Name in Chinese characters (hanja)

- name_eng:

  Name in English (romanized)

- party:

  Party label that the official roster of that assembly records for the
  member. It reflects party mergers, renamings and switches during the
  term. For the 22nd assembly it is the party as of March 2026.

- party_elected:

  Party at election, that is, the party on whose ticket or list the
  member was elected. For a successor to a proportional seat, the party
  of the list the seat came from. The source records ten such successors
  under the party that the list party had merged into by the time they
  took the seat (for example, the Democratic Party of Korea for the
  Democratic Alliance of Korea), as does release 0.7.0 of the kna
  project.

- district:

  Electoral district name, or party list position for proportional
  members

- district_type:

  Election type: "constituency" or "proportional"

- committees:

  Committees (standing and special) the member served on in that
  assembly, comma-separated in order of first assignment. Empty for a
  member with no assignment, such as the Speaker.

- gender:

  "M" (male) or "F" (female)

- birth_date:

  Date of birth

- seniority:

  Seniority at that assembly, that is, the number of terms served up to
  and including this one, counting terms before the 20th (1 =
  first-term)

- n_bills:

  Number of bills in
  [`bills`](https://kyusik-yang.github.io/assemblykor/reference/bills.md)
  the member proposed, co-proposed or supported (see
  [`get_proposers`](https://kyusik-yang.github.io/assemblykor/reference/get_proposers.md))

- n_bills_lead:

  Bills proposed as lead (primary) proposer

## Source

Open National Assembly Information API (Republic of Korea), as corrected
in kna 0.7.0 (<https://github.com/kyusik-yang/kna>). License: public
domain (Korean government open data).

## Details

662 unique legislators served across the three assemblies. `member_id`
is consistent across assemblies, so legislators can be tracked over
time. Party names may differ between `party` (mid-term) and
`party_elected` (election day) due to party mergers and name changes,
which are common in Korean politics. Some legislators share a name with
another member of the same assembly (for example, two members named Kim
Seong-tae in the 20th), so join on `member_id`, never on `name`.

Up to version 0.1.3, `seniority` held each member's lifetime number of
terms at the time of data collection, so it overstated the seniority of
286 member-terms of the 20th and 21st assemblies, and `committees` came
from a present-day string that did not match the assembly. Both now
follow release 0.7.0 of the kna project, as do six values of
`party_elected`, one district, two district types and the bill counts.

## Examples

``` r
data(legislators)

# Party composition by assembly
table(legislators$assembly, legislators$party)
#>     
#>      개혁신당 국민의당 국민의힘 기본소득당 녹색정의당 더불어민주당 무소속
#>   20        0       25        0          0          0          138      6
#>   21        0        1      123          1          2          180      6
#>   22        3        0      109          1          0          172      3
#>     
#>      민주평화당 바른미래당 사회민주당 새누리당 시대전환 열린민주당 자유한국당
#>   20          6         17          0       10        0          0        111
#>   21          0          0          0        0        1          1          0
#>   22          0          0          1        0        0          0          0
#>     
#>      정의당 조국혁신당 진보당
#>   20      7          0      0
#>   21      6          0      1
#>   22      0         13      4

# Gender gap in bill production
tapply(legislators$n_bills_lead, legislators$gender, median)
#>  F  M 
#> 63 55 

# First-term vs senior legislators
boxplot(n_bills_lead ~ seniority, data = legislators,
        xlab = "Terms served", ylab = "Bills proposed (lead)")
```
