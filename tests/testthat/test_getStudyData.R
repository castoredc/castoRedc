context("Test if the output of getStudyData matches the expected output.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)
complete_study_output <- castor_api$getStudyData(creds$output_study)

test_that("getStudyData returns the expected study data.", {
  actual <- complete_study_output$Study
  expected <- read.csv("tests/test_files/files_output/CastorStudy.csv", check.names=F)

  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Unscheduled Visit", {
  actual <- complete_study_output$`Repeating data`$`Unscheduled visit`
  expected <- read.csv("tests/test_files/files_output/CastorUnscheduledVisit.csv", check.names=F)

  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Medication", {
  actual <- complete_study_output$`Repeating data`$Medication
  expected <- read.csv("tests/test_files/files_output/CastorMedication.csv", check.names=F)

  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Comorbidities", {
  actual <- complete_study_output$`Repeating data`$Comorbidities
  expected <- read.csv("tests/test_files/files_output/CastorUnscheduledVisit.csv", check.names=F)

  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Adverse Events", {
  actual <- complete_study_output$`Repeating data`$`Adverse event`
  expected <- read.csv("tests/test_files/files_output/CastorAdverseEvent.csv", check.names=F)

  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the survey Quality of Life", {
  actual <- complete_study_output$Surveys$`QOL Survey`
  expected <- read.csv("tests/test_files/files_output/CastorQOLSurvey.csv", check.names=F)

  expect_identical(actual, expected)
})
