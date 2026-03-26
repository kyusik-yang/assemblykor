# ---- Dataset integrity tests ----
# Verify dimensions, column names, key uniqueness, and types
# for all seven built-in datasets.

# -- legislators -------------------------------------------------------

test_that("legislators has expected structure", {
  data(legislators, envir = environment())
  expect_s3_class(legislators, "data.frame")
  expect_equal(ncol(legislators), 15)
  expect_true(nrow(legislators) > 900)

  expected_cols <- c(
    "member_id", "assembly", "name", "name_hanja", "name_eng",
    "party", "party_elected", "district", "district_type",
    "committees", "gender", "birth_date", "seniority",
    "n_bills", "n_bills_lead"
  )
  expect_named(legislators, expected_cols)
})

test_that("legislators key columns are valid", {
  data(legislators, envir = environment())
  # member_id + assembly should be unique
  key <- paste(legislators$member_id, legislators$assembly)
  expect_equal(length(key), length(unique(key)))

  # assembly is one of 20, 21, 22
  expect_true(all(legislators$assembly %in% c(20, 21, 22)))

  # gender is M or F

  expect_true(all(legislators$gender %in% c("M", "F")))

  # district_type is one of two values
  expect_true(all(legislators$district_type %in%
                    c("constituency", "proportional")))
})

# -- bills -------------------------------------------------------------

test_that("bills has expected structure", {
  data(bills, envir = environment())
  expect_s3_class(bills, "data.frame")
  expect_equal(ncol(bills), 9)
  expect_true(nrow(bills) > 60000)

  expected_cols <- c(
    "bill_id", "bill_no", "assembly", "bill_name", "committee",
    "propose_date", "result", "proposer", "proposer_id"
  )
  expect_named(bills, expected_cols)
})

test_that("bills key columns are valid", {
  data(bills, envir = environment())
  expect_equal(length(bills$bill_id), length(unique(bills$bill_id)))
  expect_true(all(bills$assembly %in% c(20, 21, 22)))
  expect_s3_class(bills$propose_date, "Date")
})

# -- wealth ------------------------------------------------------------

test_that("wealth has expected structure", {
  data(wealth, envir = environment())
  expect_s3_class(wealth, "data.frame")
  expect_equal(ncol(wealth), 14)
  expect_true(nrow(wealth) > 2900)

  expected_cols <- c(
    "member_id", "year", "name", "total_assets", "total_debt",
    "net_worth", "real_estate", "building", "land", "deposits",
    "stocks", "n_properties", "has_seoul_property", "has_gangnam_property"
  )
  expect_named(wealth, expected_cols)
})

test_that("wealth key columns are valid", {
  data(wealth, envir = environment())
  # member_id + year should be unique
  key <- paste(wealth$member_id, wealth$year)
  expect_equal(length(key), length(unique(key)))
  expect_true(all(wealth$year >= 2015 & wealth$year <= 2025))
  expect_type(wealth$has_seoul_property, "logical")
  expect_type(wealth$has_gangnam_property, "logical")
})

# -- seminars ----------------------------------------------------------

test_that("seminars has expected structure", {
  data(seminars, envir = environment())
  expect_s3_class(seminars, "data.frame")
  expect_equal(ncol(seminars), 18)
  expect_true(nrow(seminars) > 5900)

  expected_cols <- c(
    "name", "member_id", "year", "assembly", "party", "camp",
    "seniority", "n_seminars", "n_cross_party", "cross_party_ratio",
    "avg_coalition_size", "is_governing", "is_female",
    "is_proportional", "is_seoul", "province", "total_terms",
    "n_bills_led"
  )
  expect_named(seminars, expected_cols)
})

test_that("seminars key columns are valid", {
  data(seminars, envir = environment())
  expect_true(all(seminars$assembly %in% 17:22))
  expect_type(seminars$is_governing, "logical")
  expect_true(all(seminars$cross_party_ratio >= 0 &
                    seminars$cross_party_ratio <= 1, na.rm = TRUE))
})

# -- speeches ----------------------------------------------------------

test_that("speeches has expected structure", {
  data(speeches, envir = environment())
  expect_s3_class(speeches, "data.frame")
  expect_equal(ncol(speeches), 9)
  expect_true(nrow(speeches) > 15000)

  expected_cols <- c(
    "assembly", "date", "committee", "speaker", "role",
    "speaker_name", "member_id", "speech_order", "speech"
  )
  expect_named(speeches, expected_cols)
})

test_that("speeches key columns are valid", {
  data(speeches, envir = environment())
  expect_true(all(speeches$assembly == 22))
  expect_s3_class(speeches$date, "Date")
  valid_roles <- c(
    "legislator", "chair", "minister", "vice_minister",
    "senior_bureaucrat", "agency_head", "witness", "expert_witness",
    "nominee", "minister_nominee", "testifier", "public_corp_head",
    "broadcasting", "committee_staff"
  )
  expect_true(all(speeches$role %in% valid_roles))
})

# -- votes -------------------------------------------------------------

test_that("votes has expected structure", {
  data(votes, envir = environment())
  expect_s3_class(votes, "data.frame")
  expect_equal(ncol(votes), 13)
  expect_true(nrow(votes) > 7900)

  expected_cols <- c(
    "bill_id", "bill_no", "bill_name", "assembly", "committee",
    "vote_date", "result", "bill_type", "total_members", "voted",
    "yes", "no", "abstain"
  )
  expect_named(votes, expected_cols)
})

test_that("votes key columns are valid", {
  data(votes, envir = environment())
  expect_true(all(votes$assembly %in% c(20, 21, 22)))
  expect_s3_class(votes$vote_date, "Date")
  # yes + no + abstain should not exceed voted
  expect_true(all(votes$yes + votes$no + votes$abstain <= votes$voted + 1,
                  na.rm = TRUE))
})

# -- roll_calls --------------------------------------------------------

test_that("roll_calls has expected structure", {
  data(roll_calls, envir = environment())
  expect_s3_class(roll_calls, "data.frame")
  expect_equal(ncol(roll_calls), 8)
  expect_true(nrow(roll_calls) > 360000)

  expected_cols <- c(
    "bill_id", "assembly", "member_name", "member_id",
    "party", "district", "vote", "vote_date"
  )
  expect_named(roll_calls, expected_cols)
})

test_that("roll_calls key columns are valid", {
  data(roll_calls, envir = environment())
  expect_true(all(roll_calls$assembly %in% c(20, 21, 22)))
  expect_s3_class(roll_calls$vote_date, "Date")
  # member_id + bill_id should be unique within each assembly
  key <- paste(roll_calls$assembly, roll_calls$member_id, roll_calls$bill_id)
  expect_equal(length(key), length(unique(key)))
})

# -- Cross-dataset join keys -------------------------------------------

test_that("join keys are compatible across datasets", {
  data(legislators, envir = environment())
  data(wealth, envir = environment())
  data(bills, envir = environment())
  data(votes, envir = environment())
  data(roll_calls, envir = environment())

  # wealth member_ids should largely exist in legislators
  overlap <- mean(wealth$member_id %in% legislators$member_id, na.rm = TRUE)
  expect_true(overlap > 0.5)

  # roll_calls member_ids should overlap with legislators
  rc_ids <- unique(roll_calls$member_id)
  leg_ids <- unique(legislators$member_id)
  overlap_rc <- mean(rc_ids %in% leg_ids)
  expect_true(overlap_rc > 0.8)
})
