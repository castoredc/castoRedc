creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getField returns an appropriate object.", {
  field <- castor_api$getField(creds$output_study, creds$example_field)

  expect_is(field, "list")
  expect_equal(field$field_id, creds$example_field)
  expect_gt(length(field), 0)
})

test_that("getField fails appropriately", {
  error <- expect_error(castor_api$getField(creds$output_study, creds$fail_field))
  expect_match(error$message, "Error code: 404")
})


test_that("getFieldsPages returns an appropriate object.", {
  fields <- castor_api$getFieldsPages(creds$output_study)
  expect_type(fields, "list")
})

test_that("getFieldPages returns an appropriate object when retrieving a single page.", {
  one_page <- castor_api$getFieldsPages(creds$output_study, page = 1)
  expect_type(one_page, "list")
  expect_true(length(one_page) == 1)
})

test_that("getFieldPages fails appropriately", {
  error1 <- expect_error(castor_api$getFieldsPages(creds$output_study, page = -1))
  expect_match(error1$message, "Error code: 400")

  error2 <- expect_error(castor_api$getFieldsPages(creds$output_study, page = 100000000))
  expect_match(error2$message, "Error code: 409")

  error3 <- expect_error(castor_api$getFieldsPages(creds$output_study, page = pi))
  expect_match(error3$message, "page must be an integer")
})



test_that("getFields returns an appropriate object.", {
  field_data <- castor_api$getFields(creds$output_study)

  expect_s3_class(field_data, "data.frame")
  expect_equal(nrow(field_data), 115)
  expect_equal(ncol(field_data), 37)
})

test_that("getFields fails appropriately", {
  error <- expect_error(castor_api$getFields("THISISNOTASTUDYID"))
  expect_match(error$message, "Error code: 404")
})

