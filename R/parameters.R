#' Language Model Parameters
#' 
#' Get and set parameters of a language model
#' 
#' @name parameters

#' @rdname parameters
#' @export
param <- function(object, which) {
        if (!is.character(which))
                rlang::abort("'which' must be a length one character vector.",
                             class = "domain_error")
        UseMethod("param", object)
}

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

#' @export
`param<-.kgram_freqs` <- function(object, which, value)
        rlang::abort("Parameters of \"kgram_freqs\" objects cannot be set.")

#' @export
`param<-.language_model` <- function(object, which, value) {
        
        if (which == "V") {
                h <- paste0("Dictionary size cannot be set.")
                rlang::abort(h, class = "read_only_par_error")
        }
        
        if ( is.null(attr(object, "cpp_obj")[[which]]) ) {
                smoother <- class(object)[[2]]
                h <- paste0("\"", which, 
                            "\" is not a valid parameter for smoother \"",
                            smoother, "\".")
                i <- paste0("See info(\"", smoother, "\") or ?param.")
                rlang::abort(c(h, i = i), class = "smoother_invalid_parameter")
        }
        
        attr(object, "cpp_obj")[[which]] <- value
        return(object)
}

#' @rdname parameters
#' @export
parameters <- function(object) 
        UseMethod("parameters", object)

#' @export
parameters.kgram_freqs <- function(object)
        list(N = param(object, "N"), V = param(object, "V"))

#' @export
parameters.language_model <- function(object) {
        smoother <- class(object)[[2]]
        names <- sapply(list_parameters(smoother), function(x) x$name)
        names <- c("N", "V", names)
        res <- lapply(names, function(name) param(object, name))
        names(res) <- names
        return(res)
}