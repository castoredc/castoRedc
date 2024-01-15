context("Test Step related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getStep returns an appropriate object.", {
  step <- castor_api$getStep(creds$example_study, creds$example_step)

  expect_is(step, "list")
  expect_equal(step$step_id, creds$example_step)
  expect_gt(length(step), 0)
})

test_that("getStepsPages returns an appropriate object.", {
  steps <- castor_api$getStepsPages(creds$example_study)
  one_step <- castor_api$getStepsPages(creds$example_study, page = 1)

  expect_is(steps, "list")
  expect_is(one_step, "list")
  expect_true(length(one_step) == 1)
  expect_error(castor_api$getStepsPages(creds$example_study, page = -1))
  expect_error(castor_api$getStepsPages(creds$example_study, page = 100000000))
  expect_error(castor_api$getStepsPages(creds$example_study, page = pi))
})

test_that("getSteps returns an appropriate object.", {
  step_data <- castor_api$getSteps(creds$example_study)

  expect_is(step_data, "data.frame")
  expect_gt(nrow(step_data), 0)
  expect_gt(ncol(step_data), 0)
  expect_error(castor_api$getSteps("this is not a study id"))
})
