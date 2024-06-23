# TODO: Needs updates to tests
context("Test Visit related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getVisit returns an appropriate object.", {
  visit <- castor_api$getVisit(creds$example_study, creds$example_visit)

  expect_is(visit, "list")
  expect_equal(visit$visit_id, creds$example_visit)
  expect_gt(length(visit), 0)
})

test_that("getVisitsPages returns an appropriate object.", {
  visits <- castor_api$getVisitsPages(creds$example_study)
  one_visit <- castor_api$getVisitsPages(creds$example_study, page = 1)

  expect_is(visits, "list")
  expect_is(one_visit, "list")
  expect_true(length(one_visit) == 1)
  expect_error(castor_api$getVisitsPages(creds$example_study, page = -1))
  expect_error(castor_api$getVisitsPages(creds$example_study, page = 100000000))
  expect_error(castor_api$getVisitsPages(creds$example_study, page = pi))
})

test_that("getVisits returns an appropriate object.", {
  visit_data <- castor_api$getVisits(creds$example_study)

  expect_is(visit_data, "data.frame")
  expect_gt(nrow(visit_data), 0)
  expect_gt(ncol(visit_data), 0)
  expect_error(castor_api$getVisits("this is not a study id"))
})
