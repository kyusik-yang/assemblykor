# assemblykor <img src="man/figures/logo.png" align="right" height="138" />

Korean National Assembly data for political science education.

## Overview

The goal of `assemblykor` is to provide a curated collection of Korean
National Assembly datasets for teaching quantitative methods in political
science. Think of it as a Korean politics counterpart to
[palmerpenguins](https://allisonhorst.github.io/palmerpenguins/).

The package includes five built-in datasets covering legislators, bills,
asset declarations, policy seminars, and committee speeches, all drawn from
public data of the Korean National Assembly (2000-2026).

## Meet the data

<table>
<tr><td width="50%">

**`legislators`** 947 records

20-22대 국회의원 메타데이터 (이름, 정당, 선거구, 성별, 선수, 발의 건수)

</td><td width="50%">

**`bills`** 60,925 records

법안 메타데이터 (제목, 위원회, 발의일, 처리 결과, 대표발의자)

</td></tr>
<tr><td>

**`wealth`** 2,928 records

의원 재산신고 패널 (순자산, 부동산, 예금, 주식, 13개 시점)

</td><td>

**`seminars`** 5,962 records

정책세미나 활동 패널 (개최 건수, 초당적 비율, 여당 여부)

</td></tr>
<tr><td colspan="2">

**`speeches`** 7,500 records

상임위원회 회의록 샘플 (16-20대, 경제/국토 위원회, 발언 전문)

</td></tr>
</table>

## Installation

```r
# install.packages("remotes")
remotes::install_github("kyusik-yang/assemblykor")
```

## Usage

```r
library(assemblykor)

data(legislators)
data(bills)
data(wealth)
data(seminars)
data(speeches)
```

### Example: party composition by gender

```r
library(dplyr)

legislators |>
  filter(assembly == 22) |>
  count(party, gender) |>
  filter(n >= 3)
```

### Example: wealth distribution

```r
library(ggplot2)

ggplot(wealth, aes(x = net_worth / 1e6)) +
  geom_histogram(bins = 50, fill = "steelblue") +
  labs(x = "Net worth (billion KRW)", y = "Count",
       title = "Distribution of legislator wealth")
```

### Example: bill outcomes

```r
bills |>
  count(result, sort = TRUE) |>
  head(5)
#>               result     n
#> 1     임기만료폐기 30678
#> 2     대안반영폐기 13692
#> 3         수정가결  2222
#> 4         원안가결  1048
#> 5             철회   578
```

## Downloadable datasets

Larger datasets are available via download functions (requires the `arrow`
package):

```r
# Bill propose-reason texts (60,925 texts, ~40 MB download)
texts <- get_bill_texts()

# Co-sponsorship records (769,773 rows, ~25 MB download)
proposers <- get_proposers()
```

## Tutorials (한국어 수업 자료)

The package includes six Korean-language tutorials designed for classroom
use in political science methods courses:

| # | Tutorial | Topic |
|---|----------|-------|
| 1 | R 기초와 tidyverse | `dplyr` 핵심 함수, 파이프, 데이터 결합 |
| 2 | ggplot2 시각화 | 막대, 히스토그램, 산점도, 박스플롯, facet |
| 3 | 회귀분석 | OLS, 다중회귀, 로그 변환, 상호작용 |
| 4 | 패널 데이터와 고정효과 | 합동 OLS vs FE, 양방향 FE, DiD |
| 5 | 텍스트 분석 입문 | 키워드 빈도, TF-IDF, 위원회별 비교 |
| 6 | 네트워크 분석 | 공동발의 네트워크, 중심성, 커뮤니티 탐지 |

```r
# List available tutorials
list_tutorials()

# Copy a tutorial to your working directory
open_tutorial(1)  # or open_tutorial("01-tidyverse-basics")
```

Each tutorial includes step-by-step instructions and exercises (연습 문제).

## Joining datasets

All datasets share the `member_id` and/or `assembly` columns for easy
joining:

```r
# Merge legislators with wealth data
leg_wealth <- legislators |>
  inner_join(wealth, by = "member_id", relationship = "many-to-many")
```

## CSV access

CSV versions of the smaller datasets are available for teaching file I/O:

```r
# Find the file path
path_to_file("legislators.csv")

# Read directly
legislators_csv <- read.csv(path_to_file("legislators.csv"), fileEncoding = "UTF-8")
```

## Data sources

| Dataset | Source | License |
|---------|--------|---------|
| Legislators, bills, proposers | [Open National Assembly API](https://open.assembly.go.kr) | Public domain |
| Asset declarations | [OpenWatch](https://openwatchdata.com) | CC BY-SA 4.0 |
| Policy seminars | National Assembly Seminar Database | Public data |

## Citation

```r
citation("assemblykor")
```

```
Yang, Kyusik (2026). assemblykor: Korean National Assembly Data for
Political Science Education. R package version 0.1.0.
https://github.com/kyusik-yang/assemblykor
```

## License

MIT (package code). Data licenses as noted above.
