context("Test Record related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getRecord returns an appropriate object.", {
  record <- castor_api$getRecord(creds$example_study, creds$example_record)

  expect_is(record, "list")
  expect_equal(record$record_id, creds$example_record)
  expect_gt(length(record), 0)
})

test_that("getRecordsPages returns an appropriate object.", {
  records <- castor_api$getRecordsPages(creds$example_study)
  one_record <- castor_api$getRecordsPages(creds$example_study, page = 1)

  expect_is(records, "list")
  expect_is(one_record, "list")
  expect_true(length(one_record) == 1)
  expect_error(castor_api$getRecordsPages(creds$example_study, page = -1))
  expect_error(castor_api$getRecordsPages(creds$example_study, page = 100000000))
  expect_error(castor_api$getRecordsPages(creds$example_study, page = pi))
})

test_that("getRecords returns an appropriate object.", {
  record_data <- castor_api$getRecords(creds$example_study)

  expect_is(record_data, "data.frame")
  expect_gt(nrow(record_data), 0)
  expect_gt(ncol(record_data), 0)
  expect_error(castor_api$getRecords("this is not a stuy id"))
})
