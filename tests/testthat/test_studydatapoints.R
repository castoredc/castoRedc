# Needs updates to tests
context("Test StudyDataPoint related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getStudyDataPoint returns an appropriate object.", {
  sdp <- castor_api$getStudyDataPoint(creds$example_study,
                                      creds$example_participant,
                                      creds$example_field)

  expect_is(sdp, "list")
  expect_equal(sdp$field_id, creds$example_field)
  expect_equal(sdp$participant_id, creds$example_participant)
  expect_gt(length(sdp), 0)
})

test_that("getStudyDataPointsPages returns an appropriate object.", {
  sdps <- castor_api$getStudyDataPointsPages(creds$example_study,
                                             creds$example_participant)
  one_sdp <- castor_api$getStudyDataPointsPages(creds$example_study,
                                                creds$example_participant,
                                                page = 1)

  expect_is(sdps, "list")
  expect_is(one_sdp, "list")
  expect_true(length(one_sdp) == 1)
  expect_error(castor_api$getStudyDataPointsPages(creds$example_study,
                                                  creds$example_participant,
                                                  page = -1))
  expect_error(castor_api$getStudyDataPointsPages(creds$example_study,
                                                  creds$example_participant,
                                                  page = 100000000))
  expect_error(castor_api$getStudyDataPointsPages(creds$example_study,
                                                  creds$example_participant,
                                                  page = pi))
})

test_that("getStudyDataPoints returns an appropriate object.", {
  sdp_data <- castor_api$getStudyDataPoints(creds$example_study,
                                            creds$example_participant,
                                            filter_types = creds$filter_vals)

  expect_is(sdp_data, "data.frame")
  expect_gt(nrow(sdp_data), 0)
  expect_gt(ncol(sdp_data), 0)
  expect_error(castor_api$getStudyDataPoints("this is not a study id",
                                             "this is not a participant id",
                                             filter_types = creds$filter_vals))
})
