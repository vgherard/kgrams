new_kgrams_dictionary <- function(cpp_obj) {
        structure(list(), cpp_obj = cpp_obj, class = "kgrams_dictionary")
}

#' @export
kgrams_dictionary <- function(object, ...) {
        if (missing(object) || is.null(object))
                return(kgrams_dictionary_default())
        UseMethod("kgrams_dictionary", object)
}

#' @rdname kgrams_dictionary
#' @export
dictionary <- kgrams_dictionary

#' @export
kgrams_dictionary.kgram_freqs <- function(object, ...) {
        dict_cpp <- attr(object, "cpp_obj")$dictionary()
        return(new_kgrams_dictionary(dict_cpp))
}

#' @export
kgrams_dictionary.character <- function(object, ...) 
{
        args <- list(...)
        if (!is.null(args[["size"]])) {
                # if other arguments: warning
                xptr <- dict_top_n(object, args[["size"]])
        } else if (!is.null(args[["cov"]])) {
                # if other arguments: warning
                xptr <- dict_coverage(object, args[["cov"]])
        } else if (!is.null(args[["threshold"]])) {
                # if other arguments: warning
                xptr <- dict_thresh(object, args[["thresh"]])
        } else {
                xptr <- dict_thresh(object, 0L)
        }
                
        return(new_kgrams_dictionary(xptr))
}

#' @export
kgrams_dictionary.kgrams_dictionary <- function(object, ...) 
        return(object)

kgrams_dictionary_default <- function() {
        cpp_obj <- new(Dictionary)
        return(new_kgrams_dictionary(cpp_obj))
}

#' @export
length.kgrams_dictionary <- function(x)
        attr(x, "cpp_obj")$length()
