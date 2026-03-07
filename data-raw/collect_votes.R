# collect_votes.R
# Collects plenary vote data from the National Assembly Open API.
# Requires: API key from https://open.assembly.go.kr
#
# Usage:
#   1. Get a free API key from the National Assembly Open Data Portal
#   2. Set it as environment variable: Sys.setenv(ASSEMBLY_API_KEY = "your_key")
#   3. Source this script: source("data-raw/collect_votes.R")
#
# Output:
#   data/votes.rda (~230 KB, bill-level vote tallies, 20-22nd assemblies)
#   data-raw/roll_calls_raw.csv (member-level roll calls, for parquet hosting)

library(httr)
library(jsonlite)
library(dplyr)

# --- Configuration ---
API_KEY <- Sys.getenv("ASSEMBLY_API_KEY")
if (nchar(API_KEY) == 0) {
  stop("Set your API key: Sys.setenv(ASSEMBLY_API_KEY = 'your_key')\n",
       "Get one free at https://open.assembly.go.kr")
}

BASE_URL <- "https://open.assembly.go.kr/portal/openapi"
EP_VOTE <- "ncocpgfiaoituanbr"           # Bill-level vote tallies
EP_MEMBER_VOTES <- "nojepdqqaweusdfbi"    # Member-level roll calls

# --- Helper function ---
# Note: API returns Content-Type: text/html even for JSON responses,
# so we must parse response text explicitly with fromJSON().
fetch_api <- function(endpoint, params, max_pages = 100) {
  all_rows <- list()
  page <- 1
  total <- NA

  while (page <= max_pages) {
    p <- c(list(KEY = API_KEY, Type = "json", pIndex = page, pSize = 1000), params)
    resp <- GET(paste0(BASE_URL, "/", endpoint), query = p,
                user_agent("assemblykor-r-package/0.1"))
    txt <- content(resp, as = "text", encoding = "UTF-8")

    # Check for top-level error
    if (grepl("ERROR-300", txt)) return(data.frame())

    data <- fromJSON(txt, simplifyVector = TRUE)
    body <- data[[endpoint]]
    if (is.null(body) || length(body) == 0) break

    # body is a data.frame: body$head[[1]] = header, body$row[[2]] = data
    head_df <- body$head[[1]]
    if (is.null(head_df)) break

    if (is.na(total)) {
      total <- as.integer(head_df$list_total_count[1])
      if (!is.na(total)) cat(sprintf("  Total records: %d\n", total))
    }

    rows <- body$row[[2]]
    if (is.null(rows) || nrow(rows) == 0) break
    all_rows[[page]] <- rows
    page <- page + 1

    if (!is.na(total) && length(all_rows) * 1000 >= total) break
    Sys.sleep(0.3)
  }

  if (length(all_rows) == 0) return(data.frame())
  bind_rows(all_rows)
}

# --- 1. Collect bill-level vote results (20-22nd assemblies) ---
cat("Collecting bill-level vote tallies...\n")
vote_list <- list()
for (age in c(20, 21, 22)) {
  cat(sprintf("\n  Assembly %d:\n", age))
  df <- fetch_api(EP_VOTE, list(AGE = age))
  if (nrow(df) > 0) {
    vote_list[[as.character(age)]] <- df
    cat(sprintf("  -> %d rows\n", nrow(df)))
  }
}
vote_results_raw <- bind_rows(vote_list)
cat("\nTotal vote results:", nrow(vote_results_raw), "\n")

votes <- vote_results_raw |>
  transmute(
    bill_id       = BILL_ID,
    bill_no       = as.integer(BILL_NO),
    bill_name     = BILL_NAME,
    assembly      = as.integer(AGE),
    committee     = CURR_COMMITTEE,
    vote_date     = as.Date(PROC_DT),
    result        = PROC_RESULT_CD,
    bill_type     = BILL_KIND_CD,
    total_members = as.integer(MEMBER_TCNT),
    voted         = as.integer(VOTE_TCNT),
    yes           = as.integer(YES_TCNT),
    no            = as.integer(NO_TCNT),
    abstain       = as.integer(BLANK_TCNT)
  ) |>
  arrange(assembly, vote_date) |>
  as.data.frame()

save(votes, file = "data/votes.rda", compress = "xz")
cat(sprintf("votes.rda: %.1f KB\n", file.size("data/votes.rda") / 1024))

# --- 2. Collect member-level roll calls (22nd assembly only) ---
# The nojepdqqaweusdfbi endpoint only has data for the 22nd assembly.
# For 20th-21st assemblies, only bill-level tallies are available.
cat("\nCollecting member-level roll calls (22nd assembly)...\n")

bill_ids <- unique(votes$bill_id[votes$assembly == 22])
cat("Bills to query:", length(bill_ids), "\n")
all_member_votes <- list()

for (i in seq_along(bill_ids)) {
  if (i %% 100 == 0) {
    n <- sum(sapply(all_member_votes, nrow))
    cat(sprintf("  Progress: %d/%d (%s rows)\n", i, length(bill_ids), format(n, big.mark = ",")))
  }

  result <- tryCatch(
    fetch_api(EP_MEMBER_VOTES, list(BILL_ID = bill_ids[i]), max_pages = 5),
    error = function(e) data.frame()
  )

  if (nrow(result) > 0) {
    all_member_votes[[length(all_member_votes) + 1]] <- result
  }
  Sys.sleep(0.15)
}

member_votes_raw <- bind_rows(all_member_votes)
cat("\nTotal member votes:", nrow(member_votes_raw), "\n")

roll_calls <- member_votes_raw |>
  transmute(
    bill_id     = BILL_ID,
    assembly    = as.integer(AGE),
    member_name = HG_NM,
    member_id   = MONA_CD,
    party       = POLY_NM,
    district    = ORIG_NM,
    vote        = RESULT_VOTE_MOD,
    vote_date   = as.Date(sub(" .*", "", VOTE_DATE), format = "%Y%m%d")
  ) |>
  arrange(assembly, vote_date, bill_id) |>
  as.data.frame()

cat("Cleaned roll_calls:", nrow(roll_calls), "rows\n")

# Save as CSV for parquet conversion (too large for built-in .rda)
write.csv(roll_calls, "data-raw/roll_calls_raw.csv", row.names = FALSE)
cat(sprintf("roll_calls_raw.csv: %.1f MB\n",
            file.size("data-raw/roll_calls_raw.csv") / (1024 * 1024)))
cat("\nTo host: convert to parquet and upload to GitHub release.\n")
