# kna070_corrections.R
# Applies the corrections of kna 0.7.0 to the built-in datasets and
# rebuilds the co-sponsorship file served by get_proposers().
#
# The datasets were built by prepare_data.R and collect_votes.R from Open
# Assembly records collected in March 2026. The kna 0.7.0 release
# (2026-09-26, https://github.com/kyusik-yang/kna, CORRECTIONS.md) found
# defects in the same upstream records: seniority was the lifetime
# reelection label, party labels were applied retroactively, committee and
# district strings were anachronistic, vetoed bills kept their first floor
# result, and the co-sponsorship list stopped at 100 names per bill. This
# script keeps the coverage of assemblykor 0.1.3 (the same bills and
# recorded votes, data as of March 2026) and replaces the affected values
# with those of kna 0.7.0. It is idempotent, so running it again on its
# own output gives the same result.
#
# Run from the package root after prepare_data.R and collect_votes.R:
#   Rscript data-raw/kna070_corrections.R
#
# Input: kna 0.7.0 data/processed. Set KNA_DATA_DIR to override the default.
# Output: data/{legislators,bills,roll_calls,seminars,speeches}.rda,
#   inst/extdata/{legislators,seminars}.csv,
#   hosted-data/proposers.parquet, hosted-data/speech_tokens.parquet

library(arrow)
library(dplyr)

kna_dir <- Sys.getenv(
  "KNA_DATA_DIR",
  path.expand("~/Desktop/kyusik-github/kna/data/processed")
)

# Data as of March 2026: the members seated, committee spells begun and
# vetoes decided by this date belong to the 0.1.3 coverage.
vintage <- as.Date("2026-03-20")

read_kna <- function(file, ...) {
  as.data.frame(read_parquet(file.path(kna_dir, file), ...))
}

# kna stores dates as UTC midnight
as_day <- function(x) as.Date(x, tz = "UTC")

load("data/legislators.rda")
load("data/bills.rda")
load("data/roll_calls.rda")
load("data/seminars.rda")
load("data/speeches.rda")

# ------------------------------------------------------------
# kna 0.7.0 inputs
# ------------------------------------------------------------
members <- bind_rows(lapply(17:22, function(a) {
  read_kna(sprintf("members_%d.parquet", a))
}))
assignments <- read_kna("committee_assignments.parquet") %>%
  mutate(row = row_number(), start_day = as_day(start_date))
edges <- read_kna("cosponsorship_edges.parquet") %>% filter(age %in% 20:22)
masters <- bind_rows(lapply(20:22, function(a) {
  read_kna(sprintf("master_bills_%d.parquet", a),
           col_select = c("bill_id", "bill_no", "age", "proc_rslt", "proc_dt",
                          "vetoed", "veto_dt", "revote_dt", "alt_bill_id",
                          "alt_vetoed"))
}))
rc_kna <- read_kna("roll_calls_all.parquet") %>% filter(term == 22)

# Guard against an earlier kna release
stopifnot(
  all(c("term_number", "party_current") %in% names(members)),
  "party_api" %in% names(rc_kna),
  setequal(unique(edges$role), c("대표발의",
                                 "공동발의",
                                 "찬성"))
)

lead_role <- "대표발의"  # lead proposer
pr_seat <- "비례대표"    # proportional seat
female <- "여"

# Committees served in an assembly, comma-joined in order of first
# assignment, as in kna members_{age}$committee. Spells that began after
# the vintage date are left out of the 22nd assembly.
committee_strings <- assignments %>%
  filter(assembly %in% 20:22, assembly < 22 | start_day <= vintage) %>%
  group_by(mona_cd, assembly, committee) %>%
  summarise(first_day = min(start_day), first_row = min(row),
            .groups = "drop") %>%
  arrange(mona_cd, assembly, first_day, first_row) %>%
  group_by(mona_cd, assembly) %>%
  summarise(committees = paste(committee, collapse = ", "), .groups = "drop")

# ------------------------------------------------------------
# 1. bills: vetoed bills follow the re-vote; flag vetoes
# ------------------------------------------------------------
bill_fix <- masters %>%
  transmute(bill_no = as.integer(bill_no), proc_rslt,
            vetoed = vetoed == 1, veto_dt = as_day(veto_dt),
            revote_dt = as_day(revote_dt), alt_vetoed = alt_vetoed == 1)
b <- bills %>%
  select(-any_of(c("vetoed", "alt_vetoed"))) %>%
  left_join(bill_fix, by = "bill_no")
stopifnot(!anyNA(b$vetoed), nrow(b) == nrow(bills))
# Every veto and re-vote of these bills predates the vintage, so the final
# result in kna 0.7.0 is also the result as of March 2026.
stopifnot(all(b$veto_dt[b$vetoed] <= vintage),
          all(b$revote_dt[b$vetoed] <= vintage, na.rm = TRUE))
b$result[b$vetoed] <- b$proc_rslt[b$vetoed]
bills <- b %>%
  select(bill_id, bill_no, assembly, bill_name, committee, propose_date,
         result, proposer, proposer_id, vetoed, alt_vetoed) %>%
  as.data.frame()
cat("bills:", nrow(bills), "rows,", sum(bills$vetoed), "vetoed,",
    sum(bills$alt_vetoed), "absorbed into a vetoed alternative\n")

# ------------------------------------------------------------
# 2. get_proposers(): full co-sponsorship edges with roles
# ------------------------------------------------------------
# Edges of the bills in `bills`, joined on bill_no so that bill 2203215,
# re-keyed upstream after March 2026, keeps its bill_id in `bills`.
role_order <- c(lead_role, "공동발의", "찬성")
proposers <- edges %>%
  mutate(bill_no = as.integer(bill_no)) %>%
  inner_join(bills %>% select(bill_id, bill_no, bill_name, propose_date),
             by = "bill_no", suffix = c(".kna", "")) %>%
  mutate(role_rank = match(role, role_order)) %>%
  arrange(bill_no, role_rank) %>%
  transmute(bill_id, bill_no, bill_name, propose_date,
            proposer_name = member_name, proposer_party = party,
            member_id, role)
stopifnot(!anyDuplicated(proposers[c("bill_id", "member_id")]),
          setequal(proposers$bill_id, bills$bill_id))
cat("proposers:", nrow(proposers), "rows\n")

# ------------------------------------------------------------
# 3. legislators: seniority at that assembly, party at election,
#    committees and districts of that assembly, full bill counts
# ------------------------------------------------------------
m2022 <- members %>% filter(age %in% 20:22)

# Add 22nd members seated by the vintage date who are missing from the
# March 2026 roster (kyusik-yang/kna CORRECTIONS.md (e))
first_spell <- assignments %>%
  filter(assembly == 22) %>%
  group_by(mona_cd) %>%
  summarise(first_day = min(start_day), .groups = "drop")
added <- m2022 %>%
  filter(age == 22, !mona_cd %in% legislators$member_id[legislators$assembly == 22]) %>%
  inner_join(first_spell %>% filter(first_day <= vintage), by = "mona_cd") %>%
  transmute(
    member_id = mona_cd, assembly = as.integer(age), name = member_name,
    name_hanja = member_name_hanja, name_eng = member_name_eng,
    party_elected = party, party = coalesce(party_current, party_elected),
    district, district_type = NA_character_, committees = NA_character_,
    gender = if_else(sex == female, "F", "M"), birth_date = as.Date(birth_date),
    seniority = NA_integer_, n_bills = NA_integer_, n_bills_lead = NA_integer_
  )
cat("legislators: adding", nrow(added), "member(s):",
    paste(added$name, added$member_id), "\n")

bill_counts <- edges %>%
  filter(as.integer(bill_no) %in% bills$bill_no) %>%
  group_by(member_id, assembly = as.integer(age)) %>%
  summarise(n_bills = n_distinct(bill_id),
            n_bills_lead = sum(role == lead_role), .groups = "drop")

leg <- bind_rows(legislators, added) %>%
  left_join(m2022 %>% transmute(member_id = mona_cd, assembly = as.integer(age),
                                term_number, party_kna = party,
                                district_kna = district, election_type),
            by = c("member_id", "assembly")) %>%
  left_join(committee_strings, by = c("member_id" = "mona_cd", "assembly"),
            suffix = c("", ".kna")) %>%
  left_join(bill_counts, by = c("member_id", "assembly"),
            suffix = c("", ".kna"))
stopifnot(!anyNA(leg$term_number))
leg <- leg %>%
  mutate(
    seniority = as.integer(term_number),
    party_elected = party_kna,
    # 22nd districts keep the March 2026 roster, which gives the district
    # at the 2024 election
    district = ifelse(assembly < 22 | is.na(district), district_kna, district),
    district_type = ifelse(election_type == pr_seat | grepl("^비례", district),
                           "proportional", "constituency"),
    committees = coalesce(committees.kna, ""),
    n_bills = coalesce(n_bills.kna, 0L),
    n_bills_lead = coalesce(n_bills_lead.kna, 0L)
  )
legislators <- leg %>%
  select(member_id, assembly, name, name_hanja, name_eng, party,
         party_elected, district, district_type, committees, gender,
         birth_date, seniority, n_bills, n_bills_lead) %>%
  as.data.frame()
# Stable sort keeps the 0.1.3 order and places added members by name
legislators <- legislators[order(legislators$assembly, legislators$name,
                                 method = "radix"), ]
rownames(legislators) <- NULL
stopifnot(!anyDuplicated(legislators[c("member_id", "assembly")]))
cat("legislators:", nrow(legislators), "rows\n")

# ------------------------------------------------------------
# 4. roll_calls: add party at election; restore votes missing from the
#    March 2026 pull
# ------------------------------------------------------------
old_bills <- unique(roll_calls$bill_id)
rc_new <- rc_kna %>%
  filter(bill_id %in% old_bills) %>%
  anti_join(roll_calls, by = c("bill_id", "member_id")) %>%
  transmute(bill_id, assembly = as.integer(term), member_name, member_id,
            party = party_api, district, vote,
            vote_date = as.Date(substr(date, 1, 8), format = "%Y%m%d"))
cat("roll_calls: adding", nrow(rc_new), "rows\n")

rc <- bind_rows(roll_calls %>% select(-any_of("party_elected")), rc_new)
rc <- rc[order(rc$vote_date, rc$bill_id, method = "radix"), ]
elected22 <- m2022 %>% filter(age == 22) %>% select(member_id = mona_cd, party_elected = party)
rc <- rc %>% left_join(elected22, by = "member_id")
stopifnot(!anyNA(rc$party_elected),
          !anyDuplicated(rc[c("bill_id", "member_id")]),
          all(rc$member_id %in% legislators$member_id[legislators$assembly == 22]))
roll_calls <- rc %>%
  select(bill_id, assembly, member_name, member_id, party, party_elected,
         district, vote, vote_date) %>%
  as.data.frame()
rownames(roll_calls) <- NULL
cat("roll_calls:", nrow(roll_calls), "rows\n")

# ------------------------------------------------------------
# 5. seminars: member attributes of that assembly, by member_id
# ------------------------------------------------------------
province_map <- c(
  "서울" = "서울", "서울특별시" = "서울",
  "부산" = "부산", "부산광역시" = "부산",
  "대구" = "대구", "대구광역시" = "대구",
  "인천" = "인천", "인천광역시" = "인천",
  "광주" = "광주", "광주광역시" = "광주",
  "대전" = "대전", "대전광역시" = "대전",
  "울산" = "울산", "울산광역시" = "울산",
  "세종" = "세종", "세종특별자치시" = "세종",
  "세종특별자치시갑" = "세종",
  "세종특별자치시을" = "세종",
  "경기" = "경기", "경기도" = "경기",
  "강원" = "강원", "강원도" = "강원",
  "강원특별자치도" = "강원",
  "충북" = "충북", "충청북도" = "충북",
  "충남" = "충남", "충청남도" = "충남",
  "전북" = "전북", "전라북도" = "전북",
  "전북특별자치도" = "전북",
  "전남" = "전남", "전라남도" = "전남",
  "전남광주통합특별시" = "전남",
  "경북" = "경북", "경상북도" = "경북",
  "경남" = "경남", "경상남도" = "경남",
  "제주" = "제주", "제주도" = "제주",
  "제주특별자치도" = "제주"
)
term_attr <- members %>%
  transmute(
    member_id = mona_cd, assembly = age, term_number,
    proportional = election_type == pr_seat | grepl("^비례", district),
    prov = unname(province_map[sub(" .*$", "", district)])
  ) %>%
  mutate(prov = ifelse(proportional, NA_character_, prov))
stopifnot(!anyNA(term_attr$prov[!term_attr$proportional]))
member_attr <- members %>%
  group_by(member_id = mona_cd) %>%
  summarise(career_terms = max(term_number),
            female = all(sex == female), n_sex = n_distinct(sex),
            .groups = "drop")
stopifnot(all(member_attr$n_sex == 1))

sem <- seminars %>%
  left_join(term_attr, by = c("member_id", "assembly")) %>%
  left_join(member_attr, by = "member_id")
seminars <- sem %>%
  mutate(
    seniority = as.integer(term_number),
    is_female = female,
    is_proportional = proportional,
    is_seoul = prov %in% "서울" & !is.na(term_number),
    province = prov,
    total_terms = as.integer(career_terms)
  ) %>%
  mutate(is_seoul = ifelse(is.na(term_number), NA, is_seoul)) %>%
  select(name, member_id, year, assembly, party, camp, seniority,
         n_seminars, n_cross_party, cross_party_ratio, avg_coalition_size,
         is_governing, is_female, is_proportional, is_seoul, province,
         total_terms, n_bills_led) %>%
  as.data.frame()
cat("seminars:", nrow(seminars), "rows,", sum(!is.na(seminars$seniority)),
    "with member attributes of that assembly\n")

# ------------------------------------------------------------
# 6. speeches: member_id as MONA_CD; drop duplicated speeches
# ------------------------------------------------------------
# The minutes identify legislators by a numeric speaker ID, which 0.1.3
# stored in member_id. Keep it as speaker_id and attach the MONA_CD.
if (!"speaker_id" %in% names(speeches)) {
  speeches$speaker_id <- ifelse(speeches$member_id %in% c("nan", ""), NA,
                                speeches$member_id)
}
clean_name <- function(x) {
  x <- sub("^(대리|직무대행) ", "", x)
  sub(" 의원$", "", x)
}
# 22nd members seated before the end of the speech period
seated <- first_spell %>% filter(first_day <= max(speeches$date))
m22 <- members %>%
  filter(age == 22, mona_cd %in% seated$mona_cd) %>%
  select(member_name, mona_cd)
stopifnot(!anyDuplicated(m22$member_name))
id_map <- speeches %>%
  filter(!is.na(speaker_id)) %>%
  distinct(speaker_id, member_name = clean_name(speaker_name)) %>%
  left_join(m22, by = "member_name")
stopifnot(!anyDuplicated(id_map$speaker_id), !anyNA(id_map$mona_cd))
speeches$member_id <- id_map$mona_cd[match(speeches$speaker_id, id_map$speaker_id)]

# 신동욱's speeches on 2024-08-14 appear twice, under two speaker IDs
dup <- duplicated(speeches[setdiff(names(speeches), "speaker_id")])
dup_keys <- speeches[dup, c("date", "speech_order")]
speeches <- speeches[!dup, c("assembly", "date", "committee", "speaker",
                             "role", "speaker_name", "member_id",
                             "speaker_id", "speech_order", "speech")]
rownames(speeches) <- NULL
cat("speeches:", nrow(speeches), "rows,", nrow(dup_keys),
    "duplicated speeches dropped\n")

# The token file has both copies of each dropped speech, in order, so
# keep the first half of the token rows of each such key.
tokens <- as.data.frame(read_parquet("hosted-data/speech_tokens.parquet"))
if (nrow(dup_keys) > 0) {
  key <- paste(tokens$date, tokens$speech_order)
  drop <- logical(nrow(tokens))
  for (k in unique(paste(dup_keys$date, dup_keys$speech_order))) {
    idx <- which(key == k)
    n <- length(idx)
    stopifnot(n %% 2 == 0,
              identical(tokens$token[idx[1:(n / 2)]], tokens$token[idx[(n / 2 + 1):n]]))
    drop[idx[(n / 2 + 1):n]] <- TRUE
  }
  tokens <- tokens[!drop, ]
  cat("speech_tokens:", nrow(tokens), "rows after dropping", sum(drop), "\n")
}

# ------------------------------------------------------------
# Save
# ------------------------------------------------------------
save(legislators, file = "data/legislators.rda", compress = "xz")
save(bills,       file = "data/bills.rda",       compress = "xz")
save(roll_calls,  file = "data/roll_calls.rda",  compress = "xz")
save(seminars,    file = "data/seminars.rda",    compress = "xz")
save(speeches,    file = "data/speeches.rda",    compress = "xz")

write.csv(legislators, "inst/extdata/legislators.csv", row.names = FALSE,
          fileEncoding = "UTF-8")
write.csv(seminars, "inst/extdata/seminars.csv", row.names = FALSE,
          fileEncoding = "UTF-8")

# gzip, not zstd: CRAN's default arrow build lacks the zstd codec
write_parquet(proposers, "hosted-data/proposers.parquet", compression = "gzip")
if (nrow(dup_keys) > 0) {
  write_parquet(tokens, "hosted-data/speech_tokens.parquet",
                compression = "gzip")
}

for (f in c(list.files("data", pattern = "\\.rda$", full.names = TRUE),
            list.files("hosted-data", full.names = TRUE))) {
  cat(sprintf("  %s: %.1f KB\n", f, file.size(f) / 1024))
}
