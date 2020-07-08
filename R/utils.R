#' @include imports.R
NULL

#' @importFrom stats setNames
split_checkbox <- function(values, field_info, sep_ = ";") {
  cat("checkbox values:\n")
  print(values)
  cat("checkbox field info:\n")
  print(field_info)
  num_vals <- length(values)
  if (num_vals > 0) {
    values <- strsplit(values, sep_)
    values <- lapply(values, function(values_) {
      if (length(values_) == 0)
        NA
      else
        values_
    })
  } else {
    values <- rep(NA, num_vals)
  }

  field <- names(field_info)

  checkbox_result <- rename_all(
    mutate_all(
      bind_rows(
        lapply(values, function(value) {
          checkboxes <- as.data.frame(split(rep(TRUE, length(value)),
                                            paste0(field, ".", value)))
          if (nrow(checkboxes) > 0)
            checkboxes
          else
            data.frame()
        })
      ),
      replace_na, FALSE
    ),
    ~gsub("[.]", "#", .)
  )

  pad_fields <- setdiff(field_info[[field]], names(checkbox_result))
  empty_checkboxes <- bind_cols(
    map(pad_fields, function(pad_field) {
      setNames(list(rep(FALSE, min(num_vals, 1))), pad_field)
    })
  )
  
  cat("checkbox_result:\n")
  print(checkbox_result)
  cat("\n\nempty_checkboxes:\n")
  print(empty_checkboxes)
  cat("\n\nfield_info[[field]]:\n")
  print(field_info[[field]])
  
  select(
    bind_cols(checkbox_result, empty_checkboxes),
  one_of(field_info[[field]]))
}

split_checkboxes <- function(checkbox_data, checkbox_field_info, sep = ";") {
  bind_cols(
    imap(checkbox_data, function(field_data, field) {
      split_checkbox(field_data, checkbox_field_info[field], sep)
    })
  )
}

#' cols_to_map
#'
#' Generates a named list based on two columns from a data frame.
#'
#' @param dataframe A data frame
#' @param key A string of a column name in the data frame
#' @param value A string of a column name in the data frame
#'
#' @return A named list, with the names from the key field and values from
#' the value field
#' @export
#'
#' @examples
#' cols_to_map(mtcars, key = "cyl", value = "mpg")
cols_to_map <- function(dataframe, key, value) {
  if (missing(key) || missing(value))
    stop("Must provide key and value fields to generate map (named list).")

  if (!is.data.frame(dataframe))
    stop("dataframe is not a valid dataframe")

  if (!all(c(key, value) %in% names(dataframe)))
    stop("key and value must both be present in dataframe")

  dataframe <- unique(dataframe[c(key, value)])

  split(dataframe[[value]], dataframe[[key]])
}
