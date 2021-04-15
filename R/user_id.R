
#' Checks if user information is a user_id or screen_name
#'
#' @param x A twitter user_id or screen_name
#' @param arg_name Name of the argument to return in error message
#'
#' @return Either "user_id" or "screen_name"
#' @export
user_type <- rtweet:::user_type

#' Get the screen name of the authenticated user
#'
#' @param token Token
#'
#' @export
api_screen_name <- rtweet:::api_screen_name
