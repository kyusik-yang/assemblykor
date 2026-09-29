# Data Codebook

This codebook documents all seven built-in datasets in `assemblykor`.
For each dataset, we list every variable with its type, missing rate,
and value distribution. All datasets can be joined via `member_id`
and/or `assembly`.

------------------------------------------------------------------------

## legislators

**963 rows, 15 variables.** MP metadata for the 20th-22nd Korean
National Assembly.

- **Unit of observation**: legislator-assembly
- **Key**: `member_id` + `assembly` (unique)
- **Source**: Open National Assembly API

| Variable | Type | Missing | Distribution |
|:---|:---|:---|:---|
| member_id | character | 0.0% | 672 unique; top: 04T3751T, 0VU8517U, 1WE5693J |
| assembly | numeric | 0.0% | min=20, Q1=20, median=21, Q3=22, max=22 |
| name | character | 0.0% | 663 unique; top: 강훈식, 권성동, 권칠승 |
| name_hanja | character | 0.0% | 671 unique; top: 尹厚德, 尹在玉, 尹昊重 |
| name_eng | character | 0.7% | 663 unique; top: AHN CHEOLSOO, AHN GYUBACK, AN HOYOUNG |
| party | character | 0.0% | 17 unique; top: 더불어민주당, 국민의힘, 자유한국당 |
| party_elected | character | 0.0% | 18 unique; top: 더불어민주당, 새누리당, 국민의힘 |
| district | character | 0.0% | 298 unique; top: 비례대표, 인천 계양구을, 강원 원주시갑 |
| district_type | character | 0.0% | 2 unique; top: constituency, proportional |
| committees | character | 0.0% | 904 unique; top: 외교통일위원회, 정무위원회, 국방위원회 |
| gender | character | 0.0% | 2 unique; top: M, F |
| birth_date | Date | 0.0% | 1940-07-11 to 1995-01-02 |
| seniority | numeric | 0.0% | min=1, Q1=1, median=2, Q3=3, max=8 |
| n_bills | numeric | 0.0% | min=7, Q1=464, median=757, Q3=1158, max=4205 |
| n_bills_lead | numeric | 0.0% | min=0, Q1=37, median=61, Q3=88, max=696 |

------------------------------------------------------------------------

## bills

**64,900 rows, 11 variables.** Legislative bill metadata (20th-22nd
assembly).

- **Unit of observation**: bill
- **Key**: `bill_id` (unique)
- **Join**: `proposer_id` links to `legislators$member_id`
- **Source**: Open National Assembly API

| Variable | Type | Missing | Distribution |
|:---|:---|:---|:---|
| bill_id | character | 0.0% | 64900 unique; top: PRC_A1A6B0A8G3D0P1G8B4B2F1J6J3I8Q3, PRC_A1A6B0W6I2T0P1H6L0D4U0A9N0G3B2, PRC_A1A6B0X7D2X8K1H6B5W3G0C3F5P5L7 |
| bill_no | numeric | 0.0% | min=2000001, Q1=2018589, median=2111904, Q3=2203732, max=2221581 |
| assembly | numeric | 0.0% | min=20, Q1=20, median=21, Q3=22, max=22 |
| bill_name | character | 0.0% | 4718 unique; top: 조세특례제한법 일부개정법률안, 공직선거법 일부개정법률안, 지방세특례제한법 일부개정법률안 |
| committee | character | 0.1% | 33 unique; top: 행정안전위원회, 보건복지위원회, 국토교통위원회 |
| propose_date | Date | 0.0% | 2016-05-30 to 2026-09-23 |
| result | character | 22.6% | 8 unique; top: 임기만료폐기, 대안반영폐기, 수정가결 |
| proposer | character | 0.0% | 800 unique; top: 황주홍, 윤준병, 민형배 |
| proposer_id | character | 0.0% | 809 unique; top: JOY4394O, JC14718Q, VRY5522V |
| vetoed | logical | 0.0% | TRUE: 12, FALSE: 64888 |
| alt_vetoed | logical | 0.0% | TRUE: 180, FALSE: 64720 |

------------------------------------------------------------------------

## wealth

**3,215 rows, 14 variables.** Legislator asset declaration panel
(2015-2025, 11 years).

- **Unit of observation**: legislator-year
- **Key**: `member_id` + `year` (unique)
- **Units**: all monetary values in thousands of KRW (1 unit = 1,000
  won)
- **Source**: OpenWatch (CC BY-SA 4.0)

| Variable | Type | Missing | Distribution |
|:---|:---|:---|:---|
| member_id | character | 0.0% | 776 unique; top: 04T3751T, 1WE5693J, 1Y73132H |
| year | numeric | 0.0% | min=2015, Q1=2017, median=2020, Q3=2023, max=2025 |
| name | character | 0.0% | 775 unique; top: 김도읍, 김상훈, 김태년 |
| total_assets | numeric | 0.0% | min=36960, Q1=1094748, median=1840120, Q3=3320038, max=443526250 |
| total_debt | numeric | 0.0% | min=0, Q1=40000, median=217893, Q3=572290, max=20027140 |
| net_worth | numeric | 0.0% | min=-1427653, Q1=808384, median=1492296, Q3=2849600, max=443526250 |
| real_estate | numeric | 0.0% | min=0, Q1=570000, median=1015618, Q3=1948572, max=42900041 |
| building | numeric | 0.0% | min=0, Q1=490000, median=917000, Q3=1720984, max=42886438 |
| land | numeric | 0.0% | min=0, Q1=0, median=5139, Q3=137388, max=25616148 |
| deposits | numeric | 0.0% | min=0, Q1=218886, median=428692, Q3=876346, max=46929336 |
| stocks | numeric | 0.0% | min=0, Q1=0, median=0, Q3=26234, max=375332731 |
| n_properties | numeric | 0.0% | min=0, Q1=3, median=4, Q3=5, max=37 |
| has_seoul_property | logical | 0.0% | TRUE: 2527, FALSE: 688 |
| has_gangnam_property | logical | 0.0% | TRUE: 885, FALSE: 2330 |

------------------------------------------------------------------------

## seminars

**5,962 rows, 18 variables.** Legislator-year policy seminar activity
(17th-22nd assembly, 2004-2025).

- **Unit of observation**: legislator-year
- **Key**: `member_id` + `year` (note: ~5% of `member_id` are `NA`)
- **Source**: National Assembly Seminar Database

| Variable | Type | Missing | Distribution |
|:---|:---|:---|:---|
| name | character | 0.0% | 1081 unique; top: 안민석, 조정식, 변재일 |
| member_id | character | 4.5% | 1088 unique; top: IN328264, XBT9550Q, ZA54991S |
| year | numeric | 0.0% | min=2004, Q1=2011, median=2016, Q3=2021, max=2025 |
| assembly | numeric | 0.0% | min=17, Q1=18, median=20, Q3=21, max=22 |
| party | character | 0.2% | 42 unique; top: 더불어민주당, 한나라당, 새누리당 |
| camp | character | 0.0% | 5 unique; top: 민주계, 보수계, 기타 |
| seniority | numeric | 4.6% | min=1, Q1=1, median=1, Q3=3, max=8 |
| n_seminars | numeric | 0.0% | min=1, Q1=2, median=5, Q3=12, max=94 |
| n_cross_party | numeric | 0.0% | min=0, Q1=0, median=1, Q3=4, max=55 |
| cross_party_ratio | numeric | 0.0% | min=0, Q1=0, median=0, Q3=0, max=1 |
| avg_coalition_size | numeric | 0.0% | min=1, Q1=2, median=3, Q3=10, max=74 |
| is_governing | logical | 0.0% | TRUE: 2795, FALSE: 3167 |
| is_female | logical | 4.5% | TRUE: 1001, FALSE: 4695 |
| is_proportional | logical | 4.6% | TRUE: 1031, FALSE: 4657 |
| is_seoul | logical | 4.6% | TRUE: 914, FALSE: 4774 |
| province | character | 21.9% | 17 unique; top: 경기, 서울, 부산 |
| total_terms | numeric | 4.5% | min=1, Q1=1, median=2, Q3=4, max=8 |
| n_bills_led | numeric | 0.0% | min=0, Q1=21, median=42, Q3=72, max=696 |

------------------------------------------------------------------------

## speeches

**15,795 rows, 10 variables.** Committee speech records from the Science
and ICT Committee (22nd assembly, 2024).

- **Unit of observation**: speech turn
- **Key**: `date` + `speech_order` (unique except for eight values of
  2024-06-25, when two meetings were held)
- **Join**: `member_id` links to `legislators$member_id` for members of
  the Assembly (`NA` for other speakers)
- **Source**: National Assembly committee minutes

| Variable | Type | Missing | Distribution |
|:---|:---|:---|:---|
| assembly | numeric | 0.0% | min=22, Q1=22, median=22, Q3=22, max=22 |
| date | Date | 0.0% | 2024-06-11 to 2024-12-27 |
| committee | character | 0.0% | 1 unique; top: 과학기술정보방송통신위원회 |
| speaker | character | 0.0% | 165 unique; top: 위원장 최민희, 김현 위원, 노종면 위원 |
| role | character | 0.0% | 14 unique; top: legislator, chair, witness |
| speaker_name | character | 0.0% | 139 unique; top: 최민희, 김현, 노종면 |
| member_id | character | 23.6% | 22 unique; top: YS38221N, 7YL9580G, RUZ25800 |
| speaker_id | character | 23.6% | 23 unique; top: 6247, 1728, 9103 |
| speech_order | numeric | 0.0% | min=1, Q1=329, median=774, Q3=1463, max=4091 |
| speech | character | 0.0% | 15795 unique; top: ‘2011년 대검 중수부에서 대장동 대출 건으로 수사를 받았고, 제가 대출 커미션 받은 것 때문에 모두 수사를 받았고 그때 당시 계좌 압수수색까지 받았습니다. 하지만 무혐의를 받았습니다’라고 반복해서 경찰에 진술한 기록이 있습니다., ‘MBC에서 노조원 수도 바뀌어’ 이것은 서부지방법원에서 진행되고 있으니까 그 진실이 나올 겁니다. 왜 한 노조가 다른 노조를 핍박하느냐 그리고 왜 한 노조는 절대 선인 양 군림하려고 하느냐…… 그래서 원고 허 모 이분이, 지금 참고인이 겪은 피해에 대해서 이렇게 돼 있습니다. 이게 무슨, 회사 내 정상화위원회라는 게 정말 이게 무슨 조직입니까? 이런 조직을, 아까 어떤 증인이지요, 송요훈 증인인가 이분은 자기가 떳떳하다 이야기를 하는데 이 판결문에 이렇게 돼 있습니다. 얼마나 겁을 주는지 정상화위원회 조사협력 요구에 응하지 않을 경우, 정당한 사유가 있음에도 불구하고 조사에 불응할 경우 대기발령, 임금 삭감 이런 겁을 주니까 그래서 수사 의뢰, 중징계 같은 수단으로 비위행위를 시인하도록 강요했고 그런데 이러니까 허 참고인이 인사위원회에 회부된 동료 기자들 상당수가 해고·정직 같은 중징계를 받는 것을 보면서 징계처분의 압박과 심리적 불안감이 상당하였을 것으로 보았다. 이게 법원 판결문입니다. 그래서 명예퇴직을 신청을 했지요?, ‘Obedire Veritati’ ‘그대 서강의 자랑이듯 서강 그대의 자랑이어라’, 서강대에서도 이 후보자님 지우고 싶을 것 같다는 생각이 듭니다. 씁쓸한 마음에 개인적인 소회 밝혔습니다. 후보자님, 본인이 방통위원장으로 임명된다는 것에 몇 퍼센트 확신을 하고 계십니까? |

------------------------------------------------------------------------

## votes

**8,611 rows, 13 variables.** Plenary vote tallies (20th-22nd assembly).

- **Unit of observation**: bill vote
- **Key**: `bill_id` (unique except for bill 2000491, which has two
  tally rows)
- **Join**: `bill_id` links to `bills$bill_id` (~40% match rate; `votes`
  includes committee alternatives and budget bills not in `bills`)
- **Source**: Open National Assembly API

| Variable | Type | Missing | Distribution |
|:---|:---|:---|:---|
| bill_id | character | 0.0% | 8610 unique; top: ARC_D1U6W0S6P2G7T1G1C2X3M1S6L7N2N0, ARC_A1D6N0F9G0E9M1T7F4B8E3C0T6E9E3, ARC_A1E8A1H2I2X1C1Q7Q4W7A0G6F1S9Q2 |
| bill_no | character | 0.0% | 8592 unique; top: 2022996, 2000491, 2012299 |
| bill_name | character | 0.0% | 6110 unique; top: 도로교통법 일부개정법률안(대안)(행정안전위원장), 자동차관리법 일부개정법률안(대안)(국토교통위원장), 국민건강보험법 일부개정법률안(대안)(보건복지위원장) |
| assembly | numeric | 0.0% | min=20, Q1=20, median=21, Q3=21, max=22 |
| committee | character | 0.0% | 49 unique; top: 농림축산식품해양수산위원회, 국토교통위원회, 보건복지위원회 |
| vote_date | Date | 0.0% | 2016-06-09 to 2026-09-17 |
| result | character | 0.0% | 3 unique; top: 원안가결, 수정가결, 부결 |
| bill_type | character | 0.0% | 9 unique; top: 법률안, 예산안, 결의안 |
| total_members | numeric | 0.0% | min=286, Q1=296, median=299, Q3=300, max=300 |
| voted | numeric | 0.0% | min=3, Q1=187, median=212, Q3=236, max=297 |
| yes | numeric | 0.0% | min=1, Q1=179, median=203, Q3=227, max=297 |
| no | numeric | 0.0% | min=0, Q1=0, median=0, Q3=1, max=187 |
| abstain | numeric | 0.0% | min=0, Q1=1, median=3, Q3=7, max=64 |

------------------------------------------------------------------------

## roll_calls

**549,513 rows, 9 variables.** Member-level roll call votes (22nd
assembly, 1,847 bills).

- **Unit of observation**: legislator-bill vote
- **Key**: `member_id` + `bill_id` (unique)
- **Join**: `member_id` links to `legislators$member_id`; `bill_id`
  links to `votes$bill_id`
- **Source**: Open National Assembly API

| Variable | Type | Missing | Distribution |
|:---|:---|:---|:---|
| bill_id | character | 0.0% | 1847 unique; top: ARC_B2U4U0H7N2J2O0N8R5I5F1J9G2D2U5, ARC_C2A4B0A8H3R0V0R9F2L0E3Z7P8F7S5, ARC_C2A4M0W7H2E2U0L8Z5W5D3P2U7T2A3 |
| assembly | numeric | 0.0% | min=22, Q1=22, median=22, Q3=22, max=22 |
| member_name | character | 0.0% | 320 unique; top: 박지원, 강경숙, 강대식 |
| member_id | character | 0.0% | 321 unique; top: 04T3751T, 0R68099X, 0VU8517U |
| party | character | 0.0% | 8 unique; top: 더불어민주당, 국민의힘, 조국혁신당 |
| party_elected | character | 0.0% | 9 unique; top: 더불어민주당, 국민의힘, 국민의미래 |
| district | character | 0.0% | 255 unique; top: 비례대표, 강원 동해시태백시삼척시정선군, 강원 속초시인제군고성군양양군 |
| vote | character | 0.0% | 4 unique; top: 찬성, 불참, 반대 |
| vote_date | Date | 0.0% | 2024-07-04 to 2026-09-17 |

------------------------------------------------------------------------

## Dataset relationship diagram

                        legislators
                       (member_id + assembly)
                       /       |        \
                      /        |         \
                   wealth   seminars   bills
                (member_id) (member_id) (proposer_id)
                                          |
                                        votes
                                      (bill_id)
                                          |
                                      roll_calls
                                   (bill_id + member_id)
                                          |
                                      legislators
                                      (member_id)

        speeches --- legislators (member_id, 22nd assembly only)

All datasets share `member_id` as the primary join key. Use `assembly`
as a secondary key when joining datasets that span multiple assembly
terms.
