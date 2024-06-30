creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(
  key = creds$client_id,
  secret = creds$client_secret,
  base_url = creds$base_url
)

test_that("getStudyDataPointsBulk returns an appropriate object.", {
  study_data_points_bulk <- castor_api$getStudyDataPointsBulk(creds$output_study)

  expect_s3_class(study_data_points_bulk, "data.frame")
  expect_equal(nrow(study_data_points_bulk), 56)
  expect_equal(ncol(study_data_points_bulk), 4)
})

test_that("getStudyDataPointsBulk fails appropriately", {
  error <- expect_error(castor_api$getStudyDataPointsBulk("THISISNOTASTUDYID"))
  expect_match(error$message, "Error code: 404")
})


test_that("getStudyDataBulk returns an appropriate object.", {
  field_info <- castor_api$getFields(output_study)
  participant_info <- castor_api$getParticipants(output_study)
  study_data_bulk <- castor_api$getStudyDataBulk(creds$output_study, field_info, participant_info)

  expect_s3_class(study_data_bulk, "data.frame")
  expect_equal(nrow(study_data_bulk), 2)
  expect_equal(ncol(study_data_bulk), 57)
  expect_named(
    study_data_bulk,
    c(
      "participant_id",
      "archived",
      "randomisation_group" ,
      "randomisation_datetime" ,
      "institute" ,
      "base_bl_date",
      "base_bmi" ,
      "base_creat" ,
      "base_CRP" ,
      "base_date" ,
      "base_dbp" ,
      "base_gluc" ,
      "base_hb",
      "base_hr" ,
      "base_ht" ,
      "base_leucoc" ,
      "base_sbp" ,
      "base_tromboc" ,
      "base_urea" ,
      "base_weight",
      "conc_med" ,
      "fac_V_leiden" ,
      "fu_bl_date" ,
      "fu_bmi" ,
      "fu_creat" ,
      "fu_CRP" ,
      "fu_date",
      "fu_dbp" ,
      "fu_gluc" ,
      "fu_hb" ,
      "fu_hr" ,
      "fu_ht" ,
      "fu_leucoc" ,
      "fu_sbp",
      "fu_tromboc" ,
      "fu_urea" ,
      "fu_weight" ,
      "his_cvd" ,
      "his_diabetes" ,
      "his_family" ,
      "his_smoke",
      "ic_date" ,
      "ic_language" ,
      "ic_main_version" ,
      "ic_versions" ,
      "inc_age" ,
      "inc_criteria" ,
      "inc_dx",
      "inc_ic" ,
      "inc_trials" ,
      "onset_stroke" ,
      "onset_trombectomy" ,
      "pat_birth_year" ,
      "pat_height" ,
      "pat_race",
      "pat_sex" ,
      "unscheduled"
    )
  )
})

test_that("getStudyDataBulk fails appropriately", {
  field_info <- castor_api$getFields(output_study)
  participant_info <- castor_api$getParticipants(output_study)
  error <- expect_error(castor_api$getStudyDataBulk("THISISNOTASTUDYID", field_info, participant_info))
  expect_match(error$message, "Error code: 404")
})
