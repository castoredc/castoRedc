
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Castor API R Package

The intent of this package is to provide convenient access to study data
in Castor via R.

## Package Structure

Access to data in the API comes in three forms:

1.  Access to individual items (getStudyDataPoint, getStudy, getRecord,
    etc.)
2.  Access to pages of items in a list (getStudyDataPoints, getStudies,
    getRecords, etc.)
3.  Processed into a data frame for straightforward analysis
    (getStudyData)

## Installation

``` r
# install.packages("remotes")
remotes::install_github("castoredc/castoRedc")
```

## Missing data

In the package, user missing data is handled in the following way. For
date variables, they are represented by 31-12-29XX, where XX (95-99)
indicates the type of missing data. For numeric variables, they are
represented by the values -99 to -95, where 95 to 99 represent the type
of missing data in Castor. For non-numeric variables, they are
represented by \##\_USER_MISSING_XX## where XX (95-99) indicates the
type of missing data.

## Testing

If you want to test the package, for example when developing, please
fill in create_testing_credentials.R.  
You should supply an example for each of the study, report, etc. Please
make sure that the record has a value in the field. And that the report
step is a child of the report.

## Usage

See
<https://helpdesk.castoredc.com/article/124-application-programming-interface-api>
about generating your credentials.

*Note: It is recommended that you read
<https://cran.r-project.org/web/packages/httr/vignettes/secrets.html>
about managing your credentials.*

``` r
library(castoRedc)

castor_api <- CastorData$new(key = credentials$client_id, 
                             secret = credentials$client_secret, 
                             base_url = "https://data.castoredc.com")
```

``` r
studies <- castor_api$getStudies()
```

| crf_id                               | study_id                             | name                               | created_by                           | created_on          | trial_registry_id | live | randomization_enabled | gcp_enabled | surveys_enabled | premium_support_enabled | main_contact                         | expected_centers | expected_records | slug                   | version | duration | domain                       | \_links.self.href                                                           |
|:-------------------------------------|:-------------------------------------|:-----------------------------------|:-------------------------------------|:--------------------|:------------------|:-----|:----------------------|:------------|:----------------|:------------------------|:-------------------------------------|-----------------:|-----------------:|:-----------------------|:--------|---------:|:-----------------------------|:----------------------------------------------------------------------------|
| 15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88 | 15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88 | PythonWrapperTest - Study          | B23ABCC4-3A53-FB32-7B78-3960CC907F25 | 2021-06-22 07:50:12 |                   | TRUE | FALSE                 | TRUE        | TRUE            | FALSE                   | B23ABCC4-3A53-FB32-7B78-3960CC907F25 |                1 |              180 | ESXnzDc2zuKJ7fFjEnUCu5 | 0.21    |       12 | <https://data.castoredc.com> | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88> |
| 1BCD52D3-7AB3-4EA9-8ABE-74B4B7087001 | 1BCD52D3-7AB3-4EA9-8ABE-74B4B7087001 | PythonWrapperTest - Client (Write) | B23ABCC4-3A53-FB32-7B78-3960CC907F25 | 2022-06-28 07:13:41 |                   | TRUE | TRUE                  | TRUE        | TRUE            | FALSE                   | B23ABCC4-3A53-FB32-7B78-3960CC907F25 |                1 |              100 | 8pDFJAdy4m3Kf8fZEMRxw6 | 0.01    |       24 | <https://data.castoredc.com> | <https://data.castoredc.com/api/study/1BCD52D3-7AB3-4EA9-8ABE-74B4B7087001> |
| C6073904-2B46-4F38-B359-A455FC255920 | C6073904-2B46-4F38-B359-A455FC255920 | PythonWrapperTest - Import         | B23ABCC4-3A53-FB32-7B78-3960CC907F25 | 2021-03-12 12:47:30 |                   | TRUE | FALSE                 | FALSE       | TRUE            | FALSE                   | B23ABCC4-3A53-FB32-7B78-3960CC907F25 |                1 |               50 | ThTvYFAxJFodP35aATLKFd | 0.21    |       27 | <https://data.castoredc.com> | <https://data.castoredc.com/api/study/C6073904-2B46-4F38-B359-A455FC255920> |
| D234215B-D956-482D-BF17-71F2BB12A2FD | D234215B-D956-482D-BF17-71F2BB12A2FD | PythonWrapperTest - Client         | B23ABCC4-3A53-FB32-7B78-3960CC907F25 | 2019-09-23 08:12:48 |                   | TRUE | TRUE                  | TRUE        | TRUE            | FALSE                   | B23ABCC4-3A53-FB32-7B78-3960CC907F25 |                2 |               50 | python-wrapper         | 0.61    |       15 | <https://data.castoredc.com> | <https://data.castoredc.com/api/study/D234215B-D956-482D-BF17-71F2BB12A2FD> |
| D82A17DE-E280-4D69-B96A-4399872BBECC | D82A17DE-E280-4D69-B96A-4399872BBECC | PythonWrapperTest - SpecialCases   | B23ABCC4-3A53-FB32-7B78-3960CC907F25 | 2022-01-03 13:52:27 |                   | TRUE | FALSE                 | TRUE        | TRUE            | FALSE                   | B23ABCC4-3A53-FB32-7B78-3960CC907F25 |                1 |              500 | p8CPbd2rnbBFkb2oW5GFUg | 1.11    |       60 | <https://data.castoredc.com> | <https://data.castoredc.com/api/study/D82A17DE-E280-4D69-B96A-4399872BBECC> |

``` r
(example_study_id <- studies[["study_id"]][1])
#> [1] "15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88"
```

``` r
study <- castor_api$getStudyData(example_study_id)
```

<table class="kable_wrapper">
<tbody>
<tr>
<td>

| Participant_ID | Site_Abbreviation | Randomization_Group | Participant_Creation | ic_date    | ic_versions#Other | ic_versions#Main study CF | ic_main_version | ic_language#English | ic_language#Dutch |
|:---------------|:------------------|:--------------------|:---------------------|:-----------|:------------------|:--------------------------|:----------------|:--------------------|:------------------|
| 110001         | FGV               | NA                  | 2021-06-22 09:51:49  | 2021-06-22 | FALSE             | TRUE                      | 2.5             | FALSE               | FALSE             |
| 110002         | FGV               | NA                  | 2021-06-22 09:59:01  | NA         | FALSE             | FALSE                     | NA              | FALSE               | FALSE             |

</td>
<td>
<table class="kable_wrapper">
<tbody>
<tr>
<td>

| repeating_data_name | created_on          | Participant_ID | repeating_data_inst_name            | AE_type          | AE_SAE | AE_severity      | AE_stopdate | AE_expected | AE_outcome | AE_action            | AE_relation        | AE_startdate |
|:--------------------|:--------------------|:---------------|:------------------------------------|:-----------------|:-------|:-----------------|:------------|:------------|:-----------|:---------------------|:-------------------|:-------------|
| Adverse event       | 2021-06-22 09:55:13 | 110001         | Adverse event - 22-06-2021 09:55:12 | A bug in the API | Yes    | Life-threatening | 24-06-2021  | Yes         | Resolved   | Medical intervention | Definitely related | 23-06-2021   |
| Adverse event       | 2021-06-22 09:58:13 | 110001         | Adverse event - 22-06-2021 09:58:12 | NA               | NA     | NA               | NA          | NA          | NA         | NA                   | NA                 | NA           |

</td>
<td>

| repeating_data_name | created_on          | Participant_ID | repeating_data_inst_name            | comorbidities                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
|:--------------------|:--------------------|:---------------|:------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Comorbidities       | 2021-06-22 09:56:07 | 110001         | Comorbidities - 22-06-2021 09:56:06 | {“file_name”:“Y29tb3JiaWRpdGllcy50eHQ=”,“mime_type”:“text/plain”,“file_size”:48,“storage_path”:“B2CF4AB1-CCCF-43CD-9933-13DE879C1AB5”,“key”:{“generation”:{“metadata”:\[\],“version”:\[“rb”,1\]},“storage”:{“metadata”:{“ciphertext”:“CiQAsmjNQAKXE4sQbDJagktdyNPH7fbo6bCMPRGYrSp/hYls7U0SSQAAsqYVDFxH1mKbO5tgQ3RmzxhkmAvUKA7LDzwqaU1gcdWuKvplMjniW1OjZwW8qntb+a60NG12EN9k6YSifTl6749JXjB/4Fw=”,“key_version”:“1”,“project”:“castoredc-kms”,“location”:“europe-west4”,“keyring”:“15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88”,“keyname”:“41B6FFD8-61BB-4D06-B5B1-58D8D2875C68”},“version”:\[“google”,1\]}},“algorithm”:{“version”:\[“sodium”,1\],“attributes”:{“nonce”:“0021a3e7a6cf3b8a686d184d499503df435a4232b0356476”}}} |

</td>
<td>

| repeating_data_name | created_on          | Participant_ID | repeating_data_inst_name         | med_stop   | med_name   | med_dose | med_start  | med_units |
|:--------------------|:--------------------|:---------------|:---------------------------------|:-----------|:-----------|:---------|:-----------|:----------|
| Medication          | 2021-06-22 09:54:28 | 110001         | Medication - 22-06-2021 09:54:28 | 28-06-2021 | Diclofenac | 150      | 25-06-2021 | mg/day    |
| Medication          | 2021-06-22 09:58:27 | 110001         | Medication - 22-06-2021 09:58:26 | NA         | NA         | NA       | NA         | NA        |

</td>
<td>

| repeating_data_name | created_on          | Participant_ID | repeating_data_inst_name                | unsvis_sbp | unsvis_dbp | unsvis_date | unsvis_weight | unsvis_hr | unsvis_type           |
|:--------------------|:--------------------|:---------------|:----------------------------------------|:-----------|:-----------|:------------|:--------------|:----------|:----------------------|
| Unscheduled visit   | 2021-06-22 09:57:38 | 110001         | Unscheduled visit - 22-06-2021 09:57:36 | 233        | 156        | 24-06-2021  | 98.3          | 112       | admission to day-care |

</td>
</tr>
</tbody>
</table>
</td>
<td>
<table class="kable_wrapper">
<tbody>
<tr>
<td>

| survey_instance_id                   | participant_id | survey_name | survey_package_name     | survey_package_instance_id           | created_on                 | created_by                           | sent_on                    | finished_on                | survey_package_instance_parent_id | survey_package_instance_parent_type | SF12_12 | SF12_2 | SF12_1    | VAS   | SF12_3 |
|:-------------------------------------|:---------------|:------------|:------------------------|:-------------------------------------|:---------------------------|:-------------------------------------|:---------------------------|:---------------------------|:----------------------------------|:------------------------------------|:--------|:-------|:----------|:------|:-------|
| 4FF130AD-274C-4C8F-A4A0-A7816A5A88E9 | 110001         | QOL Survey  | My first survey package | 0761A9BA-9802-483D-8EB3-D07233A56F2B | 2021-06-22 10:12:19.000000 | B23ABCC4-3A53-FB32-7B78-3960CC907F25 | 2021-06-22 10:12:19.000000 | 2021-06-22 10:12:44.000000 |                                   | 0                                   | Rarely  | Mostly | Excellent | 85.00 | Mostly |
| B99F0082-1B20-456B-8D4D-47D16867B211 | 110001         | QOL Survey  | My first survey package | 5B3FE56F-89FA-4C6D-A638-E8FA46113EB0 | 2021-06-22 10:13:01.000000 | B23ABCC4-3A53-FB32-7B78-3960CC907F25 | 2021-06-22 10:13:01.000000 | NA                         |                                   | 0                                   | NA      | NA     | NA        | NA    | NA     |
| 29FD41EF-46F1-4DEA-A372-F38FC2C0C9C2 | 110001         | QOL Survey  | My first survey package | EBBB77D0-56A2-49C7-9333-A27C17FA5D95 | 2021-09-24 13:12:45.000000 | B23ABCC4-3A53-FB32-7B78-3960CC907F25 | 2021-09-24 13:12:45.000000 | NA                         |                                   | 0                                   | NA      | NA     | NA        | NA    | NA     |

</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>

``` r
fields <- castor_api$getFields(example_study_id)
```

| id                                   | parent_id                            | field_id                             | field_number | field_label                                                                              | field_variable_name | field_type        | field_required | field_hidden | field_info | field_units | field_min | field_min_label | field_max | field_max_label | field_enforce_decimals | field_slider_step | field_slider_step_value | field_image | report_id                            | field_length | additional_config             | exclude_on_data_export | option_group | metadata_points | validations | dependency_parents | dependency_children | randomize_option_order | \_links.self.href                                                                                                      | option_group.id | option_group.name | option_group.description | option_group.layout | option_group.fields | option_group.options |
|:-------------------------------------|:-------------------------------------|:-------------------------------------|-------------:|:-----------------------------------------------------------------------------------------|:--------------------|:------------------|---------------:|-------------:|:-----------|:------------|----------:|:----------------|----------:|:----------------|:-----------------------|:------------------|------------------------:|:------------|:-------------------------------------|-------------:|:------------------------------|:-----------------------|:-------------|:----------------|:------------|:-------------------|:--------------------|:-----------------------|:-----------------------------------------------------------------------------------------------------------------------|:----------------|:------------------|:-------------------------|:--------------------|:--------------------|:---------------------|
| 00A3BB37-1532-400E-8BBC-529FF5D63317 | 6D2A7286-685C-4A78-9641-929E233E41E2 | 00A3BB37-1532-400E-8BBC-529FF5D63317 |            7 | Record all relevant received therapy                                                     | NA                  | repeated_measures |              0 |            0 |            |             |        NA |                 |        NA |                 | NA                     | NA                |                      NA |             | F3F1C353-A3DC-42B4-8B47-B2DF56E8B3BF |           NA | {“showReportOfAllPhases”:“0”} | FALSE                  | NA           | NULL            | NULL        | NULL               | NULL                | FALSE                  | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/field/00A3BB37-1532-400E-8BBC-529FF5D63317> | NA              | NA                | NA                       | NA                  | NULL                | NULL                 |
| 02E4E21B-0AAA-4C89-980F-414D37E25BE5 | 88CA5E48-2A1B-4179-9908-F090B62E44A0 | 02E4E21B-0AAA-4C89-980F-414D37E25BE5 |            1 | **To randomize this patient, click on the ‘Randomize’ button in the Randomization tab.** | NA                  | remark            |              0 |            0 |            |             |        NA |                 |        NA |                 | NA                     | NA                |                      NA |             |                                      |           NA |                               | FALSE                  | NA           | NULL            | NULL        | NULL               | NULL                | FALSE                  | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/field/02E4E21B-0AAA-4C89-980F-414D37E25BE5> | NA              | NA                | NA                       | NA                  | NULL                | NULL                 |
| 04E40C4C-3AA0-42D3-AE27-F40879366A84 | 4E1682D3-9611-4B1A-84C4-14FCEBA15248 | 04E40C4C-3AA0-42D3-AE27-F40879366A84 |            1 | Describe the adverse event                                                               | AE_type             | textarea          |              1 |            0 |            |             |        NA |                 |        NA |                 | NA                     | NA                |                      NA |             |                                      |           NA |                               | FALSE                  | NA           | NULL            | NULL        | NULL               | NULL                | FALSE                  | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/field/04E40C4C-3AA0-42D3-AE27-F40879366A84> | NA              | NA                | NA                       | NA                  | NULL                | NULL                 |

``` r
forms <- castor_api$getForms(example_study_id)
```

| id                                   | form_id                              | form_name         | form_order | form_description                                            | \_embedded.visit.id                  | \_embedded.visit.visit_id            | \_embedded.visit.visit_description | \_embedded.visit.visit_name       | \_embedded.visit.visit_duration | \_embedded.visit.visit_number | \_embedded.visit.visit_order | \_embedded.visit.\_links.self.href                                                                                     | \_links.self.href                                                                                                                        |
|:-------------------------------------|:-------------------------------------|:------------------|-----------:|:------------------------------------------------------------|:-------------------------------------|:-------------------------------------|:-----------------------------------|:----------------------------------|:--------------------------------|:------------------------------|-----------------------------:|:-----------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------|
| 10B74382-3EA9-4107-85BC-C33B9BA078CA | 10B74382-3EA9-4107-85BC-C33B9BA078CA | Physical exam     |          8 | This is a copy of the Baseline Physical exam step.          | 62EDEB24-7616-4476-912D-2F280FB56E36 | 62EDEB24-7616-4476-912D-2F280FB56E36 | NA                                 | Follow-up Visit                   | NA                              | NA                            |                            3 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/62EDEB24-7616-4476-912D-2F280FB56E36> | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/repeating-data-instance/10B74382-3EA9-4107-85BC-C33B9BA078CA> |
| 287CE537-8910-4A0A-95A2-3683E48B548E | 287CE537-8910-4A0A-95A2-3683E48B548E | Study inclusion   |          2 | This form contains Inclusion Criteria information.          | EFEDE30F-0D61-468D-B67D-92465ACB0108 | EFEDE30F-0D61-468D-B67D-92465ACB0108 | NA                                 | Informed Consent and Inclusion    | NA                              | NA                            |                            1 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/EFEDE30F-0D61-468D-B67D-92465ACB0108> | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/repeating-data-instance/287CE537-8910-4A0A-95A2-3683E48B548E> |
| 2D15033E-59B8-4BF3-A5BA-5AF82F1870C1 | 2D15033E-59B8-4BF3-A5BA-5AF82F1870C1 | Demographics      |          3 | This form contains Demographic information.                 | EFEDE30F-0D61-468D-B67D-92465ACB0108 | EFEDE30F-0D61-468D-B67D-92465ACB0108 | NA                                 | Informed Consent and Inclusion    | NA                              | NA                            |                            1 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/EFEDE30F-0D61-468D-B67D-92465ACB0108> | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/repeating-data-instance/2D15033E-59B8-4BF3-A5BA-5AF82F1870C1> |
| 31B909EC-39C5-4C94-ADAF-30C62E039288 | 31B909EC-39C5-4C94-ADAF-30C62E039288 | Laboratory        |          7 | This form contains hematology and biochemistry data.        | 65B46EAC-5CE4-4E54-8C27-87F2A0FBA318 | 65B46EAC-5CE4-4E54-8C27-87F2A0FBA318 | NA                                 | Baseline                          | NA                              | NA                            |                            2 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/65B46EAC-5CE4-4E54-8C27-87F2A0FBA318> | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/repeating-data-instance/31B909EC-39C5-4C94-ADAF-30C62E039288> |
| 4366B99E-610D-4082-BEC8-F93A59A8F01A | 4366B99E-610D-4082-BEC8-F93A59A8F01A | Consent           |          1 | This form contains informed consent information.            | EFEDE30F-0D61-468D-B67D-92465ACB0108 | EFEDE30F-0D61-468D-B67D-92465ACB0108 | NA                                 | Informed Consent and Inclusion    | NA                              | NA                            |                            1 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/EFEDE30F-0D61-468D-B67D-92465ACB0108> | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/repeating-data-instance/4366B99E-610D-4082-BEC8-F93A59A8F01A> |
| 5349E9D7-A0E6-49A2-93A4-B66A38291048 | 5349E9D7-A0E6-49A2-93A4-B66A38291048 | Physical exam     |          6 | This form contains physical exam data from the first visit. | 65B46EAC-5CE4-4E54-8C27-87F2A0FBA318 | 65B46EAC-5CE4-4E54-8C27-87F2A0FBA318 | NA                                 | Baseline                          | NA                              | NA                            |                            2 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/65B46EAC-5CE4-4E54-8C27-87F2A0FBA318> | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/repeating-data-instance/5349E9D7-A0E6-49A2-93A4-B66A38291048> |
| 6D2A7286-685C-4A78-9641-929E233E41E2 | 6D2A7286-685C-4A78-9641-929E233E41E2 | Medical history   |          4 | This form contains Medical history information.             | EFEDE30F-0D61-468D-B67D-92465ACB0108 | EFEDE30F-0D61-468D-B67D-92465ACB0108 | NA                                 | Informed Consent and Inclusion    | NA                              | NA                            |                            1 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/EFEDE30F-0D61-468D-B67D-92465ACB0108> | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/repeating-data-instance/6D2A7286-685C-4A78-9641-929E233E41E2> |
| 88CA5E48-2A1B-4179-9908-F090B62E44A0 | 88CA5E48-2A1B-4179-9908-F090B62E44A0 | Randomization     |          5 | This form includes information on the randomization.        | 65B46EAC-5CE4-4E54-8C27-87F2A0FBA318 | 65B46EAC-5CE4-4E54-8C27-87F2A0FBA318 | NA                                 | Baseline                          | NA                              | NA                            |                            2 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/65B46EAC-5CE4-4E54-8C27-87F2A0FBA318> | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/repeating-data-instance/88CA5E48-2A1B-4179-9908-F090B62E44A0> |
| 8FC6AD28-3C81-4958-9B13-B249B2CA2D72 | 8FC6AD28-3C81-4958-9B13-B249B2CA2D72 | Medication        |         11 | In this step you can record medication intake.              | 3102EBF4-1525-4F83-94CF-840C51E64CCA | 3102EBF4-1525-4F83-94CF-840C51E64CCA | NA                                 | Unscheduled visits and Medication | NA                              | NA                            |                            4 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/3102EBF4-1525-4F83-94CF-840C51E64CCA> | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/repeating-data-instance/8FC6AD28-3C81-4958-9B13-B249B2CA2D72> |
| 90226AC6-F20E-48DC-83BC-C094CDC589BD | 90226AC6-F20E-48DC-83BC-C094CDC589BD | Unscheduled visit |         10 | In this step you can record unscheduled visits.             | 3102EBF4-1525-4F83-94CF-840C51E64CCA | 3102EBF4-1525-4F83-94CF-840C51E64CCA | NA                                 | Unscheduled visits and Medication | NA                              | NA                            |                            4 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/3102EBF4-1525-4F83-94CF-840C51E64CCA> | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/repeating-data-instance/90226AC6-F20E-48DC-83BC-C094CDC589BD> |
| FEABD311-4C21-4602-B722-37EECC90A622 | FEABD311-4C21-4602-B722-37EECC90A622 | Laboratory        |          9 | To copy a step, click on the cogwheel next to it.           | 62EDEB24-7616-4476-912D-2F280FB56E36 | 62EDEB24-7616-4476-912D-2F280FB56E36 | NA                                 | Follow-up Visit                   | NA                              | NA                            |                            3 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/62EDEB24-7616-4476-912D-2F280FB56E36> | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/repeating-data-instance/FEABD311-4C21-4602-B722-37EECC90A622> |

``` r
visits <- castor_api$getVisits(example_study_id)
```

| id                                   | visit_id                             | visit_description | visit_name                        | visit_duration | visit_number | visit_order | \_links.self.href                                                                                                      |
|:-------------------------------------|:-------------------------------------|:------------------|:----------------------------------|:---------------|:-------------|------------:|:-----------------------------------------------------------------------------------------------------------------------|
| 3102EBF4-1525-4F83-94CF-840C51E64CCA | 3102EBF4-1525-4F83-94CF-840C51E64CCA | NA                | Unscheduled visits and Medication | NA             | NA           |           4 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/3102EBF4-1525-4F83-94CF-840C51E64CCA> |
| 62EDEB24-7616-4476-912D-2F280FB56E36 | 62EDEB24-7616-4476-912D-2F280FB56E36 | NA                | Follow-up Visit                   | NA             | NA           |           3 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/62EDEB24-7616-4476-912D-2F280FB56E36> |
| 65B46EAC-5CE4-4E54-8C27-87F2A0FBA318 | 65B46EAC-5CE4-4E54-8C27-87F2A0FBA318 | NA                | Baseline                          | NA             | NA           |           2 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/65B46EAC-5CE4-4E54-8C27-87F2A0FBA318> |
| EFEDE30F-0D61-468D-B67D-92465ACB0108 | EFEDE30F-0D61-468D-B67D-92465ACB0108 | NA                | Informed Consent and Inclusion    | NA             | NA           |           1 | <https://data.castoredc.com/api/study/15E88A04-9CB8-4B30-9A3C-B1DBFC96CD88/visit/EFEDE30F-0D61-468D-B67D-92465ACB0108> |
