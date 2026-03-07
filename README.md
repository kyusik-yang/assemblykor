# assemblykor

Korean National Assembly data for political science education.

A teaching-oriented R data package providing ready-to-use datasets from the Korean National Assembly (2000-2026). Designed as a Korean politics counterpart to [`palmerpenguins`](https://allisonhorst.github.io/palmerpenguins/), enabling students to practice regression, panel data analysis, text analysis, and network analysis with real legislative data.

## Installation

```r
# Install from GitHub
# install.packages("remotes")
remotes::install_github("kyusik-yang/assemblykor")
```

## Datasets

| Dataset | Rows | Unit | Coverage | Use cases |
|---------|------|------|----------|-----------|
| `legislators` | 947 | legislator-assembly | 20th-22nd (2016-2026) | EDA, cross-tabs, demographics |
| `bills` | 60,925 | bill | 20th-22nd (2016-2026) | Frequency analysis, survival analysis |
| `wealth` | 2,928 | legislator-year | 2015-2025 | Panel regression, fixed effects |
| `seminars` | 5,962 | legislator-year | 2000-2025 | Difference-in-differences, collaboration |

All datasets use English column names with consistent identifiers (`member_id`, `assembly`) for easy joining.

## Quick start

```r
library(assemblykor)

# Legislator demographics
data(legislators)
table(legislators$gender, legislators$assembly)

# Bill outcomes
data(bills)
barplot(sort(table(bills$result), decreasing = TRUE)[1:5],
        las = 2, main = "Bill Outcomes in the Korean National Assembly")

# Wealth panel
data(wealth)
boxplot(net_worth / 1e6 ~ year, data = wealth,
        xlab = "Year", ylab = "Net Worth (billion KRW)",
        main = "Legislator Wealth Over Time")

# Seminar collaboration
data(seminars)
with(seminars, plot(n_seminars, cross_party_ratio,
     xlab = "Seminars hosted", ylab = "Cross-party ratio",
     main = "Policy Seminars and Bipartisan Cooperation"))
```

## Downloadable datasets

Larger datasets are available via download functions (requires the `arrow` package):

```r
# Bill propose-reason texts (60,925 texts, ~40 MB)
texts <- get_bill_texts()

# Co-sponsorship records (769,773 rows, ~25 MB)
proposers <- get_proposers()
```

Files are cached locally after the first download.

## Teaching scenarios

| Topic | Dataset | Example exercise |
|-------|---------|-----------------|
| R intro / tidyverse | `legislators` | Party composition by gender and assembly |
| OLS regression | `wealth` + `legislators` | Does wealth predict legislative productivity? |
| Panel data / FE | `wealth` | Within-legislator wealth changes over time |
| Diff-in-Diff | `seminars` | Government status and cross-party collaboration |
| Text analysis | `get_bill_texts()` | Topic modeling of propose-reasons |
| Network analysis | `get_proposers()` | Co-sponsorship networks and centrality |
| Survival analysis | `bills` | Time to bill passage by committee |

## Joining datasets

```r
library(dplyr)
data(legislators)
data(wealth)

# Merge legislator metadata with wealth data
leg_wealth <- legislators |>
  inner_join(wealth, by = "member_id")

# Example: party differences in real estate holdings
leg_wealth |>
  group_by(party) |>
  summarise(median_re = median(real_estate / 1e6, na.rm = TRUE)) |>
  arrange(desc(median_re))
```

## Data sources

- **Bills and legislators**: [Open National Assembly API](https://open.assembly.go.kr) (public domain)
- **Asset declarations**: [OpenWatch](https://openwatchdata.com) (CC BY-SA 4.0)
- **Policy seminars**: National Assembly Seminar Database (public data, collected via API)

## Citation

```
Yang, Kyusik (2026). assemblykor: Korean National Assembly Data for Political Science
Education. R package version 0.1.0. https://github.com/kyusik-yang/assemblykor
```

## License

MIT (package code) + CC BY 4.0 (data)
