creds = list(
  client_id = "",
  client_secret = "",
  example_study = "",
  base_url = "https://data.castoredc.com",
  example_field = "",
  example_phase = "",
  example_records = "",
  example_report = "",
  example_report_step = "",
  example_step = "",
  example_surveys = "",
  filter_vals = "dropdown"
)

castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)
study_hash <- digest::digest(castor_api$getStudyData(creds$example_study))

creds$study_hash <- study_hash

saveRDS(creds, file = "tests/testthat/testing_credentials.Rds")
