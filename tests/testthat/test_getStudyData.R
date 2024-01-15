context("Test getStudyData in all its glory.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getStudyData returns an appropriate object.", {
  sdf <- castor_api$getStudyData(creds$example_study)

  expect_equal(creds$study_hash, digest::digest(sdf))
})
