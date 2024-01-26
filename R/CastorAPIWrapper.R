#' @include CastorData.R
#' @include utils.R
NULL

#' Class used to wrap Castor REST API.
#'
#'
#' @section Methods:
#' \itemize{
#'  \item \code{getRequest(req_path, query_data): Sends a request to the API
#'  given a url path and any query parameters (such as page number or include
#'  arguments).}
#'  \item \code{collectPages(request_url, page, include: }
#'  \item \code{getStudy(study_id): Retrieves information about given study.}
#'  \item \code{getStudiesPages(): Retries all Castor studies in account.}
#'  \item \code{getForm(study_id, form_id): Retrieves information about given study.}
#'  \item \code{getFormsPages(): Retries all Castor studies in account.}
#'  \item \code{getField(study_id, field_id, include): Gets a specified
#'  field.
#'  }
#'  \item \code{getFieldsPages(study_id, include, page): Gets all fields pages
#'  for a given study.
#'  }
#'  \item \code{getParticipant(study_id, participant_id): Gets a specified
#'  participant.
#'  }
#'  \item \code{getParticipantPages(study_id: Gets all participants for a given
#'  study.
#'  }
#'  \item \code{getStudyDataPoint(study_id, participant_id,
#'                                field_id: Gets an individual data
#'  point for a given study, participant and field.
#'  }
#'  \item \code{getStudyDataPointsPages(study_id, participant_id,
#'                                      filter_types: Gets all data
#'  points for a given study and participant Filter types may be supplied for fields
#'  types as a character vector of field types.
#'  }
#' }
#' @docType class
#' @keywords internal
#' @format An R6 class object.
#' @importFrom R6 R6Class
#' @export
#' @name CastorAPIWrapper-class
CastorAPIWrapper <- R6::R6Class("CastorAPIWrapper",
  public = list(
   username = NULL,
   base_url = NULL,
   oauth_token = NULL,
   retries = 0,
   retry_limit = 2,
   key = NULL,
   access_token = NULL,
   type_to_func = list(
     date = function(date_val) as.Date(date_val, "%d-%m-%Y"),
     year = function(value) as.integer(transform_missings(value)),
     numeric = function(value) as.numeric(transform_missings(value)),
     calculation = function(value) as.numeric(transform_missings(value)),
     radio = as.factor
   ),
   verbose = FALSE,
   initialize = function(username, password,
                         key, secret,
                         access_token = NULL,
                         type_to_func = self$type_to_func,
                         base_url = "https://dev.do.castoredc.com/",
                         verbose = self$verbose) {
     if (is.logical(self$verbose))
       self$verbose <- verbose
     base_url <- httr::modify_url(base_url, path = "/")

     if (missing(username) & missing(password) &
         !(missing(key) | missing(secret)) & is.null(access_token)) {
       private$secret <- secret
       self$key <- key
       self$castorOAuth(key, secret, base_url)
     } else if (!(missing(username) | missing(password))) {
       self$username <- username
       private$password <- password
     } else if (!is.null(access_token)) {
       self$access_token <- access_token
     }

     self$base_url <- base_url
     self$type_to_func <- type_to_func
     options(stringsAsFactors = FALSE)
   },
   castorOAuth = function(key, secret, baseurl) {
     castor_app = httr::oauth_app("CastorEDC", key = key, secret = secret)

     castor_endpoint = httr::oauth_endpoint(request = NULL,
                                            base_url = paste0(baseurl, "oauth"),
                                            access = "token",
                                            "authorize")

     castor_token = httr::oauth2.0_token(castor_endpoint,
                                         castor_app,
                                         client_credentials = TRUE,
                                         use_oob = FALSE,
                                         cache = FALSE)

     self$oauth_token <- castor_token
   },
   getRequest = function(req_path, query_data = list(), raw = FALSE) {
      api_req_path <- paste0("api/", req_path)
      if (self$verbose) message("Getting ", file.path(self$base_url, req_path))

      if (!is.null(self$access_token)) {
        headers <- add_headers(Authorization = paste('Bearer',
                                                     self$access_token))
        request <- GET(self$base_url, path = api_req_path,
                      query = query_data, headers, accept_json())
      } else if (is.null(self$oauth_token) & !(is.null(self$username) |
                                              is.null(private$password))) {
        basic_auth <- authenticate(self$username, private$password,
                                  type = "basic")
        request <- GET(self$base_url, path = api_req_path, query = query_data,
                       basic_auth)
      } else if (!is.null(self$oauth_token)) {
        request <- GET(self$base_url, path = api_req_path, query = query_data,
                      config(token = self$oauth_token), accept_json())

        if (request$status_code == 401) {
          warning("Invalid token")
          self$castorOAuth(self$key, private$secret, self$base_url)
          if (self$retries < self$retry_limit) {
            self$retries <- self$retries + 1
            self$getRequest(req_path, query_data, raw)
          } else {
            stop("\nRetry limit reached and credentials still not valid:",
                "\nError code: ", request$status_code,
                "\nHeaders: ", request$headers,
                "\nContent: ", content(request, as = "text", encoding = "UTF-8"))
          }
        } else if (request$status_code != 200) {
          stop("Check your credentials -- requests cannot be made with current credentials.",
               "\nError with request for ", request$url,
               "\nError code: ", request$status_code,
               "\nHeaders: ", request$headers,
               "\nContent: ", content(request, as = "text", encoding = "UTF-8"))
        }
      }

      # Reset the retries counter here because it implies a successful request
      self$retries <- 0
      if (self$verbose) {
        print(request)
        print(fromJSON(content(request, "text", encoding = "UTF-8")))
      }
      # Allow user to request raw JSON response. Otherwise go JSON to data frame
      # and flatten the data.
      if (raw) {
        result <- content(request, "text", encoding = "UTF-8")
      } else {
        result <- tryCatch({
          fromJSON(content(request, "text", encoding = "UTF-8"), flatten = TRUE)
        }, error = function(e) {
          stop("The request content could not be parsed to JSON.\n",
               "This is the raw content:\n",
               content(request, "text", encoding = "UTF-8"),
               "And this is the error:\n", e)
        })
      }

      return(result)
   },
   collectPages = function(request_url, page = NULL, include = NULL,
                           page_size = NULL, ...) {
     if (!is.null(page)) {
       if (page %% 1 != 0)
         stop(sprintf("page must be an integer. `%s` is not an integer.",
                      page))
     }
#
#      if (page_size %% 1 != 0)
#        stop(sprintf("page_size must be an integer. `%s` is not an integer.",
#                     page))

     query_params <- list(...)
     query_params$page_size <- page_size
     query_params$page <- page
     query_params$include <- include

     pages <- list(self$getRequest(request_url, query_data = query_params))

     if (is.null(pages[[1]]$page_count))
       page_count <- 1
     else
       page_count <- pages[[1]]$page_count

     if (!is.null(page)) {
       if (page > page_count | page < 1)
         stop(sprintf("page out of range: requested page `%s` of `%s` pages available",
                      page, page_count))
     }

     if (self$verbose) message("Total number of pages: ", page_count)
     if (self$verbose) message("Total number of items: ", pages[[1]]$total_items)

     # Get other pages and append them to the list.
     if (page_count > 1 & is.null(page)) {
       pages <- c(
         pages,
         lapply(
           seq(2, page_count),
           function(pagenum) {
             query_params$page <- pagenum
             self$getRequest(request_url, query_data = query_params)
           }
         )
       )
     }

     return(pages)
   },
   getStudy = function(study_id) {
     # Returns a single study.
     study <- self$getRequest(paste0("study/", study_id))
     return(study)
   },
   getStudiesPages = function(page = NULL) {
     # Returns a list pages for of forms for a given study.
     studies_url <- "study"
     studies <- self$collectPages(studies_url,
                                  page = page)
     return(studies)
   },
   getUsersPages = function(page = NULL) {
     # Returns a list pages for the user endpoint (should be just one record)
     users_url <- "user"
     users <- self$collectPages(users_url,
                                page = page)
     return(users)
   },
   getForm = function(study_id, form_id) {
     # Returns a single study.
     study <- self$getRequest(paste0("study/", study_id, "/form/", form_id))
     return(study)
   },
   getFormsPages = function(study_id, page = NULL) {
     # Returns a list pages for of forms for a given study.
     forms_url <- paste0("study/", study_id, "/form")
     forms <- self$collectPages(forms_url,
                                page = page)
     return(forms)
   },
   getVisit = function(study_id, visit_id) {
     # Returns a single study.
     study <- self$getRequest(paste0("study/", study_id, "/visit/", visit_id))
     return(study)
   },
   getVisitsPages = function(study_id, page = NULL) {
     # Returns a list pages for of visits for a given study.
     visits_url <- paste0("study/", study_id, "/visit")
     visits <- self$collectPages(visits_url,
                                 page = page)
     return(visits)
   },
   getSurvey = function(study_id, survey_id) {
     # Returns a single study.
     study <- self$getRequest(paste0("study/", study_id, "/survey/", survey_id))
     return(study)
   },
   getSurveysPages = function(study_id, include = "forms", page = NULL) {
     # Returns a list pages for of surveys for a given study.
     surveys_url <- paste0("study/", study_id, "/survey")
     surveys <- self$collectPages(surveys_url,
                                  page = page, include = include)
     return(surveys)
   },
   getSurveyPackage = function(study_id, surveypackage_id) {
     req_url <- glue("study/{study_id}/surveypackage/{surveypackage_id}")
     self$getRequest(req_url)
   },
   getSurveyPackagesPages = function(study_id, page = NULL) {
     # Returns a list pages for of surveypackages for a given study.
     surveypackages_url <- glue("study/{study_id}/surveypackage")
     self$collectPages(surveypackages_url, page = page)
   },
   getSurveyPackageInstance = function(study_id, surveypackageinstance_id) {
     # Returns a single study.
     req_url <- glue("study/{study_id}/survey-package-instance/",
                     "{surveypackageinstance_id}")
     self$getRequest(req_url)
   },
   getSurveyPackageInstancesPages = function(study_id, page = NULL) {
     # Returns a list pages for of surveypackageinstances for a given study.
     req_url <- glue("study/{study_id}/survey-package-instance")
     self$collectPages(req_url, page = page)
   },
   getRepeatingData = function(study_id, repeating_data_id, include = NULL) {
     # Returns a single repeating_data.
     self$getRequest(glue("study/{study_id}/repeating-data/{repeating_data_id}"),
                     query_data = list(include = include))
   },
   getRepeatingDatasPages = function(study_id,
                              include = "optiongroup",
                              page = NULL) {
     # Gets all repeating_datas, with each page going into a list. Returns a list.
     repeating_datas_url <- glue("study/{study_id}/repeating-data")
     self$collectPages(repeating_datas_url, page = page, include = include)
   },
   getRepeatingDataForm = function(study_id, repeating_data_id, repeating_data_form_id) {
     # Returns a single study.
     study <- self$getRequest(paste0("study/", study_id, "/repeating-data/", repeating_data_id,
                                     "/repeating-data-form/", repeating_data_form_id))
     return(study)
   },
   getRepeatingDataFormsPages = function(study_id, repeating_data_id,
                                  page = NULL) {
     # Returns a list pages for of repeating-data-forms for a given study.
     repeating_data_forms_url <- paste0("study/", study_id, "/repeating-data/", repeating_data_id,
                                "/repeating-data-form")
     repeating_data_forms <- self$collectPages(repeating_data_forms_url,
                                       page = page)
     return(repeating_data_forms)
   },
   getField = function(study_id, field_id, include = NULL) {
     field_url <- glue("study/{study_id}/field/{field_id}")
     self$getRequest(field_url, query_data = list(include = include))
   },
   getFieldsPages = function(study_id, include = "optiongroup", page = NULL) {
     fields_url <- glue("study/{study_id}/field")
     self$collectPages(fields_url, page = page, include = include)
   },
   getParticipant = function(study_id, participant_id) {
     participant_url <- glue("study/{study_id}/participant/{participant_id}")
     self$getRequest(participant_url)
   },
   getParticipantsPages = function(study_id, page = NULL) {
     participants_url <- glue("study/{study_id}/participant")
     self$collectPages(participants_url, page = page)
   },
   getStudyDataPoint = function(study_id, participant_id, field_id) {
     # Get API response for individual study data point.
     sdp_url <- glue("study/{study_id}/participant/{participant_id}/",
                     "study-data-point/{field_id}")
     self$getRequest(sdp_url)
   },
   getStudyDataPointsPages = function(study_id, participant_id, page = NULL) {
     sdp_url <- glue("study/{study_id}/participant/{participant_id}/study-data-point")
     self$collectPages(sdp_url, page = page)
   },
   getRepeatingDataInstanceMetadataPages = function(study_id, page = NULL) {
     ri_md_url <- glue("study/{study_id}/repeating-data-instance")
     self$collectPages(ri_md_url, page = page)
   }
  ),
  private = list(
    password = NULL,
    secret = NULL
  )
)
