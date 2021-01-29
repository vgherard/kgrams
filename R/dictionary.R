new_kgrams_dictionary <- function(cpp_obj) {
        structure(list(), cpp_obj = cpp_obj, class = "kgrams_dictionary")
}

#' @export
kgrams_dictionary <- function(object, ...) {
        if (missing(object) || is.null(object))
                return(kgrams_dictionary_missing())
        UseMethod("kgrams_dictionary")
}
        

#' @export
kgrams_dictionary.character <- function(object, ...)
{
        cpp_obj <- new(Dictionary)
        args <- list(...)
        if (!is.null(args[["size"]])) {
                # if cov and thresh: warning
                cpp_obj$insert_n(object, args[["size"]])
        } else if (!is.null(args[["cov"]])) {
                # if thresh: warning
                cpp_obj$insert_cover(object, args[["cov"]])
        } else if (!is.null(args[["thresh"]])) {
                # if other arguments: warning
                cpp_obj$insert_above(object, args[["thresh"]])
        } else {
                cpp_obj$insert_above(object, 0L)
        }
        new_kgrams_dictionary(cpp_obj)
}

kgrams_dictionary_missing <- function() {
        cpp_obj <- new(Dictionary)
        return(new_kgrams_dictionary(cpp_obj))
}

as.kgrams_dictionary <- function(object) {
        if (missing(object) || is.null(object))
                return(kgrams_dictionary_missing())
        UseMethod("as.kgrams_dictionary")
}
        

#' @export
as.kgrams_dictionary.kgrams_dictionary <- function(object) return(object)

#' @export
as.kgrams_dictionary.character <- function(object) {
        cpp_obj <- new(Dictionary, object)
        return(new_kgrams_dictionary(cpp_obj))
}

#' @export
length.kgrams_dictionary <- function(x)
       attr(x, "cpp_obj")$length()