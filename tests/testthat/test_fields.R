context("Test Field related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(creds$user, creds$pw)

test_that("getField returns an appropriate object.", {
  field <- castor_api$getField(creds$example_study, creds$example_field)

  expect_is(field, "list")
  expect_equal(field$field_id, creds$example_field)
  expect_gt(length(field), 0)
})

test_that("getFieldsPages returns an appropriate object.", {
  fields <- castor_api$getFieldsPages(creds$example_study)
  one_field <- castor_api$getFieldsPages(creds$example_study, page = 1)

  expect_is(fields, "list")
  expect_is(one_field, "list")
  expect_true(length(one_field) == 1)
  expect_error(castor_api$getFieldsPages(creds$example_study, page = -1))
  expect_error(castor_api$getFieldsPages(creds$example_study, page = 100000000))
  expect_error(castor_api$getFieldsPages(creds$example_study, page = pi))
})

test_that("getFields returns an appropriate object.", {
  field_data <- castor_api$getFields(creds$example_study)

  expect_is(field_data, "data.frame")
  expect_gt(nrow(field_data), 0)
  expect_gt(ncol(field_data), 0)
  expect_error(castor_api$getFields("this is not a study id"))
})