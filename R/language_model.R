new_language_model <- function(cpp_obj, 
                               cpp_freqs, 
                               .preprocess, 
                               .tokenize_sentences, 
                               smoother
                               ) 
{
        structure(list(), 
                  cpp_obj = cpp_obj, 
                  cpp_freqs = cpp_freqs,
                  .preprocess = .preprocess,
                  .tokenize_sentences = .tokenize_sentences,
                  class = c("language_model", smoother)
                  )
}

as.language_model <- function(object) 
        UseMethod("as.language_model", object)

as.language_model.language_model <- function(object) 
        return(object)

as.language_model.kgram_freqs <- function(object)
        return(language_model(object, "ml"))

as.language_model.default <- function(object) {
        msg <- "Input cannot be coerced to 'language_model'."
        rlang::abort(message = msg, class = "domain_error")
}

#' k-gram Language Models
#'
#' Create a k-gram language model.
#'
#' @author Valerio Gherardi
#' @md
#'
#' @param freqs an object which stores the information required to build the
#' k-gram model. At present, necessarily a \code{kgram_freqs} object.
#' @param smoother a character vector. Indicates the smoothing technique to
#' be applied to compute k-gram continuation probabilities. A list of 
#' available smoothers can be obtained with \link[kgrams]{smoothers}, and 
#' further information on a particular smoother through 
#' \link[kgrams]{smoother_info}
#' @param ... possible additional parameters required by the smoother.
#' 
#' @return A \code{language_model} object.
#' @details
#' \link[kgrams]{kgrams} supports several k-gram language models, including
#' Interpolated Kneser-Ney, Stupid Backoff and others 
#' (see \link[kgrams]{smoothers}). The objects created by 
#' \code{language_models()} have methods for computing word continuation and
#' sentence probabilities (see \link[kgrams]{probability}), 
#' random text generation (see \link[kgrams]{sample_sentences}) 
#' and other type of language modeling tasks such as 
#' (\strong{not yet implemented}) computing perplexities and word 
#' prediction accuracies.
#' 
#' Smoothers have often tuning parameters, which need to be specified by
#' (exact) name through the \code{...} arguments; otherwise, 
#' \code{language_model()} will use default values and, once per session, throw 
#' a warning. \code{smoother_info(smoother)} lists all parameters needed by a 
#' specific smoother, together with their allowed parameter space.
#' 
#' The run-time of \code{language_model()} may vary substantially for different
#' smoothing methods, depending on whether or not a method requires the 
#' computation of additional quantities (that is to say, beyond k-gram counts)
#' for its operativity (this is, for instance, the case for the Kneser-Ney 
#' smoother).  
#' @examples 
#' # Create an interpolated Kneser-Ney 2-gram language model
#'  
#' freqs <- kgram_freqs("a a b a a b a b a b a b", 2)
#' model <- language_model(freqs, "kn", D = 0.5)
#' probability("a" %|% "b", model)
#' @name language_model

#' @export
language_model <- function(freqs, smoother = "ml", ...) {
        validate_smoother(smoother, ...)
        UseMethod("language_model", freqs)
}

#' @export
language_model.kgram_freqs <- function(freqs, smoother = "ml", ...) {
        args <- list(...)
        for (parameter in parameters(smoother)) 
                if (is.null(args[[parameter$name]]))
                        args[[parameter$name]] <- parameter$default
        cpp_freqs <- attr(freqs, "cpp_obj")
        cpp_obj <- switch(smoother, 
               sbo = new(SBOSmoother, cpp_freqs, args[["lambda"]]),
               add_k = new(AddkSmoother, cpp_freqs, args[["k"]]),
               laplace = new(AddkSmoother, cpp_freqs, 1.0),
               ml = new(MLSmoother, cpp_freqs),
               kn = new(KNSmoother, cpp_freqs, args[["D"]])
        )
        new_language_model(cpp_obj, 
                           cpp_freqs, 
                           attr(freqs, ".preprocess"), 
                           attr(freqs, ".tokenize_sentences"),
                           smoother
                           )
}