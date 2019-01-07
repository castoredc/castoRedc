
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

## Usage

See
<https://helpdesk.castoredc.com/article/124-application-programming-interface-api>
about generating your credentials.

*Note: It is recommended that you read
<https://cran.r-project.org/web/packages/httr/vignettes/secrets.html>
about managing your credentials.*

``` r
library(castoRedc)

castor_api <- CastorData$new(key = Sys.getenv("CASTOR_KEY"), 
                             secret = Sys.getenv("CASTOR_SECRET"), 
                             base_url = "https://data.castoredc.com")
```

``` r
studies <- castor_api$getStudies()
```

| crf\_id                              | study\_id                            | name              | created\_by                          | created\_on         | live  | randomization\_enabled | gcp\_enabled | surveys\_enabled | premium\_support\_enabled | main\_contact | expected\_centers | expected\_records | slug | version | duration | \_links.self.href                                                             |
| :----------------------------------- | :----------------------------------- | :---------------- | :----------------------------------- | :------------------ | :---- | :--------------------- | :----------- | :--------------- | :------------------------ | :------------ | ----------------: | ----------------: | :--- | :------ | :------- | :---------------------------------------------------------------------------- |
| 661D1A14-0ECC-0133-0142-004F5DB68A52 | 661D1A14-0ECC-0133-0142-004F5DB68A52 | study-1           | 8E5C3876-0A0C-927B-DB49-4890D711205E | 2018-11-06 10:49:52 | FALSE | FALSE                  | TRUE         | TRUE             | TRUE                      | FALSE         |                 0 |                 0 | id-1 | 0.01    | NA       | <https://dev.do.castoredc.com/api/study/661D1A14-0ECC-0133-0142-004F5DB68A52> |
| 9D9A33EF-40DE-5438-BD7E-703FC1913461 | 9D9A33EF-40DE-5438-BD7E-703FC1913461 | test-import-tulip | 8E5C3876-0A0C-927B-DB49-4890D711205E | 2018-11-08 18:05:44 | FALSE | FALSE                  | TRUE         | TRUE             | FALSE                     | FALSE         |                 0 |                 0 | id-2 | 0.01    | NA       | <https://dev.do.castoredc.com/api/study/9D9A33EF-40DE-5438-BD7E-703FC1913461> |

``` r
(example_study_id <- studies[["study_id"]][1])
#> [1] "661D1A14-0ECC-0133-0142-004F5DB68A52"
```

``` r
fields <- castor_api$getFields(example_study_id)
```

| id                                   | parent\_id                           | field\_id                            | field\_number | field\_label                          | field\_is\_alias | field\_variable\_name  | field\_type | field\_required | field\_hidden | field\_info | field\_units | field\_min | field\_min\_label | field\_max | field\_max\_label | field\_slider\_step | report\_id | field\_length | additional\_config | exclude\_on\_data\_export | metadata\_points | validations | dependency\_parents | dependency\_children | option\_group.id | option\_group.name | option\_group.description | option\_group.layout | option\_group.options | option\_group.fields | \_links.self.href                                                                                                        |
| :----------------------------------- | :----------------------------------- | :----------------------------------- | ------------: | :------------------------------------ | :--------------- | :--------------------- | :---------- | --------------: | ------------: | :---------- | :----------- | ---------: | :---------------- | ---------: | :---------------- | :------------------ | :--------- | ------------: | :----------------- | :------------------------ | :--------------- | :---------- | :------------------ | :------------------- | :--------------- | :----------------- | :------------------------ | :------------------- | :-------------------- | :------------------- | :----------------------------------------------------------------------------------------------------------------------- |
| 0097117D-4476-0B11-4738-0D9A5FFE0E87 | FD7954F6-2321-1244-8977-CE126558566C | 0097117D-4476-0B11-4738-0D9A5FFE0E87 |             1 | Length                                | FALSE            | dem\_patlen            | numeric     |               1 |             0 |             | m            |          0 | NA                |          2 | NA                | NA                  |            |             5 | NA                 | FALSE                     | list()           | list()      | list()              | list()               | NA               | NA                 | NA                        | NA                   | NULL                  | NULL                 | <https://dev.do.castoredc.com/api/study/661D1A14-0ECC-0133-0142-004F5DB68A52/field/0097117D-4476-0B11-4738-0D9A5FFE0E87> |
| 5DA1288A-C4FC-16BB-3DAB-7786527CDCAE | 7F0CA57D-25A1-EF84-0A5D-A0ECCB2316FE | 5DA1288A-C4FC-16BB-3DAB-7786527CDCAE |             4 | Months pregnant                       | FALSE            | dem\_pat\_preg\_months | numeric     |               1 |             0 |             | months       |          0 | NA                |         10 | NA                | NA                  |            |            NA | NA                 | FALSE                     | list()           | list()      | list()              | list()               | NA               | NA                 | NA                        | NA                   | NULL                  | NULL                 | <https://dev.do.castoredc.com/api/study/661D1A14-0ECC-0133-0142-004F5DB68A52/field/5DA1288A-C4FC-16BB-3DAB-7786527CDCAE> |
| 8B1FCC14-9001-9A0C-C44E-6D0FE0B52136 | 02D1455D-82E3-36C4-A0B2-CCB3D6CFDF33 | 8B1FCC14-9001-9A0C-C44E-6D0FE0B52136 |             4 | Can patient participate in the study? | FALSE            | inc\_pat\_can\_part    | calculation |               0 |             0 |             |              |         NA | NA                |         NA | NA                | NA                  |            |            NA | NA                 | FALSE                     | list()           | list()      | list()              | list()               | NA               | NA                 | NA                        | NA                   | NULL                  | NULL                 | <https://dev.do.castoredc.com/api/study/661D1A14-0ECC-0133-0142-004F5DB68A52/field/8B1FCC14-9001-9A0C-C44E-6D0FE0B52136> |

``` r
steps <- castor_api$getSteps(example_study_id)
```

| id                                   | step\_id                             | step\_name   | step\_order | step\_description | \_embedded.phase.id                  | \_embedded.phase.phase\_id           | \_embedded.phase.phase\_description | \_embedded.phase.phase\_name | \_embedded.phase.phase\_duration | \_embedded.phase.phase\_order | \_embedded.phase.\_links.self.href                                                                                       | \_links.self.href                                                                                                       |
| :----------------------------------- | :----------------------------------- | :----------- | ----------: | :---------------- | :----------------------------------- | :----------------------------------- | :---------------------------------- | :--------------------------- | :------------------------------- | ----------------------------: | :----------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------- |
| 02D1455D-82E3-36C4-A0B2-CCB3D6CFDF33 | 02D1455D-82E3-36C4-A0B2-CCB3D6CFDF33 | Inclusion    |           1 |                   | 6EC42D9A-D1F0-B946-7A61-A6AF8A526884 | 6EC42D9A-D1F0-B946-7A61-A6AF8A526884 | NA                                  | Baseline (example phase)     | NA                               |                             1 | <https://dev.do.castoredc.com/api/study/661D1A14-0ECC-0133-0142-004F5DB68A52/phase/6EC42D9A-D1F0-B946-7A61-A6AF8A526884> | <https://dev.do.castoredc.com/api/study/661D1A14-0ECC-0133-0142-004F5DB68A52/step/02D1455D-82E3-36C4-A0B2-CCB3D6CFDF33> |
| 7F0CA57D-25A1-EF84-0A5D-A0ECCB2316FE | 7F0CA57D-25A1-EF84-0A5D-A0ECCB2316FE | Demographics |           2 |                   | 6EC42D9A-D1F0-B946-7A61-A6AF8A526884 | 6EC42D9A-D1F0-B946-7A61-A6AF8A526884 | NA                                  | Baseline (example phase)     | NA                               |                             1 | <https://dev.do.castoredc.com/api/study/661D1A14-0ECC-0133-0142-004F5DB68A52/phase/6EC42D9A-D1F0-B946-7A61-A6AF8A526884> | <https://dev.do.castoredc.com/api/study/661D1A14-0ECC-0133-0142-004F5DB68A52/step/7F0CA57D-25A1-EF84-0A5D-A0ECCB2316FE> |
| FD7954F6-2321-1244-8977-CE126558566C | FD7954F6-2321-1244-8977-CE126558566C | Measurements |           3 |                   | 6EC42D9A-D1F0-B946-7A61-A6AF8A526884 | 6EC42D9A-D1F0-B946-7A61-A6AF8A526884 | NA                                  | Baseline (example phase)     | NA                               |                             1 | <https://dev.do.castoredc.com/api/study/661D1A14-0ECC-0133-0142-004F5DB68A52/phase/6EC42D9A-D1F0-B946-7A61-A6AF8A526884> | <https://dev.do.castoredc.com/api/study/661D1A14-0ECC-0133-0142-004F5DB68A52/step/FD7954F6-2321-1244-8977-CE126558566C> |

``` r
phases <- castor_api$getPhases(example_study_id)
```

| id                                   | phase\_id                            | phase\_description | phase\_name              | phase\_duration | phase\_order | \_links.self.href                                                                                                        |
| :----------------------------------- | :----------------------------------- | :----------------- | :----------------------- | :-------------- | -----------: | :----------------------------------------------------------------------------------------------------------------------- |
| 6EC42D9A-D1F0-B946-7A61-A6AF8A526884 | 6EC42D9A-D1F0-B946-7A61-A6AF8A526884 | NA                 | Baseline (example phase) | NA              |            1 | <https://dev.do.castoredc.com/api/study/661D1A14-0ECC-0133-0142-004F5DB68A52/phase/6EC42D9A-D1F0-B946-7A61-A6AF8A526884> |

Please note that the 'castoRedc' project is released with a [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.