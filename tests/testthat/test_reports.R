context("Test Report related methods.")

creds <- readRDS("testing_credentials.Rds")
castor_api <- CastorData$new(key=creds$client_id, secret=creds$client_secret, base_url=creds$base_url)

test_that("getReport returns an appropriate object.", {
  report <- castor_api$getReport(creds$example_study, creds$example_report)

  expect_is(report, "list")
  expect_equal(report$report_id, creds$example_report)
  expect_gt(length(report), 0)
})

test_that("getReportsPages returns an appropriate object.", {
  reports <- castor_api$getReportsPages(creds$example_study)
  one_report <- castor_api$getReportsPages(creds$example_study, page = 1)

  expect_is(reports, "list")
  expect_is(one_report, "list")
  expect_true(length(one_report) == 1)
  expect_error(castor_api$getReportsPages(creds$example_study, page = -1))
  expect_error(castor_api$getReportsPages(creds$example_study,
                                          page = 100000000))
  expect_error(castor_api$getReportsPages(creds$example_study, page = pi))
})

test_that("getReports returns an appropriate object.", {
  report_data <- castor_api$getReports(creds$example_study)

  expect_is(report_data, "data.frame")
  expect_gt(nrow(report_data), 0)
  expect_gt(ncol(report_data), 0)
  expect_error(castor_api$getReports("this is not a study id"))
})


test_that("getReportStep returns an appropriate object.", {
  report_step <- castor_api$getReportStep(creds$example_study,
                                          creds$example_report,
                                          creds$example_report_step)

  expect_is(report_step, "list")
  expect_equal(report_step$report_step_id, creds$example_report_step)
  expect_gt(length(report_step), 0)
})

test_that("getReportStepsPages returns an appropriate object.", {
  report_steps <- castor_api$getReportStepsPages(creds$example_study,
                                                 creds$example_report)
  one_report_step <- castor_api$getReportStepsPages(creds$example_study,
                                                    creds$example_report,
                                                    page = 1)

  expect_is(report_steps, "list")
  expect_is(one_report_step, "list")
  expect_true(length(one_report_step) == 1)
  expect_error(castor_api$getReportStepsPages(creds$example_study,
                                              creds$example_report,
                                              page = -1))
  expect_error(castor_api$getReportStepsPages(creds$example_study,
                                              creds$example_report,
                                              page = 100000000))
  expect_error(castor_api$getReportStepsPages(creds$example_study,
                                              creds$example_report,
                                              page = pi))
})

test_that("getReportSteps returns an appropriate object.", {
  report_step_data <- castor_api$getReportSteps(creds$example_study)

  expect_is(report_step_data, "data.frame")
  expect_gt(nrow(report_step_data), 0)
  expect_gt(ncol(report_step_data), 0)
  expect_error(castor_api$getReportSteps("this is not a study id"))
})
