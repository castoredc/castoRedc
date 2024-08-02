creds <- readRDS("../testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)
study_output_nostudy <- castor_api$getStudyData(creds$output_study, load_study_data=FALSE)
study_output_nosurveys <- castor_api$getStudyData(creds$output_study, survey_instances=FALSE)
study_output_norepeatingdata <- castor_api$getStudyData(creds$output_study, repeating_data_instances=FALSE)

test_that("getStudyData returns the expected study data when omitting study data.", {
  actual <- study_output_nostudy$Study
  # if study data is omitted, we should only retrieve participant metadata
  expected <- read.csv("../../test_files/files_output/CastorStudy.csv", check.names=F)[c("participant_id", "archived", "institute", "randomisation_group", "randomisation_datetime")]
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected study data when omitting surveys.", {
  actual <- study_output_nosurveys$Study
  expected <- read.csv("../../test_files/files_output/CastorStudy.csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected study data when omitting repeating data.", {
  actual <- study_output_norepeatingdata$Study
  expected <- read.csv("../../test_files/files_output/CastorStudy.csv", check.names=F)
  expect_identical(actual, expected)
})



test_that("getStudyData returns the expected data for the repeated measure Unscheduled Visit when omitting study data", {
  actual <- study_output_nostudy$`Repeating data`$`Unscheduled visit`
  expected <- read.csv("../../test_files/files_output/CastorUnscheduledVisit.csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Unscheduled Visit when omitting surveys", {
  actual <- study_output_nosurveys$`Repeating data`$`Unscheduled visit`
  expected <- read.csv("../../test_files/files_output/CastorUnscheduledVisit.csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Unscheduled Visit when omitting repeated data", {
  actual <- study_output_norepeatingdata$`Repeating data`$`Unscheduled visit`
  expected <- NULL
  expect_identical(actual, expected)
})



test_that("getStudyData returns the expected data for the repeated measure Medication when omitting study data", {
  actual <- study_output_nostudy$`Repeating data`$Medication
  expected <- read.csv("../../test_files/files_output/CastorMedication.csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Medication when omitting surveys", {
  actual <- study_output_nosurveys$`Repeating data`$Medication
  expected <- read.csv("../../test_files/files_output/CastorMedication.csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Medication when omitting repeated data", {
  actual <- study_output_norepeatingdata$`Repeating data`$Medication
  expected <- NULL
  expect_identical(actual, expected)
})



test_that("getStudyData returns the expected data for the repeated measure Comorbidities when omitting study data", {
  actual <- study_output_nostudy$`Repeating data`$Comorbidities
  expected <- read.csv("../../test_files/files_output/CastorUnscheduledVisit.csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Comorbidities when omitting surveys", {
  actual <- study_output_nosurveys$`Repeating data`$Comorbidities
  expected <- read.csv("../../test_files/files_output/CastorUnscheduledVisit.csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Comorbidities when omitting repeated data", {
  actual <- study_output_norepeatingdata$`Repeating data`$Comorbidities
  expected <- NULL
  expect_identical(actual, expected)
})



test_that("getStudyData returns the expected data for the repeated measure Adverse Events when omitting study data", {
  actual <- study_output_nostudy$`Repeating data`$`Adverse event`
  expected <- read.csv("../../test_files/files_output/CastorAdverseEvent.csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Adverse Events when omitting surveys", {
  actual <- study_output_nosurveys$`Repeating data`$`Adverse event`
  expected <- read.csv("../../test_files/files_output/CastorAdverseEvent.csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the repeated measure Adverse Events when omitting repeated data", {
  actual <- study_output_norepeatingdata$`Repeating data`$`Adverse event`
  expected <- NULL
  expect_identical(actual, expected)
})



test_that("getStudyData returns the expected data for the survey Quality of Life when omitting study data", {
  actual <- study_output_nostudy$Surveys$`QOL Survey`
  expected <- read.csv("../../test_files/files_output/CastorQOLSurvey.csv", check.names=F)
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the survey Quality of Life when omitting surveys", {
  actual <- study_output_nosurveys$Surveys$`QOL Survey`
  expected <- NULL
  expect_identical(actual, expected)
})

test_that("getStudyData returns the expected data for the survey Quality of Life when omitting repeated data", {
  actual <- study_output_norepeatingdata$Surveys$`QOL Survey`
  expected <- read.csv("../../test_files/files_output/CastorQOLSurvey.csv", check.names=F)
  expect_identical(actual, expected)
})
