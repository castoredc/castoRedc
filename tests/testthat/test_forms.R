context("Test Form related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getForm returns an appropriate object.", {
  form <- castor_api$getForm(creds$example_study, creds$example_form)

  expect_is(form, "list")
  expect_equal(form$form_id, creds$example_form)
  expect_gt(length(form), 0)
})

test_that("getFormsPages returns an appropriate object.", {
  forms <- castor_api$getFormsPages(creds$example_study)
  one_form <- castor_api$getFormsPages(creds$example_study, page = 1)

  expect_is(forms, "list")
  expect_is(one_form, "list")
  expect_true(length(one_form) == 1)
  expect_error(castor_api$getFormsPages(creds$example_study, page = -1))
  expect_error(castor_api$getFormsPages(creds$example_study, page = 100000000))
  expect_error(castor_api$getFormsPages(creds$example_study, page = pi))
})

test_that("getForms returns an appropriate object.", {
  form_data <- castor_api$getForms(creds$example_study)

  expect_is(form_data, "data.frame")
  expect_gt(nrow(form_data), 0)
  expect_gt(ncol(form_data), 0)
  expect_error(castor_api$getForms("this is not a study id"))
})
