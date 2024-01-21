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
#'  \item \code{getParticipants(study_id): Gets all participants for a given
#'  study.
#'  }
#'  \item \code{getStudyDataPoints(study_id, participant_id,
#'                                 filter_types): Gets all data points
#'  for a given study and participant. Filter types may be supplied for fields types
#'  as a character vector of field types.
#'  }
#'  \item \code{getStudyData(study_id, filter_types): creates a data
#'  frame with all data points for a given study with each row representing a
#'  participant and each column a field.
#'  }
#'  \item \code{getOptionGroups(study_id): creates a data
#'  frame with all option groups for a given study with each row representing an
#'  option group.
#'  }
#'  \item \code{getRepeatingDataInstancesByParticipant(study_id, participant_id): creates a data
#'  frame with all repeating data for a given participant with each row
#'  representing a field.
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
    getForms = function(study_id) {
      if (self$verbose) message("Getting all forms for study ", study_id)
      forms_pages <- self$getFormsPages(study_id)

      private$mergePages(forms_pages, "forms")
    },
    getFields = function(study_id, include = "optiongroup") {
      if (self$verbose) message("Getting all fields for study ", study_id)
      fields_pages <- self$getFieldsPages(study_id, include = include)

      private$mergePages(fields_pages, "fields")
    },
    getVisits = function(study_id) {
      if (self$verbose) message("Getting all visits for study ", study_id)
      visits_pages <- self$getVisitsPages(study_id)

      private$mergePages(visits_pages, "visits")
    },
    getSurveys = function(study_id, include = "forms",
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
    getRepeatingDatas = function(study_id) {
      if (self$verbose) message("Getting all repeating_datas for study ", study_id)

      repeating_data_pages <- self$getRepeatingDatasPages(study_id)

      private$mergePages(repeating_data_pages, "repeatingData")
    },
    getRepeatingDataForms = function(study_id) {
      if (self$verbose) message("Getting all repeating_data forms for study ", study_id)

      repeating_datas <- self$getRepeatingDatas(study_id)

      repeating_data_forms_pages <- lapply(repeating_datas$repeating_data_id, function(repeating_data) {
          self$getRepeatingDataFormsPages(study_id, repeating_data_id = repeating_data)
      })
      # This endpoint gives weird output
      repeating_data_forms_pages <- unlist(repeating_data_forms_pages, recursive = FALSE)
      private$mergePages(repeating_data_forms_pages, "repeating_data_forms")
    },
    getParticipants = function(study_id, filter_archived = TRUE) {
      if (self$verbose) message("Getting all participants for study ", study_id)

      participants_pages <- self$getParticipantsPages(study_id)
      participants_merged <- private$mergePages(participants_pages, "participants")

      if (filter_archived && isTRUE(nrow(participants_merged) > 0))
        participants_merged <-
        participants_merged[!grepl("ARCHIVED", participants_merged[["participant_id"]]), ]

      return(participants_merged)
    },
    getStudyDataPointsBulkByParticipant = function(study_id, participant_id) {
      if (self$verbose)
        message("Getting data points for participant ", participant_id, " from study ",
                study_id)

      sdp_url <- glue("study/{study_id}/participant/{participant_id}",
                      "/data-points/study")

      participant_metadata <- self$getParticipant(study_id, participant_id)

      res <- self$getRequest(sdp_url)

      if (self$verbose)
        print(res)

      if (res$total_items == 0)
        return(data.frame())

      study_data <- mutate(
        spread(
          select(res[["_embedded"]][["items"]],
                 field_id, field_value, Participant_ID = participant_id),
          field_id, field_value),
        Site_Abbreviation =
          participant_metadata[["_embedded"]]$site$abbreviation,
        Randomization_Group =
          ifelse(is.null(participant_metadata$randomization_group), NA,
                 participant_metadata$randomization_group),
        Participant_Creation = participant_metadata$created_on$date
      )

      fields <- self$getFields(study_id)

      fields <- fields[!is.na(fields$field_variable_name), ]

      id_to_field_name_ <- split(fields$field_variable_name, fields$field_id)

      rename_at(study_data,
                vars(-Participant_ID, -Participant_Creation, -Randomization_Group,
                     -Site_Abbreviation),
                ~unlist(id_to_field_name_, recursive = FALSE)[.])

    },
    getStudyDataPointsBulk = function(study_id_ = FALSE) {
      sdpb_url <- glue("study/{study_id_}/data-points/study")

      private$mergePages(self$collectPages(sdpb_url, page_size = 5000), "items")
    },
    getOptionGroups = function(study_id = FALSE) {
      og_url <- glue("study/{study_id}/field-optiongroup")

      private$mergePages(self$collectPages(og_url, page_size = 1000), "fieldOptionGroups")
    },
    getRepeatingDataInstancesByParticipant = function(study_id, participant_id) {
      repeating_data_url <- glue("study/{study_id}/participant/{participant_id}",
                         "/data-points/repeating-data-instance")

      result <- private$mergePages(self$collectPages(repeating_data_url,
                                                     page_size = 1000),
                                   "items")

      if (nrow(result) > 0)
        result
      else
        NULL
    },
    getRepeatingDataInstances = function(study_id, participant_id = NULL,
                                  id_to_field_name = NULL) {
      self$getRepeatingDataInstancesBulk(study_id, participant_id_ = participant_id,
                                  id_to_field_name_ = id_to_field_name)
    },
    getRepeatingDataInstancesBulk = function(study_id_,
                                      participant_id_ = NULL,
                                      id_to_field_name_ = NULL,
                                      page_size = NULL) {
      if (!is.null(participant_id_)) {
        repeating_data_instances <- self$getRepeatingDataInstancesByParticipant(
          study_id = study_id_, participant_id = participant_id_)
      } else {
        ri_url <- glue("study/{study_id_}/data-points",
                       "/repeating-data-instance")

        repeating_data_instances <- private$mergePages(
          self$collectPages(ri_url, page_size = page_size,
                            enable_pagination = "true"),
          "items")
      }

      if (!isTRUE(nrow(repeating_data_instances) > 0)) {
        warning("No repeating_data instances data for ", study_id_)
        return(NULL)
      }

      repeating_data_inst_fields <- c("field_id", "repeating_data_instance_id", "field_value",
                              "participant_id")

      ri_metadata <- self$getRepeatingDataInstanceMetadata(study_id_)

      repeating_data_inst_name_to_id <- cols_to_map(ri_metadata,
                                            "repeating_data_instance_name",
                                            "repeating_data_instance_id")

      repeating_data_instance_to_name <- cols_to_map(ri_metadata,
                                             "repeating_data_instance_name",
                                             "repeating_data_name")

      repeating_data_instances <- left_join(
        repeating_data_instances,
        select(ri_metadata, repeating_data_instance_name, repeating_data_name, created_on)
      )

      repeating_data_fields <- cols_to_map(repeating_data_instances, "repeating_data_name",
                                   "field_id")

      repeating_data_data <- rename(
        spread(
          distinct(
            select(repeating_data_instances, participant_id, field_id, repeating_data_name,
                   created_on, repeating_data_instance_name, field_value)),
          field_id, field_value),
        Participant_ID = participant_id,
        repeating_data_inst_name = repeating_data_instance_name)

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

      repeating_data_data <- rename_at(repeating_data_data,
                               vars(-Participant_ID, -repeating_data_inst_name,
                                    -repeating_data_name, -created_on),
                               ~unlist(id_to_field_name_, recursive = FALSE)[.])

      attr(repeating_data_data, "repeating_data_inst_name_to_id") <- repeating_data_inst_name_to_id
      attr(repeating_data_data, "repeating_data_fields") <- repeating_data_fields

      repeating_data_data
    },
    getRepeatingDataInstanceMetadata = function(study_id) {
      ri_md_pages <- self$getRepeatingDataInstanceMetadataPages(study_id = study_id)
      ri_metadata <- private$mergePages(ri_md_pages, "repeatingDataInstance")

      selected_cols <- c("id", "name", "status", "parent_id", "parent_type",
                         "participant_id", "repeating_data_name", "created_on",
                         "created_by", "_embedded.repeating_data.repeating_data_id",
                         "_embedded.repeating_data.description",
                         "_embedded.repeating_data.type")

      name_map <- c(
        "id" = "repeating_data_instance_id",
        "name" = "repeating_data_instance_name",
        "status" = "repeating_data_instance_status",
        "parent_id" = "repeating_data_instance_parent_id",
        "parent_type" = "repeating_data_instance_parent_type",
        "_embedded.repeating_data.repeating_data_id" = "repeating_data_id",
        "_embedded.repeating_data.description" = "repeating_data_description",
        "_embedded.repeating_data.type" = "repeating_data_type"
      )

      ri_metadata <- ri_metadata[selected_cols]

      rename_at(ri_metadata, names(name_map), ~name_map[.])
    },
    getSurveyInstances = function(study_id, participant_id = NULL,
                                  id_to_field_name = NULL) {
      self$getSurveyInstancesBulk(study_id, participant_id_ = participant_id,
                                  id_to_field_name_ = id_to_field_name)
    },
    getSurveyInstancesBulk = function(study_id_, participant_id_ = NULL,
                                      id_to_field_name_ = NULL) {
      if (is.null(participant_id_)) {
        si_url <- glue("study/{study_id_}/data-points",
                       "/survey-instance")
      } else {
        si_url <- glue("study/{study_id_}/participant/{participant_id_}",
                       "/data-points/survey-instance")
      }

      survey_instances <- private$mergePages(
        self$collectPages(si_url, page_size = 5000), "items")

      if (!isTRUE(nrow(survey_instances) > 0)) {
        warning("No survey instances data for ", study_id_)
        return(NULL)
      }

      survey_inst_fields <- c("field_id", "survey_instance_id", "field_value",
                              "participant_id", "survey_name")

      survey_data <- rename(
        spread(
          distinct(
            select(survey_instances, survey_instance_id, participant_id, field_id,
                   survey_name, field_value)),
          field_id, field_value),
        Participant_ID = participant_id,
        package_name = survey_name)

      if (!is.null(id_to_field_name_))
        rename_at(survey_data, vars(-Participant_ID, -package_name,
                                    -survey_instance_id),
                  ~unlist(id_to_field_name_, recursive = FALSE)[.])
      else
        survey_data
    },
    getSurveyInstanceBulk = function(study_id, participant_id, survey_instance_id) {
      si_url <- glue("study/{study_id}/participant/{participant_id}",
                     "/data-points/survey-instance",
                     "/{survey_instance_id}")

      self$getRequest(si_url)[["_embedded"]][["items"]] %>%
        select(field_id, survey_instance_id, field_value, participant_id) %>%
        spread(field_id, field_value)
    },
    getSurveyPackageInstanceBulk = function(study_id, participant_id,
                                            survey_package_instance_id) {
      spi_url <- glue("study/{study_id}/participant/{participant_id}",
                      "/data-points",
                      "/survey-package-instance/{survey_package_instance_id}")

      self$getRequest(si_url)[["_embedded"]][["items"]] %>%
        select(field_id, survey_instance_id, field_value, participant_id) %>%
        spread(field_id, field_value)
    },
    getStudyDataPoints = function(study_id, participant_id = NULL,
                                  filter_types = NULL, bulk_by_participant = FALSE) {
      if (self$verbose)
        message("Getting data points for participant ", participant_id, " from study ",
                study_id)

      if (bulk_by_participant)
        return(self$getStudyDataPointsBulkByParticipant(study_id, participant_id))
      else {
        # Request the pages for the participants with getStudyDataPointsPages.
        sdp_pages <- self$getStudyDataPointsPages(study_id, participant_id)
        # If there is more than one page, use Reduce to merge the data frames
        # within the list into a single data frame.
        sdp_merged <- private$mergePages(sdp_pages, "StudyDataPoints")
      }

      # Fetch the participant metadata from the API in order to fortify the dataset
      # with information about the study.
      participant_metadata <- self$getParticipant(study_id, participant_id)


      if (nrow(sdp_merged) == 0) {
        warning("No data points for study id ", study_id, " and participant id ",
                participant_id, "\n",
                "returning data frame with just participant metadata.")

        empty.df <- data.frame(
          "Site Abbreviation" =
            participant_metadata[["_embedded"]][["site"]][["abbreviation"]],
          "Randomization Group" =
            ifelse(is.null(participant_metadata[["randomization_group"]]), NA,
                   participant_metadata[["randomization_group"]]),
          "Participant Creation" = participant_metadata[["created_on"]][["date"]],
          "Participant_ID" = participant_id
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

      # Add the participant id as a column to the data.
      study_data_points.df[["Participant_ID"]] <- participant_id

      # Randomization ID should be in participant data.
      study_data_points.df[["Site_Abbreviation"]] <-
        participant_metadata[["_embedded"]][["site"]][["abbreviation"]]
      study_data_points.df[["Randomization_Group"]] <-
        ifelse(is.null(participant_metadata[["randomization_group"]]),
               NA,
               participant_metadata[["randomization_group"]])
      study_data_points.df[["Participant_Creation"]] <-
        participant_metadata[["created_on"]][["date"]]

      return(study_data_points.df)
    },
    getStudyDataBulk = function(study_id., field_info., participant_metadata) {
      study_data <- self$getStudyDataPointsBulk(study_id.)
      if (isTRUE(nrow(study_data) > 0)) {
        study_data_field_info <- distinct(left_join(study_data, field_info., by = "field_id"))
        study_data_long <- select(study_data_field_info,
                                  field_variable_name, participant_id, field_value)
        study_data_wide <- spread(study_data_long,
                                  field_variable_name, field_value)
        study_data_compelete_cases <- filter_all(study_data_wide,
                                                 any_vars(!is.na(.)))

        rename(
          left_join(
            select(
              participant_metadata,
              participant_id,
              Randomization_Group = randomization_group,
              Site_Abbreviation = `_embedded.site.abbreviation`,
              Participant_Creation = created_on.date),
            study_data_compelete_cases,
            by="participant_id"
          ),
          Participant_ID = participant_id
        )
      } else
        NULL
    },
    getFieldInfo = function(study_id) {
      fields <- self$getFields(study_id)
      if (!is.null(fields))
        mutate(fields,
               field_variable_name = if_else(is.na(field_variable_name) |
                                               field_variable_name == "<NA>" |
                                               field_variable_name == "",
                                             field_id,
                                             as.character(field_variable_name))
               )
      else
        NULL
    },
    generateFieldMetadata = function(study_id, field_info) {
      forms <- self$getForms(study_id)

      if (missing(field_info) || is.null(field_info))
        field_info <- self$getFieldInfo(study_id)

      if (!is.null(forms)) {
        fields_forms <- merge(forms[c("id", "form_order")],
                              field_info[c("parent_id", "field_variable_name",
                                           "field_number")],
                              by.x = "id", by.y = "parent_id", all.y = TRUE)

        fields_forms$fullform <-
          suppressWarnings(as.integer(paste0(fields_forms$form_order,
                            sprintf("%02d", fields_forms$field_number))))
      } else {
        fields_forms <- field_info
        fields_forms$fullform <- fields_forms$field_number
      }

      checkbox_fields <- self$generateCheckboxFields(field_info = field_info)

      if (!is.null(checkbox_fields)) {
        name_map <- bind_rows(
          imap(checkbox_fields,
               ~tibble(adjusted_field_variable_name = .x,
                       field_variable_name = .y)))

        field_order <- left_join(fields_forms, name_map, by="field_variable_name")
      } else {
        field_order <- fields_forms
        field_order$adjusted_field_variable_name <-
          field_order$field_variable_name
      }

      field_order$adjusted_field_variable_name <-
        ifelse(is.na(field_order$adjusted_field_variable_name),
               field_order$field_variable_name,
               field_order$adjusted_field_variable_name)

      metadata_fields <- c("Participant_ID", "Site_Abbreviation",
                           "Randomization_Group", "Participant_Creation")

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
        fullform = case_when(
          field_variable_name == "Participant_ID" ~ 1,
          field_variable_name == "Site_Abbreviation" ~ 2,
          field_variable_name == "Randomization_Group" ~ 3,
          field_variable_name == "Participant_Creation" ~ 4,
          TRUE ~ fullform + 4))

      field_order <- field_order[order(field_order$fullform), ]
      field_order <- left_join(select(field_order,
                                      field_variable_name,
                                      adjusted_field_variable_name,
                                      fullform),
                               field_info,
                               by = "field_variable_name")
      if (!is.null(forms))
        field_metadata <- merge(field_order, forms,
                                by.x = "parent_id", by.y = "id",
                                all = TRUE)
      else
        field_metadata <- field_order

      field_metadata$default <- FALSE
      field_metadata$default[field_metadata$adjusted_field_variable_name %in%
                               metadata_fields] <- TRUE

      arrange(field_metadata, fullform)
    },
    getStudyData = function(study_id, bulk = TRUE,
                            load_study_data = TRUE,
                            repeating_data_instances = FALSE,
                            survey_instances = FALSE,
                            filter_types = c("remark", "image", "summary",
                                             "upload", "repeated_measures",
                                             "add_repeating_data_button")) {
      metadata_fields <- c("Participant_ID", "Site_Abbreviation",
                           "Randomization_Group",
                           "Participant_Creation")
      participant_metadata <- self$getParticipants(study_id)
      # Get field metadata for the given study to be used in adjustTypes.
      field_info <- self$getFieldInfo(study_id)

      if (is.null(field_info))
        return(NULL)

      if (load_study_data) {
        if (bulk) {
          all_data_points.df <- self$getStudyDataBulk(study_id, field_info,
                                                      participant_metadata)
        } else {
          # Get study data from getStudyDataPoints and collect them by participant in a
          # list.
          study_data <- lapply(participant_metadata$participant_id, function(participant) {
            if (self$verbose) message("getting participant ", participant)
            return(self$getStudyDataPoints(study_id, participant, filter_types))
          })

          all_data_points.df <- bind_rows(study_data)
        }
      } else {
        all_data_points.df <- rename(
          select(
            participant_metadata,
            participant_id,
            Randomization_Group = randomization_group,
            Site_Abbreviation = `_embedded.site.abbreviation`,
            Participant_Creation = created_on.date
          ),
          Participant_ID = participant_id
        )
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

      if ("Participant_Creation" %in% names(adjusted_data_points.df))
        adjusted_data_points.df[["Participant_Creation"]] <-
        as.POSIXct(adjusted_data_points.df[["Participant_Creation"]], tz = "GMT")

      if (repeating_data_instances || survey_instances)
        id_to_name <- cols_to_map(field_metadata, "field_id",
                                  "field_variable_name")

      if (repeating_data_instances) {
        repeating_data_instances <- self$getRepeatingDataInstances(
          study_id = study_id, id_to_field_name = id_to_name)
        if (!is.null(repeating_data_instances)) {
          repeating_data_fields <- attr(repeating_data_instances, "repeating_data_fields")

          repeating_data_fields <- imap(repeating_data_fields, function(fields, repeating_data) {
            pull(filter(field_metadata, field_id %in% fields),
                 adjusted_field_variable_name)
          })

          repeating_data_instances <- self$adjustCheckboxFields(
            repeating_data_instances,
            filter(field_metadata,
                   field_variable_name %in% names(repeating_data_instances) &
                     field_type == "checkbox"))

          attr(repeating_data_instances, "repeating_data_fields") <- repeating_data_fields

          attr(adjusted_data_points.df, "repeating_data_instances") <- repeating_data_instances
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
        # message("Only one page from API to return")
        # Otherwise, just return the data frame from the only page that exists.
        pages_merged <- pages[[1]][[key]][[subkey]]
      }

      if (identical(pages_merged, list()))
          pages_merged <- NULL

      return(pages_merged)
    }
  )
)
