# TODO: Needs updates to tests
context("Test Survey related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getSurvey returns an appropriate object.", {
  survey <- castor_api$getSurvey(creds$example_study, creds$example_survey)

  expect_is(survey, "list")
  expect_equal(survey$survey_id, creds$example_survey)
  expect_gt(length(survey), 0)
})

test_that("getSurveysPages returns an appropriate object.", {
  surveys <- castor_api$getSurveysPages(creds$example_study)
  one_survey <- castor_api$getSurveysPages(creds$example_study, page = 1)

  expect_is(surveys, "list")
  expect_is(one_survey, "list")
  expect_true(length(one_survey) == 1)
  expect_error(castor_api$getSurveysPages(creds$example_study, page = -1))
  expect_error(castor_api$getSurveysPages(creds$example_study, page = 100000000))
  expect_error(castor_api$getSurveysPages(creds$example_study, page = pi))
})

test_that("getSurveys returns an appropriate object.", {
  survey_data <- castor_api$getSurveys(creds$example_study)

  expect_is(survey_data, "data.frame")
  expect_gt(nrow(survey_data), 0)
  expect_gt(ncol(survey_data), 0)
  expect_error(castor_api$getSurveys("this is not a study id"))
})
