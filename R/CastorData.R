#' @include utils.R
NULL

#' Class used to access Castor REST API.
#'
#'
#' @section Methods:
#' \itemize{
#'  \item \code{getStudies(): Retries all Castor studies in account.}
#'  \item \code{getFields(study_id, include, page): Gets all fields for a given
#'  study.
#'  }
#'  \item \code{getRecords(study_id): Gets all records for a given
#'  study.
#'  }
#'  \item \code{getStudyDataPoints(study_id, record_id,
#'                                 filter_types): Gets all data points
#'  for a given study and record. Filter types may be supplied for fields types
#'  as a character vector of field types.
#'  }
#'  \item \code{getStudyData(study_id, filter_types): creates a data
#'  frame with all data points for a given study with each row representing a
#'  record and each column a field.
#'  }
#'  \item \code{adjustTypes = function(field_to_type, values,
#'                                     type_to_func): Utility method
#'  for casting columns to their intended type. Users can supply their own list
#'  of data type : function (for casting the data) mappings on instantiation of
#'  this class, CastorAPIWrapper.
#'  }
#' }
#' @docType class
#' @keywords internal
#' @format An R6 class object.
#' @importFrom R6 R6Class
#' @export
#' @name CastorData-class
CastorData <- R6::R6Class("CastorData",
  inherit = CastorAPIWrapper,
  public = list(
    getStudies = function() {
      studies_pages <- self$getStudiesPages()

      private$mergePages(studies_pages, "study")
    },
    getUsers = function() {
      users_pages <- self$getUsersPages()

      private$mergePages(users_pages, "user")
    },
    getSteps = function(study_id) {
      if (self$verbose) message("Getting all steps for study ", study_id)
      steps_pages <- self$getStepsPages(study_id)

      private$mergePages(steps_pages, "steps")
    },
    getFields = function(study_id, include = "optiongroup") {
      if (self$verbose) message("Getting all fields for study ", study_id)
      fields_pages <- self$getFieldsPages(study_id, include = include)

      private$mergePages(fields_pages, "fields")
    },
    getPhases = function(study_id) {
      if (self$verbose) message("Getting all phases for study ", study_id)
      phases_pages <- self$getPhasesPages(study_id)

      private$mergePages(phases_pages, "phases")
    },
    getSurveys = function(study_id, include = "steps",
                          page = NULL) {
      if (self$verbose) message("Getting all surveys for study ", study_id)
      surveys_pages <- self$getSurveysPages(study_id, include = include)


      private$mergePages(surveys_pages, "surveys")
    },
    getSurveyPackages = function(study_id) {
      if (self$verbose)
        message("Getting all survey packages for study ", study_id)

      surveypackages_pages <- self$getSurveyPackagesPages(study_id)

      private$mergePages(surveypackages_pages, "survey_packages")
    },
    getSurveyPackageInstances = function(study_id) {
      if (self$verbose)
        message("Getting all survey packages for study ", study_id)

      surveypackageinstances_pages <-
        self$getSurveyPackageInstancesPages(study_id)

      private$mergePages(surveypackageinstances_pages, "surveypackageinstances")
    },
    getReports = function(study_id) {
      if (self$verbose) message("Getting all reports for study ", study_id)

      report_pages <- self$getReportsPages(study_id)

      private$mergePages(report_pages, "reports")
    },
    getReportSteps = function(study_id) {
      if (self$verbose) message("Getting all report steps for study ", study_id)

      reports <- self$getReports(study_id)

      report_steps_pages <- lapply(reports$report_id, function(report) {
          self$getReportStepsPages(study_id, report_id = report)
      })
      # This endpoint gives weird output
      report_steps_pages <- unlist(report_steps_pages, recursive = FALSE)
      private$mergePages(report_steps_pages, "report_steps")
    },
    getRecords = function(study_id, filter_archived = TRUE) {
      if (self$verbose) message("Getting all records for study ", study_id)

      records_pages <- self$getRecordsPages(study_id)
      records_merged <- private$mergePages(records_pages, "records")

      if (filter_archived && isTRUE(nrow(records_merged) > 0))
        records_merged <-
          records_merged[!grepl("ARCHIVED", records_merged[["record_id"]]), ]

      return(records_merged)
    },
    getStudyDataPointsBulkByRecord = function(study_id, record_id) {
      if (self$verbose)
        message("Getting data points for record ", record_id, " from study ",
                study_id)

      sdp_url <- glue("study/{study_id}/record/{record_id}",
                      "/data-point-collection/study")

      record_metadata <- self$getRecord(study_id, record_id)

      res <- self$getRequest(sdp_url)

      if (self$verbose)
        print(res)

      if (res$total_items == 0)
        return(data.frame())

      study_data <- mutate(
        spread(
          select(res[["_embedded"]][["items"]],
                 field_id, field_value, Record_ID = record_id),
          field_id, field_value),
        Institute_Abbreviation =
          record_metadata[["_embedded"]]$institute$abbreviation,
        Randomization_Group =
          ifelse(is.null(record_metadata$randomization_group), NA,
                 record_metadata$randomization_group),
        Record_Creation = record_metadata$created_on$date
      )

      fields <- self$getFields(study_id)

      fields <- fields[!is.na(fields$field_variable_name), ]

      id_to_field_name_ <- split(fields$field_variable_name, fields$field_id)

      rename_at(study_data,
                vars(-Record_ID, -Record_Creation, -Randomization_Group,
                     -Institute_Abbreviation),
                ~unlist(id_to_field_name_, recursive = FALSE)[.])

    },
    getStudyDataPointsBulk = function(study_id_ = FALSE) {
      sdpb_url <- glue("study/{study_id_}/data-point-collection/study")

      private$mergePages(self$collectPages(sdpb_url, page_size = 5000), "items")
    },
    getReportInstancesByRecord = function(study_id, record_id) {
      report_url <- glue("study/{study_id}/record/{record_id}",
                         "/data-point-collection/report-instance")

      result <- private$mergePages(self$collectPages(report_url,
                                                     page_size = 5000),
                                   "items")

      if (nrow(result) > 0)
        result
      else
        NULL
    },
    getReportInstances = function(study_id, record_id = NULL,
                                  id_to_field_name = NULL) {
      self$getReportInstancesBulk(study_id, record_id_ = record_id,
                                  id_to_field_name_ = id_to_field_name)
    },
    getReportInstancesBulk = function(study_id_,
                                      record_id_ = NULL,
                                      id_to_field_name_ = NULL,
                                      page_size = NULL) {
      if (!is.null(record_id_)) {
        report_instances <- self$getReportInstancesByRecord(
          study_id = study_id_, record_id = record_id_)
      } else {
        ri_url <- glue("study/{study_id_}/data-point-collection",
                       "/report-instance")

        report_instances <- private$mergePages(
          self$collectPages(ri_url, page_size = page_size,
                            enable_pagination = "true"),
          "items")
      }

      if (!isTRUE(nrow(report_instances) > 0)) {
        warning("No report instances data for ", study_id_)
        return(NULL)
      }

      report_inst_fields <- c("field_id", "report_instance_id", "field_value",
                              "record_id")

      ri_metadata <- self$getReportInstanceMetadata(study_id_)

      report_inst_name_to_id <- cols_to_map(ri_metadata,
                                            "report_instance_name",
                                            "report_instance_id")

      report_instance_to_name <- cols_to_map(ri_metadata,
                                             "report_instance_name",
                                             "report_name")

      report_instances <- left_join(
        report_instances,
        select(ri_metadata, report_instance_name, report_name, created_on)
      )

      report_fields <- cols_to_map(report_instances, "report_name",
                                   "field_id")

      report_data <- rename(
        spread(
          distinct(
            select(report_instances, record_id, field_id, report_name,
                   created_on, report_instance_name, field_value)),
          field_id, field_value),
        Record_ID = record_id,
        report_inst_name = report_instance_name)

      if (is.null(id_to_field_name_)) {
        fields <- self$getFields(study_id_)

        fields <-
          fields %>%
          mutate(field_variable_name = if_else(
            is.na(field_variable_name) | isTRUE(field_variable_name == ""),
            paste(substr(field_label, 1, 64), "|", substr(field_id, 1, 8)),
            as.character(field_variable_name)
          ))

        fields <- fields[!is.na(fields$field_variable_name), ]

        id_to_field_name_ <- split(fields$field_variable_name, fields$field_id)
      }

      report_data <- rename_at(report_data,
                               vars(-Record_ID, -report_inst_name,
                                    -report_name, -created_on),
                               ~unlist(id_to_field_name_, recursive = FALSE)[.])

      attr(report_data, "report_inst_name_to_id") <- report_inst_name_to_id
      attr(report_data, "report_fields") <- report_fields

      report_data
    },
    getReportInstanceMetadata = function(study_id) {
      ri_md_pages <- self$getReportInstanceMetadataPages(study_id = study_id)
      ri_metadata <- private$mergePages(ri_md_pages, "reportInstances")

      selected_cols <- c("id", "name", "status", "parent_id", "parent_type",
                         "record_id", "report_name", "created_on",
                         "created_by", "_embedded.report.report_id",
                         "_embedded.report.description",
                         "_embedded.report.type")

      name_map <- c(
        "id" = "report_instance_id",
        "name" = "report_instance_name",
        "status" = "report_instance_status",
        "parent_id" = "report_instance_parent_id",
        "parent_type" = "report_instance_parent_type",
        "_embedded.report.report_id" = "report_id",
        "_embedded.report.description" = "report_description",
        "_embedded.report.type" = "report_type"
      )

      ri_metadata <- ri_metadata[selected_cols]

      rename_at(ri_metadata, names(name_map), ~name_map[.])
    },
    getSurveyInstances = function(study_id, record_id = NULL,
                                  id_to_field_name = NULL) {
      self$getSurveyInstancesBulk(study_id, record_id_ = record_id,
                                  id_to_field_name_ = id_to_field_name)
    },
    getSurveyInstancesBulk = function(study_id_, record_id_ = NULL,
                                      id_to_field_name_ = NULL) {
      if (is.null(record_id_)) {
        si_url <- glue("study/{study_id_}/data-point-collection",
                       "/survey-instance")
      } else {
        si_url <- glue("study/{study_id_}/record/{record_id_}",
                       "/data-point-collection/survey-instance")
      }

      survey_instances <- private$mergePages(
        self$collectPages(si_url, page_size = 5000), "items")

      if (!isTRUE(nrow(survey_instances) > 0)) {
        warning("No survey instances data for ", study_id_)
        return(NULL)
      }

      survey_inst_fields <- c("field_id", "survey_instance_id", "field_value",
                              "record_id", "survey_name")

      survey_data <- rename(
        spread(
          distinct(
            select(survey_instances, survey_instance_id, record_id, field_id,
                   survey_name, field_value)),
          field_id, field_value),
        Record_ID = record_id,
        package_name = survey_name)

      if (!is.null(id_to_field_name_))
        rename_at(survey_data, vars(-Record_ID, -package_name),
                  ~unlist(id_to_field_name_, recursive = FALSE)[.])
      else
        survey_data
    },
    getSurveyInstanceBulk = function(study_id, record_id, survey_instance_id) {
      si_url <- glue("study/{study_id}/record/{record_id}",
                     "/data-point-collection/survey-instance",
                     "/{survey_instance_id}")

      self$getRequest(si_url)[["_embedded"]][["items"]] %>%
        select(field_id, survey_instance_id, field_value, record_id) %>%
        spread(field_id, field_value)
    },
    getSurveyPackageInstanceBulk = function(study_id, record_id,
                                            survey_package_instance_id) {
      spi_url <- glue("study/{study_id}/record/{record_id}",
                      "/data-point-collection",
                      "/survey-package-instance/{survey_package_instance_id}")

      self$getRequest(si_url)[["_embedded"]][["items"]] %>%
        select(field_id, survey_instance_id, field_value, record_id) %>%
        spread(field_id, field_value)
    },
    getStudyDataPoints = function(study_id, record_id = NULL,
                                  filter_types = NULL, bulk_by_record = FALSE) {
      if (self$verbose)
        message("Getting data points for record ", record_id, " from study ",
                study_id)

      if (bulk_by_record)
        return(self$getStudyDataPointsBulkByRecord(study_id, record_id))
      else {
        # Request the pages for the records with getStudyDataPointsPages.
        sdp_pages <- self$getStudyDataPointsPages(study_id, record_id)
        # If there is more than one page, use Reduce to merge the data frames
        # within the list into a single data frame.
        sdp_merged <- private$mergePages(sdp_pages, "StudyDataPoints")
      }

      # Fetch the record metadata from the API in order to fortify the dataset
      # with information about the study.
      record_metadata <- self$getRecord(study_id, record_id)


      if (nrow(sdp_merged) == 0) {
        warning("No data points for study id ", study_id, " and record id ",
                record_id, "\n",
                "returning data frame with just record metadata.")

        empty.df <- data.frame(
          "Institute Abbreviation" =
            record_metadata[["_embedded"]][["institute"]][["abbreviation"]],
          "Randomization Group" =
            ifelse(is.null(record_metadata[["randomization_group"]]), NA,
                   record_metadata[["randomization_group"]]),
          "Record Creation" = record_metadata[["created_on"]][["date"]],
          "Record_ID" = record_id
        )

        return(empty.df)
      }
      # Filter out any field types that are specified in the filter_types
      # variable, unless it is NULL.
      if (self$verbose) message("Filtering results.")
      if (!is.null(filter_types))
        sdp_merged <-
          sdp_merged[!(sdp_merged[["_embedded.field.field_type"]] %in%
                         filter_types), ]

      # Restructure the values and variable names into a data frame.
      study_data_points.df <- data.frame(
        as.list(setNames(sdp_merged[["value"]],
                         sdp_merged[["field_variable_name"]])),
        stringsAsFactors = FALSE)

      # Add the record id as a column to the data.
      study_data_points.df[["Record_ID"]] <- record_id

      # Randomization ID should be in record data.
      study_data_points.df[["Institute_Abbreviation"]] <-
        record_metadata[["_embedded"]][["institute"]][["abbreviation"]]
      study_data_points.df[["Randomization_Group"]] <-
        ifelse(is.null(record_metadata[["randomization_group"]]),
               NA,
               record_metadata[["randomization_group"]])
      study_data_points.df[["Record_Creation"]] <-
        record_metadata[["created_on"]][["date"]]

      return(study_data_points.df)
    },
    getStudyDataBulk = function(study_id., field_info., record_metadata) {
      study_data <- self$getStudyDataPointsBulk(study_id.)
      if (isTRUE(nrow(study_data) > 0)) {
        study_data_field_info <- distinct(left_join(study_data, field_info.))
        study_data_long <- select(study_data_field_info,
                                  field_variable_name, record_id, field_value)
        study_data_wide <- spread(study_data_long,
                                  field_variable_name, field_value)
        study_data_compelete_cases <- filter_all(study_data_wide,
                                                 any_vars(!is.na(.)))

        rename(
          left_join(
            select(
              record_metadata,
              record_id,
              Randomization_Group = randomization_group,
              Institute_Abbreviation = `_embedded.institute.abbreviation`,
              Record_Creation = created_on.date),
            study_data_compelete_cases
          ),
          Record_ID = record_id
        )
      } else
        NULL
    },
    getFieldInfo = function(study_id) {
      fields <- self$getFields(study_id)
      if (!is.null(fields))
        mutate(fields,
               field_variable_name = if_else(is.na(field_variable_name) |
                                               field_variable_name == "<NA>",
                                             field_id, field_variable_name))
      else
        NULL
    },
    generateFieldMetadata = function(study_id, field_info) {
      steps <- self$getSteps(study_id)

      if (missing(field_info) || is.null(field_info))
        field_info <- self$getFieldInfo(study_id)

      if (!is.null(steps)) {
        fields_steps <- merge(steps[c("id", "step_order")],
                              field_info[c("parent_id", "field_variable_name",
                                           "field_number")],
                              by.x = "id", by.y = "parent_id", all.y = TRUE)

        fields_steps$fullstep <-
          as.integer(paste0(fields_steps$step_order,
                            sprintf("%02d", fields_steps$field_number)))
      } else {
        fields_steps <- field_info
        fields_steps$fullstep <- fields_steps$field_number
      }

      checkbox_fields <- self$generateCheckboxFields(field_info = field_info)

      if (!is.null(checkbox_fields)) {
        name_map <- bind_rows(
          imap(checkbox_fields,
               ~tibble(adjusted_field_variable_name = .x,
                       field_variable_name = .y)))

        field_order <- left_join(fields_steps, name_map)
      } else {
        field_order <- fields_steps
        field_order$adjusted_field_variable_name <-
          field_order$field_variable_name
      }

      field_order$adjusted_field_variable_name <-
        ifelse(is.na(field_order$adjusted_field_variable_name),
               field_order$field_variable_name,
               field_order$adjusted_field_variable_name)

      metadata_fields <- c("Record_ID", "Institute_Abbreviation",
                           "Randomization_Group", "Record_Creation")

      field_order <- bind_rows(
        field_order,
        data.frame(
          field_variable_name = metadata_fields,
          adjusted_field_variable_name = metadata_fields
        )
      )

      field_order <- distinct(field_order, field_variable_name,
                              adjusted_field_variable_name, .keep_all = TRUE)

      field_order <- mutate(
        field_order,
        fullstep = case_when(
          field_variable_name == "Record_ID" ~ 1,
          field_variable_name == "Institute_Abbreviation" ~ 2,
          field_variable_name == "Randomization_Group" ~ 3,
          field_variable_name == "Record_Creation" ~ 4,
          TRUE ~ fullstep + 4))

      field_order <- field_order[order(field_order$fullstep), ]
      field_order <- left_join(select(field_order,
                                      field_variable_name,
                                      adjusted_field_variable_name,
                                      fullstep),
                               field_info)
      if (!is.null(steps))
        field_metadata <- merge(field_order, steps,
                                by.x = "parent_id", by.y = "id",
                                all = TRUE)
      else
        field_metadata <- field_order

      field_metadata$default <- FALSE
      field_metadata$default[field_metadata$adjusted_field_variable_name %in%
                               metadata_fields] <- TRUE

      arrange(field_metadata, fullstep)
    },
    getStudyData = function(study_id, bulk = TRUE,
                            report_instances = FALSE,
                            survey_instances = FALSE,
                            filter_types = c("remark", "image", "summary",
                                             "upload", "repeated_measures",
                                             "add_report_button")) {
      metadata_fields <- c("Record_ID", "Institute_Abbreviation",
                           "Randomization_Group",
                           "Record_Creation")
      record_metadata <- self$getRecords(study_id)
      # Get field metadata for the given study to be used in adjustTypes.
      field_info <- self$getFieldInfo(study_id)

      if (is.null(field_info))
        return(NULL)

      if (bulk) {
        all_data_points.df <- self$getStudyDataBulk(study_id, field_info,
                                                    record_metadata)
      } else {
        # Get study data from getStudyDataPoints and collect them by record in a
        # list.
        study_data <- lapply(record_metadata$record_id, function(record) {
          if (self$verbose) message("getting record ", record)
          return(self$getStudyDataPoints(study_id, record, filter_types))
        })

        all_data_points.df <- bind_rows(study_data)
      }

      if (is.null(all_data_points.df)) {
        warning("No study data available for this study.")
        fields <- unique(field_info$field_variable_name)
        all_data_points.df <- as.list(
          rep(NA, length(fields) + length(metadata_fields))
        )
        names(all_data_points.df) <- append(fields, metadata_fields)
        all_data_points.df <- as.data.frame(all_data_points.df)[NULL, ]
      }

      adjusted_data_points.df <- self$adjustTypes(
        all_data_points.df, field_info, self$type_to_func, filter_types)

      adjusted_data_points.df <-
        self$adjustCheckboxFields(adjusted_data_points.df, field_info)

      field_metadata <- self$generateFieldMetadata(study_id, field_info)

      adjusted_data_points.df <- adjusted_data_points.df[
        intersect(field_metadata$adjusted_field_variable_name,
                  names(adjusted_data_points.df))]

      if ("Record_Creation" %in% names(adjusted_data_points.df))
        adjusted_data_points.df[["Record_Creation"]] <-
        as.POSIXct(adjusted_data_points.df[["Record_Creation"]], tz = "GMT")

      if (report_instances || survey_instances)
        id_to_name <- cols_to_map(field_metadata, "field_id",
                                  "field_variable_name")

      if (report_instances) {
        report_instances <- self$getReportInstances(
          study_id = study_id, id_to_field_name = id_to_name)
        if (!is.null(report_instances)) {
          report_fields <- attr(report_instances, "report_fields")

          report_fields <- imap(report_fields, function(fields, report) {
            pull(filter(field_metadata, field_id %in% fields),
                 adjusted_field_variable_name)
          })

          report_instances <- self$adjustCheckboxFields(
            report_instances,
            filter(field_metadata,
                   field_variable_name %in% names(report_instances) &
                     field_type == "checkbox"))

          attr(report_instances, "report_fields") <- report_fields

          attr(adjusted_data_points.df, "report_instances") <- report_instances
        }
      }
      if (survey_instances) {
        survey_instances <- self$getSurveyInstances(
          study_id = study_id, id_to_field_name = id_to_name)
        if (!is.null(survey_instances)) {
          survey_instances <- self$adjustCheckboxFields(
            survey_instances,
            filter(field_metadata,
                   field_variable_name %in% names(survey_instances)))

          attr(adjusted_data_points.df, "survey_instances") <- survey_instances
        }
      }

      attr(adjusted_data_points.df, "field_metadata") <- field_metadata
      attr(adjusted_data_points.df, "castor") <- TRUE

      adjusted_data_points.df
    },
    generateCheckboxFields = function(field_info, checkboxes = NULL) {
      if (is.null(checkboxes))
        checkboxes <- filter(field_info, field_type == "checkbox")
      if (nrow(checkboxes) > 0) {
        if (self$verbose)
          glue("Adjusting {nrow(checkboxes)} checkox fields:\n",
               paste(checkboxes$field_variable_name, collapse = ", "))

        checkbox_map <- pmap(checkboxes, list) %>%
          set_names(map(., "field_variable_name")) %>%
          imap(~paste0(.$field_variable_name, "#",
                       .$option_group.options$groupOrder))

        # the above generates duplicates
        checkbox_map[unique(names(checkbox_map))]
      } else {
        if (self$verbose) message("No checkbox fields to adjust")
        return(NULL)
      }
    },
    adjustCheckboxFields = function(datapoints, field_info,
                                    checkbox_fields = NULL) {
      if (is.null(checkbox_fields))
        checkbox_fields <- self$generateCheckboxFields(field_info)

      checkbox_vars <- intersect(names(checkbox_fields), names(datapoints))
      if (is.null(checkbox_fields) || length(checkbox_vars) == 0)
        return(datapoints)
      else {
        checkbox_data <- split_checkboxes(datapoints[checkbox_vars],
                                          checkbox_field_info = checkbox_fields)
        adjusted_data_points <- bind_cols(
          select(datapoints, -one_of(checkbox_vars)),
          checkbox_data)

        if (self$verbose) message("Checkbox fields adjusted.")

        return(adjusted_data_points)
      }
    },
    adjustTypes = function(study_data, field_metadata, type_to_func,
                           filter_types) {
      if (nrow(study_data) == 0)
        return(study_data)

      field_metadata <- filter(field_metadata,
                               field_variable_name %in% names(study_data))

      for (type in names(type_to_func)) {
        fields <- pull(filter(field_metadata, field_type == type),
                       field_variable_name)

        study_data <- mutate_at(study_data, fields, type_to_func[[type]])
      }

      other_fields <- pull(filter(field_metadata,
                                  !(field_type %in% names(type_to_func))),
                           field_variable_name)

      mutate_at(study_data, other_fields, as.character)
    }
  ),
  private = list(
    mergePages = function(pages, subkey, key = "_embedded") {
      if (length(pages) > 1) {
        df_pages <- lapply(pages,
          function(page) {
            if (key %in% names(page)) {
              if (subkey %in% names(page[[key]])) {
                return(page[[key]][[subkey]])
              } else {
                warning(subkey, " not in data frame.\nReturning NULL.")
                return(NULL)
              }
            } else {
              warning(subkey, " not in data frame.\nReturning NULL.")
              return(NULL)
            }
          })
        pages_merged <- bind_rows(df_pages)
        if (self$verbose) {
          message("Merged pages:")
          print(pages_merged)
        }
      } else {
        message("Only one page from API to return")
        # Otherwise, just return the data frame from the only page that exists.
        pages_merged <- pages[[1]][[key]][[subkey]]
      }

      if (identical(pages_merged, list()))
          pages_merged <- NULL

      return(pages_merged)
    }
  )
)
