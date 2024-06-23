# TODO: Needs updates to tests
context("Test RepeatingData related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getRepeatingData returns an appropriate object.", {
  repeating_data <- castor_api$getRepeatingData(creds$example_study, creds$example_repeating_data)

  expect_is(repeating_data, "list")
  expect_equal(repeating_data$repeating_data_id, creds$example_repeating_data)
  expect_gt(length(repeating_data), 0)
})

test_that("getRepeatingDatasPages returns an appropriate object.", {
  repeating_datas <- castor_api$getRepeatingDatasPages(creds$example_study)
  one_repeating_data <- castor_api$getRepeatingDatasPages(creds$example_study, page = 1)

  expect_is(repeating_datas, "list")
  expect_is(one_repeating_data, "list")
  expect_true(length(one_repeating_data) == 1)
  expect_error(castor_api$getRepeatingDatasPages(creds$example_study, page = -1))
  expect_error(castor_api$getRepeatingDatasPages(creds$example_study,
                                          page = 100000000))
  expect_error(castor_api$getRepeatingDatasPages(creds$example_study, page = pi))
})

test_that("getRepeatingDatas returns an appropriate object.", {
  repeating_data_data <- castor_api$getRepeatingDatas(creds$example_study)

  expect_is(repeating_data_data, "data.frame")
  expect_gt(nrow(repeating_data_data), 0)
  expect_gt(ncol(repeating_data_data), 0)
  expect_error(castor_api$getRepeatingDatas("this is not a study id"))
})


test_that("getRepeatingDataForm returns an appropriate object.", {
  repeating_data_form <- castor_api$getRepeatingDataForm(creds$example_study,
                                          creds$example_repeating_data,
                                          creds$example_repeating_data_form)

  expect_is(repeating_data_form, "list")
  expect_equal(repeating_data_form$repeating_data_form_id, creds$example_repeating_data_form)
  expect_gt(length(repeating_data_form), 0)
})

test_that("getRepeatingDataFormsPages returns an appropriate object.", {
  repeating_data_forms <- castor_api$getRepeatingDataFormsPages(creds$example_study,
                                                 creds$example_repeating_data)
  one_repeating_data_form <- castor_api$getRepeatingDataFormsPages(creds$example_study,
                                                    creds$example_repeating_data,
                                                    page = 1)

  expect_is(repeating_data_forms, "list")
  expect_is(one_repeating_data_form, "list")
  expect_true(length(one_repeating_data_form) == 1)
  expect_error(castor_api$getRepeatingDataFormsPages(creds$example_study,
                                              creds$example_repeating_data,
                                              page = -1))
  expect_error(castor_api$getRepeatingDataFormsPages(creds$example_study,
                                              creds$example_repeating_data,
                                              page = 100000000))
  expect_error(castor_api$getRepeatingDataFormsPages(creds$example_study,
                                              creds$example_repeating_data,
                                              page = pi))
})

test_that("getRepeatingDataForms returns an appropriate object.", {
  repeating_data_form_data <- castor_api$getRepeatingDataForms(creds$example_study)

  expect_is(repeating_data_form_data, "data.frame")
  expect_gt(nrow(repeating_data_form_data), 0)
  expect_gt(ncol(repeating_data_form_data), 0)
  expect_error(castor_api$getRepeatingDataForms("this is not a study id"))
})
