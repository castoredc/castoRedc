context("Test StudyDataPoint related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(creds$user, creds$pw)

test_that("getStudyDataPoint returns an appropriate object.", {
  sdp <- castor_api$getStudyDataPoint(creds$example_study,
                                      creds$example_record,
                                      creds$example_field)

  expect_is(sdp, "list")
  expect_equal(sdp$field_id, creds$example_field)
  expect_equal(sdp$record_id, creds$example_record)
  expect_gt(length(sdp), 0)
})

test_that("getStudyDataPointsPages returns an appropriate object.", {
  sdps <- castor_api$getStudyDataPointsPages(creds$example_study,
                                             creds$example_record)
  one_sdp <- castor_api$getStudyDataPointsPages(creds$example_study,
                                                creds$example_record,
                                                page = 1)

  expect_is(sdps, "list")
  expect_is(one_sdp, "list")
  expect_true(length(one_sdp) == 1)
  expect_error(castor_api$getStudyDataPointsPages(creds$example_study,
                                                  creds$example_record,
                                                  page = -1))
  expect_error(castor_api$getStudyDataPointsPages(creds$example_study,
                                                  creds$example_record,
                                                  page = 100000000))
  expect_error(castor_api$getStudyDataPointsPages(creds$example_study,
                                                  creds$example_record,
                                                  page = pi))
})

test_that("getStudyDataPoints returns an appropriate object.", {
  sdp_data <- castor_api$getStudyDataPoints(creds$example_study,
                                            creds$example_record,
                                            filter_types = creds$filter_vals)

  expect_is(sdp_data, "data.frame")
  expect_gt(nrow(sdp_data), 0)
  expect_gt(ncol(sdp_data), 0)
  expect_error(castor_api$getStudyDataPoints("this is not a study id",
                                             "this is not a record id",
                                             filter_types = creds$filter_vals))
})