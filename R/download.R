#' Download bill propose-reason texts
#'
#' Downloads the full propose-reason texts (jean-iyu) for all 60,925 bills.
#' The file is approximately 25 MB and is cached locally after the first
#' download. Requires the \pkg{arrow} package to read parquet files.
#'
#' @param cache_dir Directory to cache downloaded files. Defaults to
#'   \code{tools::R_user_dir("assemblykor", "cache")}.
#' @param force_download Logical. If \code{TRUE}, re-download even if cached.
#'
#' @return A data frame with 60,925 rows and 3 variables:
#' \describe{
#'   \item{bill_id}{Bill identifier (links to \code{bills$bill_id})}
#'   \item{propose_reason}{Full text of the propose-reason statement (Korean)}
#'   \item{scrape_status}{Data collection status: "ok", "empty", "no_csrf", or "error"}
#' }
#'
#' @examples
#' \donttest{
#' if (requireNamespace("arrow", quietly = TRUE)) {
#'   texts <- get_bill_texts(cache_dir = tempdir())
#'   nchar_dist <- nchar(texts$propose_reason)
#'   hist(nchar_dist, breaks = 100, main = "Length of Propose-Reason Texts")
#' }
#' }
#'
#' @export
get_bill_texts <- function(cache_dir = NULL, force_download = FALSE) {
  if (!requireNamespace("arrow", quietly = TRUE)) {
    stop("Package 'arrow' is required. Install with: install.packages('arrow')")
  }

  if (is.null(cache_dir)) {
    cache_dir <- tools::R_user_dir("assemblykor", "cache")
  }
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

  dest <- file.path(cache_dir, "bill_texts.parquet")

  if (!file.exists(dest) || force_download) {
    url <- "https://github.com/kyusik-yang/korean-assembly-bills/raw/main/data/bill_texts.parquet"
    message("Downloading bill texts (~25 MB)...")
    utils::download.file(url, dest, mode = "wb", quiet = FALSE)
    message("Cached at: ", dest)
  } else {
    message("Using cached file: ", dest)
  }

  df <- arrow::read_parquet(dest)
  colnames(df) <- c("bill_id", "propose_reason", "scrape_status")
  as.data.frame(df)
}


#' Download bill co-sponsorship records
#'
#' Downloads the complete proposer records (769,773 rows) listing every
#' legislator who co-sponsored each bill. Requires the \pkg{arrow} package.
#'
#' @inheritParams get_bill_texts
#'
#' @return A data frame with 769,773 rows and 8 variables:
#' \describe{
#'   \item{bill_id}{Bill identifier (links to \code{bills$bill_id})}
#'   \item{bill_no}{Numeric bill number}
#'   \item{bill_name}{Bill title in Korean}
#'   \item{propose_date}{Proposal date}
#'   \item{proposer_name}{Legislator name}
#'   \item{proposer_party}{Party affiliation at the time of co-sponsorship}
#'   \item{member_id}{Legislator identifier (links to \code{legislators$member_id})}
#'   \item{is_lead}{Logical: \code{TRUE} if lead (primary) proposer, \code{FALSE} if co-sponsor}
#' }
#'
#' @examples
#' \donttest{
#' if (requireNamespace("arrow", quietly = TRUE) &&
#'     requireNamespace("dplyr", quietly = TRUE)) {
#'   props <- get_proposers(cache_dir = tempdir())
#'
#'   # Build co-sponsorship edgelist
#'   leads <- dplyr::select(
#'     dplyr::filter(props, is_lead), bill_id, lead = member_id
#'   )
#'   cosponsors <- dplyr::select(
#'     dplyr::filter(props, !is_lead), bill_id, cosponsor = member_id
#'   )
#'   edges <- dplyr::inner_join(
#'     leads, cosponsors,
#'     by = "bill_id", relationship = "many-to-many"
#'   )
#' }
#' }
#'
#' @export
get_proposers <- function(cache_dir = NULL, force_download = FALSE) {
  if (!requireNamespace("arrow", quietly = TRUE)) {
    stop("Package 'arrow' is required. Install with: install.packages('arrow')")
  }

  if (is.null(cache_dir)) {
    cache_dir <- tools::R_user_dir("assemblykor", "cache")
  }
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

  dest <- file.path(cache_dir, "proposers.parquet")

  if (!file.exists(dest) || force_download) {
    url <- "https://github.com/kyusik-yang/korean-assembly-bills/raw/main/data/proposers.parquet"
    message("Downloading proposer records (~6 MB)...")
    utils::download.file(url, dest, mode = "wb", quiet = FALSE)
    message("Cached at: ", dest)
  } else {
    message("Using cached file: ", dest)
  }

  raw <- arrow::read_parquet(dest)

  df <- data.frame(
    bill_id        = raw$BILL_ID,
    bill_no        = as.integer(raw$BILL_NO),
    bill_name      = raw$BILL_NM,
    propose_date   = as.Date(raw$PPSL_DT),
    proposer_name  = raw$PPSR_NM,
    proposer_party = raw$PPSR_POLY_NM,
    member_id      = raw$NASS_CD,
    # "\ub300\ud45c\ubc1c\uc758" = lead proposer (Korean)
    is_lead        = !is.na(raw$REP_DIV) & raw$REP_DIV == "\ub300\ud45c\ubc1c\uc758",
    stringsAsFactors = FALSE
  )
  df
}
