context("Test instantiation and authentication.")

test_that("Castor object instantiation produces valid R6 class object.", {
  creds <- readRDS("testing_credentials.Rds")
  castor_api <- CastorData$new(creds$user, creds$pw)

  expect_is(castor_api, "R6")
  expect_is(castor_api, "CastorData")
  expect_is(castor_api, "CastorAPIWrapper")
  expect_is(castor_api$getStudiesPages(), "list")
})