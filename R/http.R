
#' Send POST and GET requests to the Twitter API
#'
#' @param token the token
#' @param api which API are we using
#' @param params parameters for the query
#' @param ... parameters to be passed to httr::GET or httr::POST
#' @param host the API host
#' @name TWIT
#'
NULL

#' @rdname TWIT
#' @export
TWIT_get <- function(token, api, params = NULL, ..., host = "api.twitter.com") {
  resp <- TWIT_method("GET",
                      token = token,
                      api = api,
                      params = params,
                      ...,
                      host = host
  )

  from_js(resp)
}

#' @rdname TWIT
#' @export
TWIT_post <- function(token, api, params = NULL, body = NULL, ..., host = "api.twitter.com") {
  TWIT_method("POST",
              token = token,
              api = api,
              params = params,
              body = body,
              ...,
              host = host
  )
}

TWIT_method <- function(method, token, api,
                        params = NULL,
                        host = "api.twiter.com",
                        retryonratelimit = NULL,
                        verbose = TRUE,
                        ...) {
  # need scipen to ensure large IDs are not displayed in scientific notation
  # need ut8-encoding for the comma separated IDs
  withr::local_options(scipen = 14, encoding = "UTF-8")

  token <- check_token(token)
  url <- paste0("https://", host, api, ".json")

  repeat({
    resp <- switch(method,
                   GET = httr::GET(url, query = params, token, ...),
                   POST = httr::POST(url, query = params, token, ...),
                   stop("Unsupported method", call. = FALSE)
    )

    switch(resp_type(resp),
           ok = break,
           rate_limit = handle_rate_limit(
             resp, api,
             retryonratelimit = retryonratelimit,
             verbose = verbose
           ),
           error = handle_error(resp)
    )
  })

  resp
}



# helpers -----------------------------------------------------------------


`%||%` <- function (x, y) {
  if (is.null(x))
    y
  else x
}

from_js <- function(resp) {
  if (!grepl("application/json", resp$headers[["content-type"]])) {
    stop("API did not return json", call. = FALSE)
  }
  resp <- httr::content(resp, as = "text", encoding = "UTF-8")
  jsonlite::fromJSON(resp)
}

resp_type <- function(resp) {
  x <- resp$status_code
  if (x == 429) {
    "rate_limit"
  } else if (x >= 400) {
    "error"
  } else {
    "ok"
  }
}

# Three possible exits:
# * skip, if testing
# * return, if retryonratelimit is TRUE
# * error, otherwise
handle_rate_limit <- function(x, api, retryonratelimit = NULL, verbose = TRUE) {
  if (is_testing()) {
    testthat::skip("Rate limit exceeded")
  }

  headers <- httr::headers(x)
  n <- headers$`x-rate-limit-limit`
  when <- .POSIXct(as.numeric(headers$`x-rate-limit-reset`))

  retryonratelimit <- retryonratelimit %||% getOption("rtweet.retryonratelimit", FALSE)

  if (retryonratelimit) {
    wait_until(when, api, verbose = verbose)
  } else {
    message <- c(
      paste0("Rate limit exceeded for Twitter endpoint '", api, "'"),
      paste0("Will receive ", n, " more requests at ", format(when, "%H:%M"))
    )
    abort(message, class = "rtweet_rate_limit", when = when)
  }
}

# I don't love this interface because it returns either a httr response object
# or a condition object, but it's easy to understand and avoids having to do
# anything exotic to break from the correct frame.
catch_rate_limit <- function(code) {
  tryCatch(code, rtweet_rate_limit = function(e) e)
}

is_rate_limit <- function(x) inherits(x, "rtweet_rate_limit")

warn_early_term <- function(cnd, hint, hint_if) {
  warn(c(
    "Terminating paginate early due to rate limit.",
    cnd$message,
    i = if (hint_if) hint,
    i = "Set `retryonratelimit = TRUE` to automatically wait for reset"
  ))
}

# https://developer.twitter.com/en/support/twitter-api/error-troubleshooting
handle_error <- function(x) {
  json <- from_js(x)
  stop(
    "Twitter API failed [", x$status_code, "]\n",
    paste0(" * ", json$errors$message, " (", json$errors$code, ")"),
    call. = FALSE
  )
}

check_status <- function(x, api) {
  switch(resp_type(x),
         ok = NULL,
         rate_limit = ,
         error = handle_error(x)
  )
}

check_token <- function(token = NULL) {
  token <- token %||% rtweet::auth_get()

  if (inherits(token, "Token1.0")) {
    token
  } else if (inherits(token, "rtweet_bearer")) {
    httr::add_headers(Authorization = paste0("Bearer ", token$token))
  } else {
    abort("`token` is not a valid access token")
  }
}
