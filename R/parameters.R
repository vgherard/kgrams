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
        assert_string(which)
        UseMethod("param", object)
}

#' @export
param.language_model <- function(object, which) {
        validate_parameter_language_model(object, which)
        res <- attr(object, "cpp_obj")[[which]]
        return(res)
}

#' @rdname parameters
#' @export
param.kgram_freqs <- function(object, which) {
        validate_parameter_kgram_freqs(which)
        res <- attr(object, "cpp_obj")[[which]]
        return(res)
}

#' @rdname parameters
#' @export
`param<-` <- function(object, which, value) {
        assert_string(which)
        UseMethod("param<-", object)
}

#' @export
`param<-.kgram_freqs` <- function(object, which, value)
        rlang::abort(
                "Parameters of \"kgram_freqs\" objects cannot be set.",
                class = "kgrams_read_only_par_error")

#' @export
`param<-.language_model` <- function(object, which, value) {
        validate_parameter_language_model(object, which, value)
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
        smoother <- attr(object, "smoother")
        names <- sapply(list_parameters(smoother), function(x) x$name)
        names <- c("N", "V", names)
        res <- lapply(names, function(name) param(object, name))
        names(res) <- names
        return(res)
}

#---------------------------------------------------------- Parameter validation

validate_parameter_language_model <- function(object, which, value) {
        smoother <- attr(object, "smoother")
        valid_params <- sapply(list_parameters(smoother), function(x) x$name)
        valid_params <- c("N", "V", valid_params)
        
        if (!(which %in% valid_params)) {
                h <- "Unknown parameter"
                x <- paste0("'", which, "' is not a recognized parameter")
                i <- paste0("See info(\"", smoother, "\") or ?param.")
                msg <- c(h,x = x, i = i)
                rlang::abort(msg, class = "kgrams_unknown_par_error")
        }
        
        if (missing(value))
                return(invisible(NULL))
        
        if (which == "V") {
                h <- "Read only parameter" 
                x <- "Dictionary size cannot be set."
                rlang::abort(c(h, x = x), class = "kgrams_read_only_par_error")
        }
        
        if (which == "N" && value > attr(object, "cpp_freqs")$N) {
                h <- "Invalid parameter" 
                x <- paste0("'N' cannot be larger than the order ",
                            "of the underlying k-gram frequency table (",
                            attr(object, "cpp_freqs")$N, ").")
                rlang::abort(c(h, x = x), class = "kgrams_invalid_par_error")
        }
        
        l <- list_parameters(smoother)
        args <- lapply(l, function(x) x$default)
        names(args) <- sapply(l, function(x) x$name)
        args <- c(list(smoother = smoother), args)
        args[[which]] <- value
        
        do.call(validate_smoother, args)
}

validate_parameter_kgram_freqs <- function(which) {
        if (!(which %in% c("N", "V"))) {
                h <- "Unknown parameter"
                x <- paste0("'", which, "' is not a recognized parameter.")
                i <- paste0("See ?param.")
                msg <- c(h,x = x, i = i)
                rlang::abort(msg, class = "kgrams_unknown_par_error")
        }
}