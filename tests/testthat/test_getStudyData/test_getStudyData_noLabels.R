creds <- readRDS("../testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)
complete_study_output <- castor_api$getStudyData(creds$output_study, translate_option_values = FALSE)

test_that("getStudyData returns the expected study data when not translating checkboxes.", {
  actual <- complete_study_output$Study
  expected <- read.csv("../../test_files/files_output/CastorStudy (noLabel).csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Unscheduled Visit when not translating checkboxes", {
  actual <- complete_study_output$`Repeating data`$`Unscheduled visit`
  expected <- read.csv("../../test_files/files_output/CastorUnscheduledVisit (noLabel).csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Medication when not translating checkboxes", {
  actual <- complete_study_output$`Repeating data`$Medication
  expected <- read.csv("../../test_files/files_output/CastorMedication (noLabel).csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Comorbidities when not translating checkboxes", {
  actual <- complete_study_output$`Repeating data`$Comorbidities
  expected <- read.csv("../../test_files/files_output/CastorUnscheduledVisit (noLabel).csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Adverse Events when not translating checkboxes", {
  actual <- complete_study_output$`Repeating data`$`Adverse event`
  expected <- read.csv("../../test_files/files_output/CastorAdverseEvent (noLabel).csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the survey Quality of Life when not translating checkboxes", {
  actual <- complete_study_output$Surveys$`QOL Survey`
  expected <- read.csv("../../test_files/files_output/CastorQOLSurvey (noLabel).csv", check.names=F)
  expect_identical(actual, expected)
})
