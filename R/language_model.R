new_language_model <- function(cpp_obj, smoother) {
        structure(list(), 
                  cpp_obj = cpp_obj, 
                  class = c("language_model", smoother)
                  )
}

#' k-gram Language Models
#'
#' Create a k-gram language model.
#'
#' @author Valerio Gherardi
#' @md
#'
#' @param object an object which stores the information required to build the
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
#' \code{language_models()} have methods for computing k-gram continuation 
#' probabilities (see \link[kgrams]{probability}), random text generation
#' (see \link[kgrams]{sample_sentences}) and other type of language 
#' modeling tasks such as (\strong{not yet implemented}) computing perplexities
#' and word prediction accuracies.
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
#' probability(model, word = "a", context = "b")
#' @name language_model

#' @export
language_model <- function(object, smoother = "ml", ...) {
        validate_smoother(smoother, ...)
        UseMethod("language_model", object)
}

#' @export
language_model.kgram_freqs <- function(object, smoother = "ml", ...) {
        args <- list(...)
        for (parameter in parameters(smoother)) 
                if (is.null(args[[parameter$name]]))
                        args[[parameter$name]] <- parameter$default
        freqs_obj <- attr(object, "cpp_obj")
        smoother_obj <- switch(smoother, 
               sbo = new(SBOSmoother, freqs_obj, args[["lambda"]]),
               add_k = new(AddkSmoother, freqs_obj, args[["k"]]),
               laplace = new(AddkSmoother, freqs_obj, 1.0),
               ml = new(MLSmoother, freqs_obj),
               kn = new(KNSmoother, freqs_obj, args[["D"]])
        )
        new_language_model(smoother_obj, smoother)
}