#' @export
query <- function(object, x, ...) 
        UseMethod("query", object)

#' @export
query.kgram_freqs <- function(object, x) {
        attr(object, "cpp_obj")$query(x)
}

#' @export
query.kgrams_dictionary <- function(object, x) {
        attr(object, "cpp_obj")$query(x)
}