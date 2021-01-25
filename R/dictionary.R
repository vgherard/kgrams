new_kgrams_dictionary <- function(xptr) {
        structure(list(), cpp_obj = xptr, class = "kgrams_dictionary")
}

#' @export
kgrams_dictionary <- function(object, ...) {
        if (missing(object) || is.null(object))
                return(kgrams_dictionary_default())
        UseMethod("kgrams_dictionary")
}

#' @export
kgrams_dictionary.kgram_freqs <- function(object) {
        xptr <- get_dict_xptr(attr(object, "cpp_obj"))
        return(new_kgrams_dictionary(xptr))
}

kgrams_dictionary_default <- function() {
        temp <- new(kgramFreqs)
        xptr <- get_dict_xptr(temp)
        return(new_kgrams_dictionary(xptr))
}

#' @export
length.kgrams_dictionary <- function(x)
        length_kgrams_dictionary(attr(x, "cpp_obj"))

