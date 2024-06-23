# Needs updates to tests
context("Test Participant related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getParticipant returns an appropriate object.", {
  participant <- castor_api$getParticipant(creds$example_study, creds$example_participant)

  expect_is(participant, "list")
  expect_equal(participant$participant_id, creds$example_participant)
  expect_gt(length(participant), 0)
})

test_that("getParticipantsPages returns an appropriate object.", {
  participants <- castor_api$getParticipantsPages(creds$example_study)
  one_participant <- castor_api$getParticipantsPages(creds$example_study, page = 1)

  expect_is(participants, "list")
  expect_is(one_participant, "list")
  expect_true(length(one_participant) == 1)
  expect_error(castor_api$getParticipantsPages(creds$example_study, page = -1))
  expect_error(castor_api$getParticipantsPages(creds$example_study, page = 100000000))
  expect_error(castor_api$getParticipantsPages(creds$example_study, page = pi))
})

test_that("getParticipants returns an appropriate object.", {
  participant_data <- castor_api$getParticipants(creds$example_study)

  expect_is(participant_data, "data.frame")
  expect_gt(nrow(participant_data), 0)
  expect_gt(ncol(participant_data), 0)
  expect_error(castor_api$getParticipants("this is not a stuy id"))
})
