# assemblykor: Korean National Assembly Data for Political Science Education

Provides ready-to-use datasets from the Korean National Assembly for
teaching quantitative methods in political science. Includes seven
built-in datasets covering legislator metadata, bills, asset
declarations, policy seminars, committee speeches, plenary vote tallies,
and member-level roll call votes.

## Built-in datasets

- [`legislators`](https://kyusik-yang.github.io/assemblykor/reference/legislators.md):
  948 MP records (20th-22nd assemblies)

- [`bills`](https://kyusik-yang.github.io/assemblykor/reference/bills.md):
  60,925 legislative bills

- [`wealth`](https://kyusik-yang.github.io/assemblykor/reference/wealth.md):
  2,928 legislator-year asset declarations

- [`seminars`](https://kyusik-yang.github.io/assemblykor/reference/seminars.md):
  5,962 legislator-year seminar records

- [`speeches`](https://kyusik-yang.github.io/assemblykor/reference/speeches.md):
  15,795 speech records (22nd, Science & ICT Committee)

- [`votes`](https://kyusik-yang.github.io/assemblykor/reference/votes.md):
  8,050 plenary vote tallies (20th-22nd assemblies)

- [`roll_calls`](https://kyusik-yang.github.io/assemblykor/reference/roll_calls.md):
  383,792 member-level roll call votes (22nd assembly)

## Download functions

- [`get_bill_texts`](https://kyusik-yang.github.io/assemblykor/reference/get_bill_texts.md):
  60,925 bill propose-reason texts

- [`get_proposers`](https://kyusik-yang.github.io/assemblykor/reference/get_proposers.md):
  777,220 co-sponsorship records

- [`get_speech_tokens`](https://kyusik-yang.github.io/assemblykor/reference/get_speech_tokens.md):
  663,582 morpheme tokens for the `speeches` dataset (Kiwi morphological
  analyzer)

## Data corrections

Version 0.1.4 corrects defects that release 0.7.0 of the kna project
(<https://github.com/kyusik-yang/kna>) found in the underlying Open
Assembly records, among them the seniority and committees of
`legislators`, the results of vetoed bills and the co-sponsorship
records cut at 100 names per bill. The coverage is unchanged, with data
as of March 2026. See the package NEWS for details.

## Tutorials

Nine Korean-language tutorials covering tidyverse, visualization,
regression, panel data, text analysis, network analysis, roll call
analysis, bill success, and speech patterns. Use
[`list_tutorials`](https://kyusik-yang.github.io/assemblykor/reference/list_tutorials.md)
to see all tutorials, and
[`open_tutorial`](https://kyusik-yang.github.io/assemblykor/reference/open_tutorial.md)
to copy them to your working directory.

## See also

Useful links:

- <https://kyusik-yang.github.io/assemblykor/>

- <https://github.com/kyusik-yang/assemblykor>

- Report bugs at <https://github.com/kyusik-yang/assemblykor/issues>

## Author

**Maintainer**: Kyusik Yang <kyusik.yang@nyu.edu>
