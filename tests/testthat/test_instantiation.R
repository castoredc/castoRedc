# Needs updates to tests
context("Test instantiation and authentication.")

test_that("Castor object instantiation produces valid R6 class object.", {
  creds <- readRDS("testing_credentials.Rds")
  castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

  expect_is(castor_api, "R6")
  expect_is(castor_api, "CastorData")
  expect_is(castor_api, "CastorAPIWrapper")
  expect_is(castor_api$getStudiesPages(), "list")
})
