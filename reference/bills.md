# Bills Proposed in the Korean National Assembly (20th-22nd)

Metadata for the 64,900 bills that members proposed during the 20th
through 22nd Korean National Assembly (2016-2026), up to 2026-09-23.

## Usage

``` r
bills
```

## Format

A data frame with 64,900 rows and 11 variables:

- bill_id:

  Unique bill identifier from the National Assembly system

- bill_no:

  Numeric bill number

- assembly:

  Assembly number (20, 21, or 22)

- bill_name:

  Full bill title in Korean

- committee:

  Standing committee to which the bill was referred

- propose_date:

  Date the bill was formally proposed

- result:

  Legislative outcome in Korean. Common values include passed as-is,
  expired at term end, and incorporated into alternative bill. `NA` for
  bills pending on 2026-09-23. For a vetoed bill, the outcome after the
  veto (rejected on the re-vote, passed again, or expired at the end of
  the term). See `table(bills$result)` for all values.

- proposer:

  Name of the lead (primary) proposer

- proposer_id:

  MONA_CD of the lead proposer (links to `legislators$member_id`).
  Comma-separated for the few bills with joint lead proposers.

- vetoed:

  Logical: the President returned the bill to the Assembly for
  reconsideration (a presidential veto)

- alt_vetoed:

  Logical: the bill was incorporated into a committee alternative
  (`result` "incorporated into alternative bill") that was vetoed and
  not passed again, so its content never became law

## Source

Open National Assembly Information API (Republic of Korea), as corrected
in kna 0.7.0 (20th and 21st) and kna 0.8.1 (22nd)
(<https://github.com/kyusik-yang/kna>).

## Details

The Korean National Assembly has seen a dramatic increase in bill
proposals: the 21st Assembly produced 23,655 bills versus 21,594 in the
20th. Most bills expire at the end of the assembly term (term expiry).
Only about 5\\ with amendments.

Up to version 0.1.3, 11 of the 12 vetoed bills, which were rejected on
the re-vote or expired at the end of the term, kept the result of their
first floor vote. Their `result` now follows the re-vote, as in release
0.7.0 of the kna project. To count bills whose content became law,
exclude `alt_vetoed` bills as well.

Use
[`get_bill_texts()`](https://kyusik-yang.github.io/assemblykor/reference/get_bill_texts.md)
to download the full propose-reason texts for text analysis, and
[`get_proposers()`](https://kyusik-yang.github.io/assemblykor/reference/get_proposers.md)
for the complete co-sponsorship records (825,283 rows).

## Examples

``` r
data(bills)

# Bills per assembly
table(bills$assembly)
#> 
#>    20    21    22 
#> 21594 23655 19651 

# Top 10 committees
sort(table(bills$committee), decreasing = TRUE)[1:10]
#> 
#>                 행정안전위원회                 보건복지위원회 
#>                           8839                           6699 
#>                 국토교통위원회                 법제사법위원회 
#>                           5817                           5678 
#>                     정무위원회                 기획재정위원회 
#>                           4832                           4620 
#>     농림축산식품해양수산위원회                 환경노동위원회 
#>                           4046                           4017 
#> 산업통상자원중소벤처기업위원회                     교육위원회 
#>                           3511                           2889 

# Distribution of legislative outcomes
head(sort(table(bills$result), decreasing = TRUE))
#> 
#>   임기만료폐기   대안반영폐기       수정가결       원안가결           철회 
#>          30679          14904           2412           1108            608 
#> 수정안반영폐기 
#>            299 
```
