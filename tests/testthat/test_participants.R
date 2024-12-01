creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getParticipant returns an appropriate object.", {
  participant <- castor_api$getParticipant(creds$output_study, creds$example_participant)

  expect_type(participant, "list")
  expect_equal(participant$participant_id, creds$example_participant)
  expect_gt(length(participant), 0)
})

test_that("getParticipant fails appropriately", {
  error <- expect_error(castor_api$getParticipant(creds$output_study, creds$fail_participant))
  expect_match(error$message, "Error code: 404")
})

test_that("getParticipantsPages returns an appropriate object.", {
  participants <- castor_api$getParticipantsPages(creds$output_study)
  expect_type(participants, "list")
})

test_that("getParticipantsPages returns an appropriate object when retrieving a single page.", {
  one_page <- castor_api$getParticipantsPages(creds$output_study, page = 1)
  expect_type(one_page, "list")
  expect_true(length(one_page) == 1)
})

test_that("getParticipantsPages fails appropriately", {
  error1 <- expect_error(castor_api$getParticipantsPages(creds$output_study, page = -1))
  expect_match(error1$message, "Error code: 400")

  error2 <- expect_error(castor_api$getParticipantsPages(creds$output_study, page = 100000000))
  expect_match(error2$message, "Error code: 409")

  error3 <- expect_error(castor_api$getParticipantsPages(creds$output_study, page = pi))
  expect_match(error3$message, "page must be an integer")
})

test_that("getParticipants returns an appropriate object.", {
  participant_data <- castor_api$getParticipants(creds$output_study)

  expect_s3_class(participant_data, "data.frame")
  expect_equal(nrow(participant_data), 2)
  expect_equal(ncol(participant_data), 34)
})

test_that("getParticipants returns an appropriate object when allowing archived.", {
  participant_data <- castor_api$getParticipants(creds$output_study, filter_archived = FALSE)

  expect_s3_class(participant_data, "data.frame")
  expect_equal(nrow(participant_data), 3)
  expect_equal(ncol(participant_data), 34)
})

test_that("getParticipants fails appropriately", {
  error <- expect_error(castor_api$getParticipants("THISISNOTASTUDYID"))
  expect_match(error$message, "Error code: 404")
})
