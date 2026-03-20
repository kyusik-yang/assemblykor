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
