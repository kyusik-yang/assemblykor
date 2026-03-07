#' Path to assemblykor CSV files
#'
#' Returns the file path to CSV versions of the built-in datasets stored
#' in \code{inst/extdata}. Useful for teaching file I/O with
#' \code{read.csv()} or \code{readr::read_csv()}.
#'
#' @param file Name of the CSV file. One of \code{"legislators.csv"},
#'   \code{"wealth.csv"}, or \code{"seminars.csv"}.
#'
#' @return A character string with the full file path.
#'
#' @examples
#' # Read data from CSV (alternative to data())
#' path <- path_to_file("legislators.csv")
#' legislators_csv <- read.csv(path, fileEncoding = "UTF-8")
#' head(legislators_csv)
#'
#' @export
path_to_file <- function(file = NULL) {
  if (is.null(file)) {
    dir(system.file("extdata", package = "assemblykor"))
  } else {
    system.file("extdata", file, package = "assemblykor", mustWork = TRUE)
  }
}


#' List available tutorials
#'
#' Lists the tutorial R Markdown files included with the package.
#' Tutorials are designed for classroom use in Korean political science
#' methods courses. Each tutorial is available in two formats:
#' \enumerate{
#'   \item Plain Rmd for editing in RStudio (\code{\link{open_tutorial}})
#'   \item Interactive \pkg{learnr} format (\code{\link{run_tutorial}})
#' }
#'
#' @return A character vector of tutorial file names (invisibly).
#'
#' @examples
#' list_tutorials()
#'
#' @export
list_tutorials <- function() {
  files <- dir(system.file("rmd-tutorials", package = "assemblykor"),
               pattern = "\\.Rmd$")
  if (length(files) == 0) {
    message("No tutorials found.")
    return(invisible(character(0)))
  }
  cat("Available tutorials:\n\n")
  for (f in files) {
    cat("  ", f, "\n")
  }
  cat("\nUsage:\n")
  cat("  open_tutorial(1)       # Copy Rmd to working directory\n")
  cat("  run_tutorial(1)        # Launch interactive version in browser\n")
  invisible(files)
}


#' Open a tutorial file
#'
#' Copies a tutorial R Markdown file to the specified directory (default:
#' current working directory) so students can edit and run it in RStudio.
#'
#' @param name Tutorial name (with or without .Rmd extension), or a number
#'   corresponding to the tutorial order (1-6).
#' @param dest_dir Directory to copy the file to. Defaults to the current
#'   working directory.
#'
#' @return The path to the copied file (invisibly).
#'
#' @seealso \code{\link{run_tutorial}} for the interactive browser version.
#'
#' @examples
#' \dontrun{
#' # Copy by name
#' open_tutorial("01-tidyverse-basics")
#'
#' # Copy by number
#' open_tutorial(1)
#' }
#'
#' @export
open_tutorial <- function(name, dest_dir = getwd()) {
  tutorials <- dir(system.file("rmd-tutorials", package = "assemblykor"),
                   pattern = "\\.Rmd$")

  if (is.numeric(name)) {
    if (name < 1 || name > length(tutorials)) {
      stop("Tutorial number must be between 1 and ", length(tutorials),
           ". Use list_tutorials() to see available tutorials.")
    }
    file <- tutorials[name]
  } else {
    if (!grepl("\\.Rmd$", name)) name <- paste0(name, ".Rmd")
    file <- tutorials[tutorials == name]
    if (length(file) == 0) {
      stop("Tutorial '", name, "' not found. Use list_tutorials() to see available tutorials.")
    }
  }

  src <- system.file("rmd-tutorials", file, package = "assemblykor")
  dest <- file.path(dest_dir, file)

  if (file.exists(dest)) {
    message("File already exists: ", dest)
    message("Overwriting...")
  }

  file.copy(src, dest, overwrite = TRUE)
  message("Tutorial copied to: ", dest)
  invisible(dest)
}


#' Run an interactive tutorial
#'
#' Launches a \pkg{learnr} interactive tutorial in the browser. Students
#' can type and run code directly in the browser with hints and solutions.
#' Requires the \pkg{learnr} package.
#'
#' @param name Tutorial name or number (1-6). Use \code{\link{list_tutorials}}
#'   to see available tutorials.
#'
#' @seealso \code{\link{open_tutorial}} for the plain Rmd version.
#'
#' @examples
#' \dontrun{
#' run_tutorial(1)  # Launch tutorial 1 in browser
#' }
#'
#' @export
run_tutorial <- function(name) {
  if (!requireNamespace("learnr", quietly = TRUE)) {
    stop("Package 'learnr' is required. Install with: install.packages('learnr')")
  }

  tutorials <- dir(system.file("rmd-tutorials", package = "assemblykor"),
                   pattern = "\\.Rmd$")
  if (is.numeric(name)) {
    if (name < 1 || name > length(tutorials)) {
      stop("Tutorial number must be between 1 and ", length(tutorials))
    }
    tut_name <- sub("\\.Rmd$", "", tutorials[name])
  } else {
    tut_name <- sub("\\.Rmd$", "", name)
  }

  learnr::run_tutorial(tut_name, package = "assemblykor")
}
