
#' Checks if user information is a user_id or screen_name
#'
#' @param x A twitter user_id or screen_name
#' @param arg_name Name of the argument to return in error message
#'
#' @return Either "user_id" or "screen_name"
#' @export
user_type <- function(x, arg_name = "user") {
  if (is.numeric(x)) {
    "user_id"
  } else if (is.character(x)) {
    if (inherits(x, "rtweet_screen_name")) {
      # needed for purely numeric screen names
      "screen_name"
    } else if (all(grepl("^[0-9]+$", x))) {
      "user_id"
    } else {
      "screen_name"
    }
  } else {
    stop("`", arg_name, "` must be a screen name or user id", call. = FALSE)
  }
}

#' Get the screen name of the authenticated user
#'
#' @param token Token
#'
#' @export
api_screen_name <- function(token = NULL) {
  params <- list(
    include_entities = FALSE,
    skip_status = TRUE,
    include_email = FALSE
  )
  r <- TWIT_get(token, "/1.1/account/verify_credentials", params)
  r$screen_name
}
