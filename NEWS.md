# assemblykor 0.1.4

This release corrects defects in the built-in data that releases 0.7.0 to
0.8.1 of the kna project (https://github.com/kyusik-yang/kna, CORRECTIONS.md
of 2026-09-26 to 2026-09-28) found in the same Open Assembly records. The
coverage is unchanged, with data as of March 2026. The corrections are
applied by `data-raw/kna070_corrections.R`, which reads kna 0.8.1. Column
names are unchanged. New columns
were added, and the two columns whose meaning changes are marked below.

## Data corrections

* `legislators$seniority` now gives the seniority at that assembly, as
  documented. It held the member's lifetime number of terms at the time
  of data collection, which overstated the seniority of 286 member-terms
  of the 20th and 21st assemblies. First-term members now number 150 in
  the 20th and 168 in the 21st, equal to the official counts, instead of
  88 and 96.
* `legislators$committees` now lists the committees the member served on
  in that assembly, from the dated assignment records. The old strings
  came from present-day committee lists and did not match the assembly
  for many members. They were empty for 233 rows, and are now empty only
  for the Speaker in the 22nd assembly.
* `legislators`: six values of `party_elected` now give the party whose
  ticket or list the member was elected on, one 20th-assembly district
  and two district types (two proportional members recorded as
  constituency members) were corrected, the two 22nd-assembly members who
  took up vacant proportional seats in June 2025 now have the district
  `비례대표` instead of an empty string, and `n_bills` was recounted from
  the complete co-sponsorship records (582 rows change). The member who
  took up a vacant proportional seat of the 22nd assembly in March 2026
  was added (948 rows instead of 947).
* `bills`: the 11 vetoed bills that were rejected on the re-vote or
  expired at the end of the term kept the result of their first floor
  vote (passed as-is or passed with amendments). `result` now follows the
  re-vote. New logical columns `vetoed` (12 bills) and `alt_vetoed` (180
  bills incorporated into a committee alternative that was vetoed and
  not passed again) make these cases visible.
* `roll_calls$party` was documented as the party at the time of the vote.
  It is the party label that the API reported at data collection, written
  onto every past vote. The values are unchanged and the documentation is
  corrected. The new column `party_elected` gives the party at election.
  53 votes cast on 2026-03-12 by the newly seated member, which the March
  2026 collection missed, were restored. The vote API omits 이소희, who took
  up a vacant proportional seat on 2026-01-15, and her 230 rows of the
  votes up to 2026-03-12 were added from the LIKMS vote pages, as in kna
  0.8.0. 171 of them are `불참`, for votes at which she was seated but on
  no list (384,022 rows instead of 383,739).
* `seminars`: `seniority`, `total_terms`, `is_female`, `is_proportional`,
  `is_seoul` and `province` now come from the member records of kna 0.7.0,
  matched on `member_id` and `assembly`. They were matched on the name
  alone, counted only the terms from the 17th assembly on, and applied
  one seat type and one region to every term of a member. `seniority`
  changes value in 1,128 rows, gains a value in 242 rows of the 22nd
  assembly and becomes `NA` in 272 rows. The attributes are `NA` for the
  266 rows without `member_id`, mostly members of the outgoing assembly
  in election years and legislators who share a name with another member.
  `province` now uses the short province names and is `NA` for
  proportional-representation members.
* `speeches$member_id` changes meaning. It held the numeric speaker
  identifier of the committee minutes, which did not match
  `legislators$member_id` for any speech. It is now the MONA_CD for the
  12,060 speeches by members of the Assembly and `NA` for other speakers.
  The old values are kept in the new column `speaker_id`. 48 speeches of
  2024-08-14 that appeared twice under two speaker identifiers were
  dropped (15,795 rows instead of 15,843).
* `get_proposers()` changes source. It now downloads a file hosted in
  this repository and built from the kna 0.7.0 co-sponsorship records.
  The old file stopped at 100 names per bill, which left out 7,447
  records of 208 bills, and `is_lead` was `FALSE` for the lead proposer
  of 36 single-proposer bills (777,220 rows instead of 769,773). A new
  column `role` separates co-proposers from supporters, who were both
  `is_lead == FALSE`. The cache file name changed, so a file cached by
  0.1.3 is not reused.
* `get_speech_tokens()` no longer holds a second copy of the tokens of the
  48 duplicated speeches (663,582 rows instead of 665,055), and uses a new
  cache file name. Its documentation claimed that 56 speeches had no
  tokens. Every speech has tokens, and the 56 were repeated
  `date`/`speech_order` keys.

## Documentation

* `votes$bill_id` is unique except for bill 2000491, which has two tally
  rows in the source. The documentation and codebook said it was unique.
* The `roll_calls` documentation said that the API has member-level votes
  for the 22nd assembly only. It also has the 20th and 21st.
* The documentation of `party_elected` notes that the source records ten
  successors to proportional seats (two of them in `roll_calls`) under
  the party that the list party had merged into, not the list party.
* Tutorial 8 (bill success) no longer counts the 180 `alt_vetoed` bills
  as passed, in all three tutorial formats. The introduction vignette no
  longer says that senior legislators propose more bills, which the data
  do not show. Row counts were updated in the README, vignettes,
  cheatsheet, tutorials and startup message.
* Tutorial 4 (panel data) uses `member_id` instead of `name` as the
  individual fixed effect in its example of a time-invariant variable,
  in all three tutorial formats. With the corrected `seminars`
  attributes, two names each belong to a man and a woman, so a `name`
  fixed effect no longer absorbed `is_female` as the tutorial says.

# assemblykor 0.1.3

* New download function `get_speech_tokens()`: morpheme tokens for the
  `speeches` dataset, produced with the Kiwi morphological analyzer
  (kiwipiepy). Content morphemes only (NNG/NNP/VV/VA/MAG/SL), verbs and
  adjectives lemmatized, keyed by `date` + `speech_order`. Students can
  do proper Korean tokenization without installing a morphological
  analyzer. Tutorial 05 gains a section comparing whitespace
  tokenization against morphological analysis.
* The startup message now points to the GitHub repository for the
  latest data and fixes, since CRAN releases may lag behind.
* Fixed tutorial 04 (panel data): `etable()` was called with an `lm`
  object, which `fixest::etable()` does not accept. The pooled OLS model
  is now re-estimated with `feols()` (identical estimates) before the
  comparison table. Fixed in all three tutorial formats (plain Rmd,
  learnr, shinyapps).
* Fixed tutorial 05 (text analysis): `slice_sample(n = min(5000, n()))`
  errors under dplyr >= 1.1.0, which requires `n` to be a constant.
  Replaced with `slice_sample(n = 5000)`, which silently truncates when
  fewer rows are available (same behavior).
* `get_bill_texts()` and `get_proposers()` now download to a temporary
  file first and only move it into the cache on success. Previously, a
  failed or partial download left a corrupt file that later calls
  treated as a valid cache. Both functions now fail gracefully with a
  message (returning `NULL` invisibly) instead of an error when the
  resource is unavailable, and raise the download timeout to at least
  300 seconds.
* Documentation corrections: `wealth` covers 772 members over 10
  disclosure years (2015-2024), not 773 over 13 periods (2015-2025);
  `seminars` covers the 17th-22nd assemblies (2004-2025), not the
  16th-22nd (2000-2025), and its `camp` variable has five levels
  (including centrist); the package overview now lists all seven
  built-in datasets.

# assemblykor 0.1.2

* Fixed donttest example failure reported in CRAN 'Additional issues'.
  The remote parquet files served by `get_bill_texts()` and
  `get_proposers()` were re-encoded from ZSTD to GZIP compression so
  that CRAN's default arrow build (which does not include the ZSTD
  codec) can read them without error.
* Examples for `get_bill_texts()` and `get_proposers()` now write the
  cache file to `tempdir()` rather than the user cache directory, so
  R CMD check runs no longer leave files behind.

# assemblykor 0.1.1

* Replaced all `\dontrun{}` in examples per CRAN reviewer request:
  - `get_bill_texts()`, `get_proposers()`: changed to `\donttest{}` (download functions).
  - `open_tutorial()`, `run_tutorial()`, `set_ko_font()`: changed to
    `if (interactive()) {}` (interactive or system-dependent functions).

# assemblykor 0.1.0

* Initial CRAN release.
* Seven built-in datasets: `legislators`, `bills`, `wealth`, `seminars`,
  `speeches`, `votes`, `roll_calls`.
* Two download functions for larger datasets: `get_bill_texts()`,
  `get_proposers()`.
* Nine Korean-language interactive tutorials (learnr) and plain R Markdown
  versions covering tidyverse, visualization, regression, panel data, text
  analysis, network analysis, roll call analysis, bill success prediction,
  and speech pattern analysis.
* Utility functions: `set_ko_font()`, `path_to_file()`, `list_tutorials()`,
  `open_tutorial()`, `run_tutorial()`.
