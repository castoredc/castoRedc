# TODO: Needs updates to tests
context("Test Study related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getStudy returns an appropriate object.", {
  study <- castor_api$getStudy(creds$example_study)

  expect_is(study, "list")
  expect_equal(study$study_id, creds$example_study)
  expect_gt(length(study), 0)
})

test_that("getStudiesPages returns an appropriate object.", {
  studies <- castor_api$getStudiesPages()
  one_study <- castor_api$getStudiesPages(page = 1)

  expect_is(studies, "list")
  expect_is(one_study, "list")
  expect_true(length(one_study) == 1)
  expect_error(castor_api$getStudiesPages(page = -1))
  expect_error(castor_api$getStudiesPages(page = 100000000))
  expect_error(castor_api$getStudiesPages(page = pi))
})

test_that("getStudies returns an appropriate object.", {
  study_data <- castor_api$getStudies()

  expect_is(study_data, "data.frame")
  expect_gt(nrow(study_data), 0)
  expect_gt(ncol(study_data), 0)
  expect_error(castor_api$getStudies("this is not a study id"))
})
