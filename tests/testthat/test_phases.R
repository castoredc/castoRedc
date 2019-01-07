context("Test Phase related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(creds$user, creds$pw)

test_that("getPhase returns an appropriate object.", {
  phase <- castor_api$getPhase(creds$example_study, creds$example_phase)

  expect_is(phase, "list")
  expect_equal(phase$phase_id, creds$example_phase)
  expect_gt(length(phase), 0)
})

test_that("getPhasesPages returns an appropriate object.", {
  phases <- castor_api$getPhasesPages(creds$example_study)
  one_phase <- castor_api$getPhasesPages(creds$example_study, page = 1)

  expect_is(phases, "list")
  expect_is(one_phase, "list")
  expect_true(length(one_phase) == 1)
  expect_error(castor_api$getPhasesPages(creds$example_study, page = -1))
  expect_error(castor_api$getPhasesPages(creds$example_study, page = 100000000))
  expect_error(castor_api$getPhasesPages(creds$example_study, page = pi))
})

test_that("getPhases returns an appropriate object.", {
  phase_data <- castor_api$getPhases(creds$example_study)

  expect_is(phase_data, "data.frame")
  expect_gt(nrow(phase_data), 0)
  expect_gt(ncol(phase_data), 0)
  expect_error(castor_api$getPhases("this is not a study id"))
})