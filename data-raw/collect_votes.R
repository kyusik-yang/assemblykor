# collect_votes.R
# Collects plenary vote data from the National Assembly Open API.
# Requires: API key from https://open.assembly.go.kr
#
# Usage:
#   1. Get a free API key from the National Assembly Open Data Portal
#   2. Set it as environment variable: Sys.setenv(ASSEMBLY_API_KEY = "your_key")
#   3. Source this script: source("data-raw/collect_votes.R")
#
# Output: data/votes.rda (~1-3 MB)

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
EP_VOTE <- "ncocpgfiaoituanbr"         # Bill-level vote tallies
EP_MEMBER_VOTES <- "nojepdqqaweusdfbi"  # Member-level roll calls

# --- Helper function ---
fetch_api <- function(endpoint, params, max_pages = 100) {
  all_rows <- list()
  page <- 1
  total <- NA

  while (page <= max_pages) {
    p <- c(list(KEY = API_KEY, Type = "json", pIndex = page, pSize = 1000), params)
    resp <- GET(paste0(BASE_URL, "/", endpoint), query = p)
    data <- content(resp, as = "parsed", simplifyVector = TRUE)

    body <- data[[endpoint]]
    if (is.null(body) || length(body) == 0) break

    head_info <- body[[1]]$head
    if (is.null(head_info)) break

    if (is.na(total)) {
      total <- as.integer(head_info[[1]]$list_total_count)
      cat(sprintf("  Total records: %d\n", total))
    }

    code <- head_info[[2]]$RESULT$CODE
    if (code == "INFO-200") break  # no more data
    if (code != "INFO-000") {
      warning("API error: ", head_info[[2]]$RESULT$MESSAGE)
      break
    }

    rows <- body[[2]]$row
    if (is.null(rows) || nrow(rows) == 0) break
    all_rows[[page]] <- rows
    page <- page + 1

    if (length(all_rows) * 1000 >= total) break
    Sys.sleep(0.3)  # rate limiting
  }

  if (length(all_rows) == 0) return(data.frame())
  bind_rows(all_rows)
}

# --- 1. Collect bill-level vote results ---
cat("Collecting bill-level vote results...\n")
vote_list <- list()
for (age in c(19, 20, 21, 22)) {
  cat(sprintf("  Assembly %d:\n", age))
  df <- fetch_api(EP_VOTE, list(AGE = age))
  if (nrow(df) > 0) {
    df$assembly <- age
    vote_list[[as.character(age)]] <- df
  }
}
vote_results_raw <- bind_rows(vote_list)

cat("Total vote results:", nrow(vote_results_raw), "\n\n")

# --- 2. Collect member-level roll calls (22nd assembly sample) ---
# Full collection for all assemblies would be very large.
# Start with 22nd assembly bills that had recorded votes.
cat("Collecting member-level votes (22nd assembly)...\n")
bills_22 <- vote_results_raw |>
  filter(assembly == 22) |>
  pull(BILL_ID) |>
  unique()

cat("  Bills with votes:", length(bills_22), "\n")

member_votes_list <- list()
for (i in seq_along(bills_22)) {
  if (i %% 50 == 0) cat(sprintf("  Progress: %d/%d\n", i, length(bills_22)))
  df <- fetch_api(EP_MEMBER_VOTES, list(AGE = 22, BILL_ID = bills_22[i]),
                  max_pages = 5)
  if (nrow(df) > 0) {
    member_votes_list[[i]] <- df
  }
  Sys.sleep(0.2)
}
member_votes_raw <- bind_rows(member_votes_list)
cat("Total member votes:", nrow(member_votes_raw), "\n\n")

# --- 3. Clean and save ---

# Bill-level vote results
votes <- vote_results_raw |>
  transmute(
    bill_id    = BILL_ID,
    bill_name  = BILL_NAME,
    assembly   = as.integer(assembly),
    vote_date  = as.Date(VOTE_DATE),
    yes        = as.integer(YES_TCNT),
    no         = as.integer(NO_TCNT),
    abstain    = as.integer(BLANK_TCNT),
    result     = RESULT
  ) |>
  as.data.frame()

# Member-level roll calls (22nd assembly)
roll_calls <- member_votes_raw |>
  transmute(
    bill_id     = BILL_ID,
    bill_name   = BILL_NAME,
    member_name = HG_NM,
    party       = POLY_NM,
    vote        = RESULT_VOTE_MOD,  # 찬성/반대/기권/불참
    vote_date   = as.Date(VOTE_DATE)
  ) |>
  as.data.frame()

cat("Cleaned votes:", nrow(votes), "rows\n")
cat("Cleaned roll_calls:", nrow(roll_calls), "rows\n")

save(votes, file = "data/votes.rda", compress = "xz")
save(roll_calls, file = "data/roll_calls.rda", compress = "xz")

cat("\nSaved to data/votes.rda and data/roll_calls.rda\n")
cat("Don't forget to add documentation in R/data.R!\n")
