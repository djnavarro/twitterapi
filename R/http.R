
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
TWIT_get <- rtweet:::TWIT_get


#' @rdname TWIT
#' @export
TWIT_post <- rtweet:::TWIT_post




#' Pagination
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' These are internal functions used for pagination inside of rtweet.
#'
#' @keywords internal
#' @param token Expert use only. Use this to override authentication for
#'   a single API call. In most cases you are better off changing the
#'   default for all calls. See [auth_as()] for details.
#' @param n Desired number of results to return. Results are downloaded
#'   in pages when `n` is large; the default value will download a single
#'   page. Set `n = Inf` to download as many results as possible.
#'
#'   The Twitter API rate limits the number of requests you can perform
#'   in each 15 minute period. The easiest way to download more than that is
#'   to use `retryonratelimit = TRUE`.
#'
#'   You are not guaranteed to get exactly `n` results back. You will get
#'   fewer results when tweets have been deleted or if you hit a rate limit.
#'   You will get more results if you ask for a number of tweets that's not
#'   a multiple of page size, e.g. if you request `n = 150` and the page
#'   size is 200, you'll get 200 results back.
#' @param get_id A single argument function that returns a vector of ids given
#'   the JSON response. The defaults are chosen to cover the most common cases,
#'   but you'll need to double check whenever implementing pagination for
#'   a new endpoint.
#' @param max_id Supply a vector of ids or a data frame of previous results to
#'   find tweets **older** than `max_id`.
#' @param since_id Supply a vector of ids or a data frame of previous results to
#'   find tweets **newer** than `since_id`.
#' @param retryonratelimit If `TRUE`, and a rate limit is exhausted, will wait
#'   until it refreshes. Most twitter rate limits refresh every 15 minutes.
#'   If `FALSE`, and the rate limit is exceeded, the function will terminate
#'   early with a warning; you'll still get back all results received up to
#'   that point. The default value, `NULL`, consults the option
#'   `rtweet.retryonratelimit` so that you can globally set it to `TRUE`,
#'   if desired.
#'
#'   If you expect a query to take hours or days to perform, you should not
#'   rely soley on `retryonratelimit` because it does not handle other common
#'   failure modes like temporarily losing your internet connection.
#' @param parse If `TRUE`, the default, returns a tidy data frame. Use `FALSE`
#'   to return the "raw" list corresponding to the JSON returned from the
#'   Twitter API.
#' @param verbose Show progress bars and other messages indicating current
#'   progress?
#'
#' @export
TWIT_paginate_max_id <- rtweet:::TWIT_paginate_max_id


# https://developer.twitter.com/en/docs/pagination
#' @rdname TWIT_paginate_max_id
#'
#' @param cursor Which page of results to return. The default will return
#'   the first page; you can supply the result from a previous call to
#'   continue pagination from where it left off.
#'
#' @export
TWIT_paginate_cursor <- rtweet:::TWIT_paginate_cursor


#' @rdname TWIT_paginate_max_id
#'
#' @export
TWIT_paginate_chunked <- rtweet:::TWIT_paginate_chunked
