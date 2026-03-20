# Path to assemblykor CSV files

Returns the file path to CSV versions of the built-in datasets stored in
`inst/extdata`. Useful for teaching file I/O with
[`read.csv()`](https://rdrr.io/r/utils/read.table.html) or
`readr::read_csv()`.

## Usage

``` r
path_to_file(file = NULL)
```

## Arguments

- file:

  Name of the CSV file. One of `"legislators.csv"`, `"wealth.csv"`, or
  `"seminars.csv"`.

## Value

A character string with the full file path.

## Examples

``` r
# Read data from CSV (alternative to data())
path <- path_to_file("legislators.csv")
legislators_csv <- read.csv(path, fileEncoding = "UTF-8")
head(legislators_csv)
#>   member_id assembly   name name_hanja       name_eng        party
#> 1  XQ98168F       20 강길부     姜吉夫   KANG GHILBOO       무소속
#> 2  60490713       20 강병원     姜炳遠  KANG BYUNGWON 더불어민주당
#> 3  IH436704       20 강석진     姜錫振   KANG SEOGJIN   자유한국당
#> 4  8I61593E       20 강석호     姜碩鎬    KANG SEOKHO   자유한국당
#> 5  TOU1222X       20 강창일     姜昌一   KANG CHANGIL 더불어민주당
#> 6  9WQ7845Z       20 강효상     姜孝祥 KHANG HYOSHANG   자유한국당
#>   party_elected                      district district_type
#> 1        무소속                   울산 울주군  constituency
#> 2  더불어민주당                 서울 은평구을  constituency
#> 3      새누리당 경남 산청군함양군거창군합천군  constituency
#> 4      새누리당 경북 영양군영덕군봉화군울진군  constituency
#> 5  더불어민주당                 제주 제주시갑  constituency
#> 6      새누리당                      비례대표  proportional
#>                                                                                                                                                                                                                                                                                                                                                   committees
#> 1                                                                                                                                                                                                                                                        산업통상자원중소벤처기업위원회, 4차 산업혁명 특별위원회, 예산결산특별위원회, 교육문화체육관광위원회
#> 2                                                                                                                                                                                                                                                                                                                                                           
#> 3                                                                                                                                                                                                                                                                             농림축산식품해양수산위원회, 국회운영위원회, 보건복지위원회, 예산결산특별위원회
#> 4                                                                                                                                                                                                                                                농림축산식품해양수산위원회, 외교통일위원회, 정보위원회, 정치개혁 특별위원회, 행정안전위원회, 안전행정위원회
#> 5                                                                                                                                                                                                                                                        과학기술정보방송통신위원회, 행정안전위원회, 예산결산특별위원회, 헌법개정 특별위원회, 외교통일위원회
#> 6 대법관(노태악) 임명동의에 관한 인사청문특별위원회, 법제사법위원회, 국회운영위원회, 공공부문 채용비리 의혹과 관련된 국정조사특별위원회, 환경노동위원회, 사법개혁특별위원회, 재난안전 대책 특별위원회, 청년미래 특별위원회, 과학기술정보방송통신위원회, 국무총리(이낙연) 임명동의에 관한 인사청문특별위원회, 헌법개정 특별위원회, 미래창조과학방송통신위원회
#>   gender birth_date seniority n_bills n_bills_lead
#> 1      M 1942-06-05         4     312           21
#> 2      M 1971-07-09         2    1078           94
#> 3      M 1959-12-07         1     694           53
#> 4      M 1955-12-03         3     583           43
#> 5      M 1952-01-28         4    1131           89
#> 6      M 1961-03-01         1     393           74
```
