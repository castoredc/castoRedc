creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(
  key = creds$client_id,
  secret = creds$client_secret,
  base_url = creds$base_url
)

test_that("getStudyDataPoints returns an appropriate object.", {
  study_data_points <- castor_api$getStudyDataPoints(creds$output_study, creds$example_participant)

  expect_s3_class(study_data_points, "data.frame")
  expect_equal(nrow(study_data_points), 1)
  expect_equal(ncol(study_data_points), 57)
  expect_named(
    study_data_points,
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
    ),
    ignore.order=T
  )
})

test_that("getStudyDataPoints fails appropriately", {
  error <- expect_error(castor_api$getStudyDataPoints("THISISNOTASTUDYID", creds$example_participant))
  expect_match(error$message, "Error code: 404")
})
