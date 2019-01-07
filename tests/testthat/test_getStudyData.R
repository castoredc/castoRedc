context("Test getStudyData in all its glory.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(creds$user, creds$pw)

test_that("getStudyData returns an appropriate object.", {
  sdf <- castor_api$getStudyData(creds$example_study)

  expect_equal("9b9b04bd7a7de6e200ff7c83518ec991", digest::digest(sdf))
})
