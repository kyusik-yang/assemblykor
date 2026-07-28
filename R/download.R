# Download a file to a temporary path first, then move it into the cache.
# Prevents a failed or partial download from being mistaken for a valid
# cached file on later calls. Returns TRUE on success, FALSE on failure
# (with a message, per CRAN policy on unavailable internet resources).
download_to_cache <- function(url, dest) {
  tmp <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp), add = TRUE)

  old_timeout <- getOption("timeout")
  options(timeout = max(300, old_timeout))
  on.exit(options(timeout = old_timeout), add = TRUE)

  status <- tryCatch(
    utils::download.file(url, tmp, mode = "wb", quiet = FALSE),
    error = function(e) conditionMessage(e),
    warning = function(w) conditionMessage(w)
  )

  ok <- is.numeric(status) && status == 0
  if (!ok || !file.exists(tmp) || file.size(tmp) == 0) {
    message("Download failed",
            if (is.character(status)) paste0(": ", status) else "",
            "\nPlease check your internet connection and try again.")
    return(FALSE)
  }

  file.copy(tmp, dest, overwrite = TRUE)
  TRUE
}


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
#' @return A data frame with 60,925 rows and 3 variables, or \code{NULL}
#'   (invisibly) if the download fails (e.g., no internet connection):
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
    if (!download_to_cache(url, dest)) return(invisible(NULL))
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
#' @return A data frame with 769,773 rows and 8 variables, or \code{NULL}
#'   (invisibly) if the download fails (e.g., no internet connection):
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
    if (!download_to_cache(url, dest)) return(invisible(NULL))
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


#' Download morpheme tokens for committee speeches
#'
#' Downloads a pre-tokenized version of the \code{\link{speeches}} dataset,
#' produced with the Kiwi morphological analyzer (via \code{kiwipiepy}).
#' Korean is an agglutinative language, so whitespace tokenization mixes
#' particles and verb endings into the tokens; morphological analysis
#' separates them and lemmatizes verbs and adjectives. This dataset lets
#' students work with proper Korean tokens without installing a
#' morphological analyzer. The file is approximately 1.3 MB and is cached
#' locally after the first download. Requires the \pkg{arrow} package.
#'
#' @inheritParams get_bill_texts
#'
#' @return A data frame with 665,055 rows and 4 variables, or \code{NULL}
#'   (invisibly) if the download fails (e.g., no internet connection):
#' \describe{
#'   \item{date}{Date of the committee meeting (links to
#'     \code{speeches$date})}
#'   \item{speech_order}{Speech turn within the meeting (links to
#'     \code{speeches$speech_order}); \code{date} + \code{speech_order}
#'     identifies one speech}
#'   \item{token}{Morpheme, in dictionary form. Verbs and adjectives are
#'     lemmatized (e.g., the stem plus \code{-da})}
#'   \item{pos}{Part-of-speech tag from the Sejong tagset: "NNG" (common
#'     noun), "NNP" (proper noun), "VV" (verb), "VA" (adjective),
#'     "MAG" (adverb), or "SL" (foreign word, e.g., "AI")}
#' }
#'
#' @details
#' Only content morphemes are included; particles (josa), verb endings
#' (eomi), and punctuation are removed. Function words carry little
#' topical meaning, so this is the usual starting point for keyword and
#' topic analysis. For noun-based analysis, filter to
#' \code{pos \%in\% c("NNG", "NNP")}.
#'
#' Join back to \code{\link{speeches}} with
#' \code{by = c("date", "speech_order")} to attach speaker metadata.
#' A small number of speeches (56 of 15,843) yield no content morphemes
#' and therefore do not appear.
#'
#' The tokenization script is in the package source repository under
#' \code{data-raw/tokenize_speeches.py}.
#'
#' @examples
#' \donttest{
#' if (requireNamespace("arrow", quietly = TRUE)) {
#'   tokens <- get_speech_tokens(cache_dir = tempdir())
#'
#'   # Most frequent nouns
#'   nouns <- tokens[tokens$pos %in% c("NNG", "NNP"), ]
#'   head(sort(table(nouns$token), decreasing = TRUE), 20)
#' }
#' }
#'
#' @seealso \code{\link{speeches}}
#'
#' @export
get_speech_tokens <- function(cache_dir = NULL, force_download = FALSE) {
  if (!requireNamespace("arrow", quietly = TRUE)) {
    stop("Package 'arrow' is required. Install with: install.packages('arrow')")
  }

  if (is.null(cache_dir)) {
    cache_dir <- tools::R_user_dir("assemblykor", "cache")
  }
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

  dest <- file.path(cache_dir, "speech_tokens.parquet")

  if (!file.exists(dest) || force_download) {
    url <- "https://github.com/kyusik-yang/assemblykor/raw/main/hosted-data/speech_tokens.parquet"
    message("Downloading speech tokens (~1.3 MB)...")
    if (!download_to_cache(url, dest)) return(invisible(NULL))
    message("Cached at: ", dest)
  } else {
    message("Using cached file: ", dest)
  }

  df <- arrow::read_parquet(dest)
  as.data.frame(df)
}
