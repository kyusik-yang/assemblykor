# refresh_kna081.R
# Extends the 22nd-assembly data to release 0.8.1 of the kna project
# (https://github.com/kyusik-yang/kna, data as of 2026-09-23) and adds the
# asset disclosures of wealth_year 2025.
#
# kna070_corrections.R corrected the data as of March 2026. This script
# replaces every 22nd-assembly row of `bills`, `legislators`, `roll_calls`
# and `votes` with the kna 0.8.1 records, and rebuilds `wealth` from the kna
# asset panel, whose 2015-2024 rows equal the OpenWatch panel used so far.
# The 20th and 21st assemblies, `seminars`, `speeches` and the speech tokens
# are left as they are. It is idempotent, so running it again on its own
# output gives the same result.
#
# Run from the package root after kna070_corrections.R:
#   Rscript data-raw/refresh_kna081.R
#
# Input: kna 0.8.1 data/processed and data/raw. Set KNA_DATA_DIR to the
#   data/processed directory to override the default.
# Output: data/{bills,legislators,roll_calls,votes,wealth}.rda,
#   inst/extdata/legislators.csv,
#   hosted-data/proposers.parquet, hosted-data/bill_texts.parquet

library(arrow)
library(dplyr)

kna_dir <- Sys.getenv(
  "KNA_DATA_DIR",
  path.expand("~/Desktop/kyusik-github/kna/data/processed")
)
kna_raw <- file.path(dirname(kna_dir), "raw")

# Data as of the kna 0.8.1 collection
vintage <- as.Date("2026-09-23")

read_kna <- function(file, dir = kna_dir, ...) {
  as.data.frame(read_parquet(file.path(dir, file), ...))
}

# kna stores dates as UTC midnight
as_day <- function(x) as.Date(x, tz = "UTC")

load("data/bills.rda")
load("data/legislators.rda")
load("data/roll_calls.rda")
load("data/votes.rda")

law <- "법률안"          # 법률안
member_bill <- "의원"        # 의원
lead_role <- "대표발의"  # 대표발의
pr_seat <- "비례대표"    # 비례대표
female <- "여"                   # 여

# ------------------------------------------------------------
# kna 0.8.1 inputs
# ------------------------------------------------------------
master22 <- read_kna("master_bills_22.parquet",
                     col_select = c("bill_id", "bill_no", "bill_kind", "ppsr_kind",
                                    "bill_nm", "committee_nm", "ppsl_dt", "proc_rslt",
                                    "rst_proposer", "rst_mona_cd", "vetoed",
                                    "alt_vetoed"))
members22 <- read_kna("members_22.parquet")
assignments <- read_kna("committee_assignments.parquet") %>%
  filter(assembly == 22) %>%
  mutate(row = row_number(), start_day = as_day(start_date))
edges <- read_kna("cosponsorship_edges.parquet") %>% filter(age %in% 20:22)
rc_kna <- read_kna("roll_calls_all.parquet") %>% filter(term == 22)
tally22 <- read_kna("ncocpgfiaoituanbr_22.parquet", dir = kna_raw)
assets <- read_kna("assets_wealth_panel.parquet")
texts <- read_kna("bill_texts_linked.parquet")

# Guard against another kna release
stopifnot(
  all(c("party_current", "election_type", "term_number") %in% names(members22)),
  all(c("likms", "likms_absent") %in% rc_kna$source),
  max(assets$wealth_year) == 2025,
  "source" %in% names(texts)
)

# ------------------------------------------------------------
# 1. bills: 22nd member law bills proposed by the vintage date
# ------------------------------------------------------------
b22 <- master22 %>%
  filter(bill_kind == law, ppsr_kind == member_bill,
         as_day(ppsl_dt) <= vintage) %>%
  transmute(bill_id, bill_no = as.integer(bill_no), assembly = 22L,
            bill_name = bill_nm, committee = committee_nm,
            propose_date = as_day(ppsl_dt), result = proc_rslt,
            proposer = rst_proposer, proposer_id = rst_mona_cd,
            vetoed = vetoed == 1, alt_vetoed = alt_vetoed == 1)
stopifnot(!anyNA(b22$vetoed), !anyNA(b22$alt_vetoed))
bills <- bind_rows(bills %>% filter(assembly < 22), b22) %>%
  arrange(assembly, desc(bill_no)) %>%
  as.data.frame()
stopifnot(!anyDuplicated(bills$bill_id), !anyDuplicated(bills$bill_no))
cat("bills:", nrow(bills), "rows,", nrow(b22), "of the 22nd\n")

# ------------------------------------------------------------
# 2. get_proposers() and get_bill_texts(): hosted files for these bills
# ------------------------------------------------------------
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

# One row per bill. kna has no text for a few bills whose API record is
# empty, and they keep a row with a missing text.
bill_texts <- bills %>%
  select(bill_id) %>%
  left_join(texts %>% transmute(bill_id = BILL_ID, propose_reason,
                                scrape_status, source),
            by = "bill_id")
stopifnot(identical(bill_texts$bill_id, bills$bill_id))
cat("bill_texts:", nrow(bill_texts), "rows,",
    sum(!is.na(bill_texts$propose_reason) & nzchar(trimws(bill_texts$propose_reason))),
    "with a text\n")

# ------------------------------------------------------------
# 3. legislators: every member of the 22nd assembly seated by the vintage
# ------------------------------------------------------------
committee_strings <- assignments %>%
  filter(start_day <= vintage) %>%
  group_by(mona_cd, committee) %>%
  summarise(first_day = min(start_day), first_row = min(row), .groups = "drop") %>%
  arrange(mona_cd, first_day, first_row) %>%
  group_by(mona_cd) %>%
  summarise(committees = paste(committee, collapse = ", "), .groups = "drop")

bill_counts <- edges %>%
  filter(age == 22, bill_id %in% b22$bill_id) %>%
  group_by(member_id) %>%
  summarise(n_bills = n_distinct(bill_id),
            n_bills_lead = sum(role == lead_role), .groups = "drop")

# kna leaves a few English names empty, and has no current party for the
# members who have left the Assembly. Keep the earlier values for those.
prev <- legislators %>%
  filter(assembly == 22) %>%
  transmute(member_id,
            prev_name_eng = ifelse(!is.na(name_eng) & nzchar(name_eng), name_eng, NA),
            prev_party = party)

l22 <- members22 %>%
  left_join(committee_strings, by = "mona_cd") %>%
  left_join(bill_counts, by = c("mona_cd" = "member_id")) %>%
  left_join(prev, by = c("mona_cd" = "member_id")) %>%
  # party in kna is the party at election; keep it before `party` is reused
  mutate(elected = party,
         eng = ifelse(is.na(member_name_eng) | !nzchar(member_name_eng),
                      prev_name_eng, member_name_eng)) %>%
  transmute(
    member_id = mona_cd, assembly = 22L, name = member_name,
    name_hanja = member_name_hanja, name_eng = eng,
    party = coalesce(party_current, prev_party, elected), party_elected = elected,
    district,
    district_type = ifelse(election_type == pr_seat | grepl("^비례", district),
                           "proportional", "constituency"),
    committees = coalesce(committees, ""),
    gender = if_else(sex == female, "F", "M"),
    birth_date = as.Date(birth_date),
    seniority = as.integer(term_number),
    n_bills = coalesce(n_bills, 0L),
    n_bills_lead = coalesce(n_bills_lead, 0L)
  )
stopifnot(!anyNA(l22$seniority), !anyNA(l22$district), all(nzchar(l22$district)))
legislators <- bind_rows(legislators %>% filter(assembly < 22), l22)
legislators <- legislators[order(legislators$assembly, legislators$name,
                                 method = "radix"), ]
rownames(legislators) <- NULL
stopifnot(!anyDuplicated(legislators[c("member_id", "assembly")]))
cat("legislators:", nrow(legislators), "rows,", nrow(l22), "of the 22nd\n")

# ------------------------------------------------------------
# 4. roll_calls: the 22nd member-level votes of kna 0.8.1
# ------------------------------------------------------------
# party is the API label of the September 2026 collection (party_api);
# for the rows kna took from LIKMS it is the member's current party.
# district comes from `legislators`, because the API of September 2026
# gives the 2026 district names (e.g. 전남광주통합특별시) that did not exist
# at the 2024 election.
roll_calls <- rc_kna %>%
  left_join(l22 %>% select(member_id, leg_district = district), by = "member_id") %>%
  mutate(elected = party) %>%
  transmute(bill_id, assembly = 22L, member_name, member_id,
            party = party_api, party_elected = elected,
            district = leg_district, vote,
            vote_date = as.Date(substr(date, 1, 8), format = "%Y%m%d"))
roll_calls <- roll_calls[order(roll_calls$vote_date, roll_calls$bill_id,
                               method = "radix"), ]
rownames(roll_calls) <- NULL
stopifnot(!anyNA(roll_calls$vote_date), !anyNA(roll_calls$party_elected),
          !anyNA(roll_calls$district),
          !anyDuplicated(roll_calls[c("bill_id", "member_id")]),
          all(roll_calls$member_id %in% l22$member_id),
          max(roll_calls$vote_date) <= vintage)
cat("roll_calls:", nrow(roll_calls), "rows\n")

# ------------------------------------------------------------
# 5. votes: the 22nd bill-level tallies of the kna 0.8.1 collection
# ------------------------------------------------------------
v22 <- tally22 %>%
  transmute(
    bill_id = BILL_ID, bill_no = as.character(as.integer(BILL_NO)),
    bill_name = BILL_NAME, assembly = as.integer(AGE),
    committee = CURR_COMMITTEE, vote_date = as.Date(PROC_DT),
    result = PROC_RESULT_CD, bill_type = BILL_KIND_CD,
    total_members = as.integer(MEMBER_TCNT), voted = as.integer(VOTE_TCNT),
    yes = as.integer(YES_TCNT), no = as.integer(NO_TCNT),
    abstain = as.integer(BLANK_TCNT)
  ) %>%
  filter(vote_date <= vintage)
votes <- bind_rows(votes %>% filter(assembly < 22), v22) %>%
  arrange(assembly, vote_date) %>%
  as.data.frame()
cat("votes:", nrow(votes), "rows,", nrow(v22), "of the 22nd\n")

# ------------------------------------------------------------
# 6. wealth: the kna asset panel, wealth_year 2015-2025
# ------------------------------------------------------------
wealth <- assets %>%
  transmute(
    member_id = mona_cd, year = as.integer(wealth_year), name = member_name,
    total_assets, total_debt, net_worth,
    real_estate = total_realestate, building = total_building,
    land = total_land, deposits = total_deposits, stocks = total_stocks,
    n_properties = as.integer(n_properties_all),
    has_seoul_property = as.logical(has_seoul_re),
    has_gangnam_property = as.logical(has_gangnam_re)
  ) %>%
  arrange(member_id, year) %>%
  as.data.frame()
stopifnot(!anyDuplicated(wealth[c("member_id", "year")]))
cat("wealth:", nrow(wealth), "rows,", sum(wealth$year == 2025), "of wealth_year 2025\n")

# ------------------------------------------------------------
# Save
# ------------------------------------------------------------
save(bills,       file = "data/bills.rda",       compress = "xz")
save(legislators, file = "data/legislators.rda", compress = "xz")
save(roll_calls,  file = "data/roll_calls.rda",  compress = "xz")
save(votes,       file = "data/votes.rda",       compress = "xz")
save(wealth,      file = "data/wealth.rda",      compress = "xz")

write.csv(legislators, "inst/extdata/legislators.csv", row.names = FALSE,
          fileEncoding = "UTF-8")

# gzip, not zstd: CRAN's default arrow build lacks the zstd codec
write_parquet(proposers, "hosted-data/proposers.parquet", compression = "gzip")
write_parquet(bill_texts, "hosted-data/bill_texts.parquet", compression = "gzip")

for (f in c(list.files("data", pattern = "\\.rda$", full.names = TRUE),
            list.files("hosted-data", full.names = TRUE))) {
  cat(sprintf("  %s: %.1f KB\n", f, file.size(f) / 1024))
}
