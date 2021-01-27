#' @export
query <- function(object, x, ...) 
        UseMethod("query", object)

#' @export
query.kgram_freqs <- function(object, x) {
        query_kgram(attr(object, "cpp_obj"), x)
}

#' @export
query.kgrams_dictionary <- function(object, x) {
        query_word(attr(object, "cpp_obj"), x)
}