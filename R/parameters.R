#' Language Model Parameters
#' 
#' Get and set parameters of a language model.
#' 
#' @param object a \code{language_model} or \code{kgram_freqs} class object.
#' @param which a string. Name of the parameter to get or set.
#' @param value new value for the parameter specified by \code{which}. Typically
#' a length one numeric.
#' 
#' @return a list for \code{parameters()}, a single value, typically numeric, 
#' for \code{param()} and \code{param()<-} (the new value, in this last case). 
#' 
#' @details 
#' These functions are used to retrieve or modify the parameters of a 
#' \code{language_model} or a \code{kgram_freqs} object. Any object of, 
#' or inheriting from, any of these two classes has at least two parameters:
#' 
#' - \code{N}: higher order of k-grams considered in the model for 
#' \code{language_model}, or stored in memory for \code{kgram_freqs}.
#' - \code{V}: size of the dictionary (excluding the special tokens 
#' \code{BOS()}, \code{EOS()}, \code{UNK()}).
#' 
#' For an object of class \code{kgram_freqs}, these are the only parameters,
#' and they are read-only. \code{language_model}s allow to set \code{N} less 
#' than or equal to the order of the underlying \code{kgram_freqs} object.
#' 
#' In addition to these, \code{language_model}s can have additional parameters,
#' e.g. discount values or interpolation constants, depending on the particular
#' smoother employed by the model. A list of parameters available for a given 
#' smoother can be obtained through \code{info()} 
#' (see \link[kgrams]{smoothers}).
#' 
#' It is important to mention that setting a parameter is an in-place operation. 
#' This implies that if, say, object \code{m} is a \code{language_model} object,
#' the code \code{m1 <- m ; param(m1, which) <- value} will set the parameter
#' \code{which} to \code{value} both for \code{m1} \emph{and} \code{m}. The 
#' reason for this is that, behind the scenes, both \code{m} and \code{m1} are 
#' pointers to the same C++ object. In order to create a true copy, one can use
#' the copy constructor \code{language_model()}, see 
#' \link[kgrams]{language_model}.
#' 
#' @examples
#' # Get and set k-gram model parameters
#' 
#' f <- kgram_freqs("a a b a b", 3)
#' param(f, "N")
#' parameters(f)
#' 
#' m <- language_model(f, "sbo", lambda = 0.2)
#' param(m, "V")
#' param(m, "lambda")
#' param(m, "N") <- 2
#' param(m, "lambda") <- 0.4
#' 
#' if (FALSE) {
#'         param(m, "V") <- 5 # Error: dictionary size cannot be set.  
#' }
#' 
#' if (FALSE) {
#'         param(f, "N") <- 4 # Error: parameters of 'kgram_freqs' cannot be set  
#' }
#' 
#' m1 <- m
#' param(m1, "lambda") <- 0.5
#' param(m, "lambda") # 0.5 ; param() modifies 'm' by reference!
#' 
#' m2 <- language_model(m) # This creates a true copy
#' param(m2, "lambda") <- 0.6
#' param(m, "lambda") # 0.5
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