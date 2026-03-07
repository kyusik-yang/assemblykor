# prepare_data.R
# Reads source data from sibling projects and creates package .rda files.
# Run from the assemblykor package root directory.

library(arrow)
library(readr)
library(dplyr)

src <- "/Volumes/kyusik-ssd/kyusik-research/projects"
out <- "data"

# ------------------------------------------------------------
# 1. legislators: MP metadata (20th-22nd assemblies)
# Source: korean-assembly-bills/data/mp_metadata.parquet
# ------------------------------------------------------------
mp <- read_parquet(file.path(src, "korean-assembly-bills/data/mp_metadata.parquet"))

seniority_map <- c(
  "초선" = 1L, "재선" = 2L, "3선" = 3L, "4선" = 4L,
  "5선" = 5L, "6선" = 6L, "7선" = 7L, "8선" = 8L, "9선" = 9L
)

legislators <- mp |>
  transmute(
    member_id   = MONA_CD,
    assembly    = as.integer(`_age`),
    name        = HG_NM,
    name_hanja  = HJ_NM,
    name_eng    = ENG_NM,
    party       = POLY_NM,
    party_elected = ELECT_POLY_NM,
    district    = ORIG_NM,
    district_type = ifelse(ELECT_GBN_NM == "비례대표", "proportional", "constituency"),
    committees  = CMIT_NM,
    gender      = ifelse(SEX_GBN_NM == "남", "M", "F"),
    birth_date  = as.Date(BTH_DATE),
    seniority   = unname(seniority_map[REELE_GBN_NM]),
    n_bills     = as.integer(n_bills),
    n_bills_lead = as.integer(n_lead)
  ) |>
  as.data.frame()

cat("legislators:", nrow(legislators), "rows\n")

# ------------------------------------------------------------
# 2. bills: bill metadata (20th-22nd assemblies)
# Source: korean-assembly-bills/data/bills.parquet
# Keep only essential columns to stay under CRAN size limit.
# ------------------------------------------------------------
raw_bills <- read_parquet(file.path(src, "korean-assembly-bills/data/bills.parquet"))

bills <- raw_bills |>
  transmute(
    bill_id      = BILL_ID,
    bill_no      = as.integer(BILL_NO),
    assembly     = as.integer(AGE),
    bill_name    = BILL_NAME,
    committee    = COMMITTEE,
    propose_date = as.Date(PROPOSE_DT),
    result       = PROC_RESULT,
    proposer     = RST_PROPOSER,
    proposer_id  = RST_MONA_CD
  ) |>
  as.data.frame()

cat("bills:", nrow(bills), "rows\n")

# ------------------------------------------------------------
# 3. wealth: legislator asset declaration panel
# Source: legislator-assets-korea/data/processed/wealth_panel_openwatch.csv
# Units: thousands of KRW (1000 won)
# ------------------------------------------------------------
raw_wealth <- read_csv(
  file.path(src, "legislator-assets-korea/data/processed/wealth_panel_openwatch.csv"),
  show_col_types = FALSE
)

wealth <- raw_wealth |>
  transmute(
    member_id          = monaCode,
    year               = as.integer(wealth_year),
    name               = name,
    total_assets       = total_assets,
    total_debt         = total_debt,
    net_worth          = net_worth,
    real_estate        = total_realestate,
    building           = total_building,
    land               = total_land,
    deposits           = total_deposits,
    stocks             = total_stocks,
    n_properties       = as.integer(n_properties_all),
    has_seoul_property   = as.logical(has_seoul_re),
    has_gangnam_property = as.logical(has_gangnam_re)
  ) |>
  as.data.frame()

cat("wealth:", nrow(wealth), "rows\n")

# ------------------------------------------------------------
# 4. seminars: legislator-year policy seminar panel
# Source: na-legislative-events-korea/outputs/legislator_panel_v2.csv
# Coverage: 16th-22nd assemblies (2000-2025)
# ------------------------------------------------------------
raw_sem <- read_csv(
  file.path(src, "na-legislative-events-korea/outputs/legislator_panel_v2.csv"),
  show_col_types = FALSE
)

seminars <- raw_sem |>
  transmute(
    name              = name,
    year              = as.integer(year),
    assembly          = as.integer(term),
    party             = party,
    camp              = camp,
    seniority         = as.integer(seniority),
    n_seminars        = as.integer(n_events),
    n_cross_party     = as.integer(cross_events),
    cross_party_ratio = round(cross_party_ratio, 4),
    avg_coalition_size = round(avg_coalition, 2),
    is_governing      = as.logical(is_gov),
    is_female         = as.logical(is_female),
    is_proportional   = as.logical(is_pr),
    is_seoul          = as.logical(is_seoul),
    province          = province,
    total_terms       = as.integer(total_terms),
    n_bills_led       = as.integer(n_bills_led)
  ) |>
  as.data.frame()

cat("seminars:", nrow(seminars), "rows\n")

# ------------------------------------------------------------
# 5. speeches: committee speech sample
# Source: politician-wealth-embedding/data/processed/speeches_all.csv
# Stratified sample of 1,500 per assembly (16th-20th)
# Covers finance and infrastructure standing committees
# ------------------------------------------------------------
raw_speeches <- read_csv(
  file.path(src, "politician-wealth-embedding/data/processed/speeches_all.csv"),
  show_col_types = FALSE
)

set.seed(42)
speeches <- raw_speeches |>
  filter(nchar(speech) >= 50, !is.na(date_clean)) |>
  group_by(term) |>
  slice_sample(n = 1500) |>
  ungroup() |>
  transmute(
    assembly     = as.integer(term),
    date         = as.Date(date_clean),
    committee    = committee_clean,
    speaker      = speaker,
    speaker_name = sub("^.+ ([가-힣]{2,4})$", "\\1",
                    sub(" (위원|의원)$", "",
                    sub("^(위원장|부위원장|전문위원|수석전문위원|정부위원|국무위원) ", "", speaker))),
    speaker_id   = as.integer(member_id),
    speech_order = as.integer(speech_order),
    speech       = speech
  ) |>
  arrange(assembly, date, committee, speech_order) |>
  as.data.frame()

cat("speeches:", nrow(speeches), "rows\n")

# ------------------------------------------------------------
# Save all datasets as .rda with xz compression
# ------------------------------------------------------------
save(legislators, file = file.path(out, "legislators.rda"), compress = "xz")
save(bills,       file = file.path(out, "bills.rda"),       compress = "xz")
save(wealth,      file = file.path(out, "wealth.rda"),      compress = "xz")
save(seminars,    file = file.path(out, "seminars.rda"),     compress = "xz")
save(speeches,    file = file.path(out, "speeches.rda"),     compress = "xz")

# Report sizes
for (f in list.files(out, pattern = "\\.rda$", full.names = TRUE)) {
  cat(sprintf("  %s: %.1f KB\n", basename(f), file.size(f) / 1024))
}
cat("Total:", round(sum(file.size(list.files(out, pattern = "\\.rda$", full.names = TRUE))) / 1024), "KB\n")
