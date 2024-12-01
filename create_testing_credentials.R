creds = list(
  client_id = "",
  client_secret = "",
  output_study = "",
  base_url = "https://data.castoredc.com",
  example_field = "",
  example_visit = "",
  example_participants = "",
  example_repeating_data = "",
  example_repeating_data_form = "",
  example_form = "",
  example_surveys = "",
  filter_vals = "dropdown"
)

castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)
entire_study <- castor_api$getStudyData(creds$output_study)
study_hash <- digest::digest(entire_study)

creds$study_hash <- study_hash

saveRDS(creds, file = "tests/testthat/testing_credentials.Rds")
