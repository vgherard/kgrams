#' Language Model Parameters
#' 
#' Get and set parameters of a language model
#' 
#' @name parameters
#'
#'

#' @rdname parameters
#' @export
param <- function(object, which) {
        if (!is.character(which))
                rlang::abort("'which' must be a length one character vector.",
                             class = "domain_error")
        UseMethod("param", object)
}

#' @rdname parameters
#' @export
param.language_model <- function(object, which) {
        res <- attr(object, "cpp_obj")[[which]]
        return(res)
}

#' @rdname parameters
#' @export
param.kgram_freqs <- function(object, which) {
        res <- attr(object, "cpp_obj")[[which]]
        return(res)
}

#' @rdname parameters
#' @export
`param<-` <- function(object, which, value) {
        if (!is.character(which))
                rlang::abort("'which' must be a length one character vector.",
                             class = "domain_error")
        UseMethod("param<-", object)
}

#' @rdname parameters
#' @export
`param<-.kgram_freqs` <- function(object, which, value)
        rlang::abort("Parameters of \"kgram_freqs\" objects cannot be set.")

#' @rdname parameters
#' @export
`param<-.language_model` <- function(object, which, value) {
        
        if (which %in% c("N", "V")) {
                h <- paste("Parameter \"", which, "\"cannot be set.")
                i <- "See ?param."
                rlang::abort(c(h, i = i), class = "read_only_par_error")
        }
        
        if ( is.null(attr(object, "cpp_obj")[[which]]) ) {
                smoother <- class(object)[[2]]
                h <- paste0("\"", which, 
                            "\" is not a valid parameter for smoother \"",
                            smoother, "\".")
                i <- paste0("See and info(\"", smoother, "\") or ?param.")
                rlang::abort(c(h, i = i), class = "smoother_invalid_parameter")
        }
        
        attr(object, "cpp_obj")[[which]] <- value
        return(object)
}