# ---- Function tests ----
# Verify exported utility functions work correctly.

# -- path_to_file ------------------------------------------------------

test_that("path_to_file lists available CSV files", {
  files <- path_to_file()
  expect_type(files, "character")
  expect_true(length(files) >= 3)
  expect_true("legislators.csv" %in% files)
  expect_true("wealth.csv" %in% files)
  expect_true("seminars.csv" %in% files)
})

test_that("path_to_file returns valid paths", {
  path <- path_to_file("legislators.csv")
  expect_type(path, "character")
  expect_true(file.exists(path))
  expect_true(grepl("legislators\\.csv$", path))
})

test_that("path_to_file errors on missing file", {
  expect_error(path_to_file("nonexistent.csv"))
})

# -- list_tutorials ----------------------------------------------------

test_that("list_tutorials returns tutorial names", {
  tutorials <- list_tutorials()
  expect_type(tutorials, "character")
  expect_equal(length(tutorials), 9)
  expect_true(all(grepl("\\.Rmd$", tutorials)))
  expect_true(any(grepl("tidyverse", tutorials)))
  expect_true(any(grepl("network", tutorials)))
})

# -- open_tutorial -----------------------------------------------------

test_that("open_tutorial copies file by number", {
  tmp <- tempdir()
  path <- open_tutorial(1, dest_dir = tmp)
  expect_true(file.exists(path))
  expect_true(grepl("01-tidyverse-basics\\.Rmd$", path))
  unlink(path)
})

test_that("open_tutorial copies file by name", {
  tmp <- tempdir()
  path <- open_tutorial("02-data-visualization", dest_dir = tmp)
  expect_true(file.exists(path))
  unlink(path)
})

test_that("open_tutorial errors on invalid number", {
  expect_error(open_tutorial(99))
  expect_error(open_tutorial(0))
})

test_that("open_tutorial errors on invalid name", {
  expect_error(open_tutorial("nonexistent-tutorial"))
})

# -- CSV files are readable --------------------------------------------

test_that("CSV files in extdata are valid", {
  for (f in path_to_file()) {
    path <- path_to_file(f)
    df <- read.csv(path, fileEncoding = "UTF-8", nrows = 5)
    expect_s3_class(df, "data.frame")
    expect_true(ncol(df) > 0)
  }
})

# -- get_proposers (offline, from a cached file) ------------------------

test_that("get_proposers reads the cached file layout", {
  skip_if_not_installed("arrow")
  cache <- file.path(tempdir(), "assemblykor-test-proposers")
  dir.create(cache, showWarnings = FALSE)
  on.exit(unlink(cache, recursive = TRUE), add = TRUE)

  # lead proposer, co-proposer, supporter
  roles <- c("\ub300\ud45c\ubc1c\uc758", "\uacf5\ub3d9\ubc1c\uc758",
             "\ucc2c\uc131")
  fake <- data.frame(
    bill_id = "PRC_TEST", bill_no = 2100001L, bill_name = "test bill",
    propose_date = as.Date("2020-06-01"),
    proposer_name = c("A", "B", "C"), proposer_party = "P",
    member_id = c("AAAAAAA1", "AAAAAAA2", "AAAAAAA3"), role = roles
  )
  arrow::write_parquet(fake, file.path(cache, "proposers_v2.parquet"))

  expect_message(props <- get_proposers(cache_dir = cache), "cached")
  expect_named(props, c("bill_id", "bill_no", "bill_name", "propose_date",
                        "proposer_name", "proposer_party", "member_id",
                        "is_lead", "role"))
  expect_equal(props$is_lead, c(TRUE, FALSE, FALSE))
  expect_equal(props$role, roles)
  expect_s3_class(props$propose_date, "Date")
})
