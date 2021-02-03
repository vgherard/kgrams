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

as_language_model <- function(object) 
        UseMethod("as_language_model", object)

as_language_model.language_model <- function(object) 
        return(object)

as_language_model.kgram_freqs <- function(object)
        return(language_model(object, "ml"))

as_language_model.default <- function(object) {
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
#' @param object an object which stores the information required to build the
#' k-gram model. At present, necessarily a \code{kgram_freqs} object, or a 
#' \code{language_model} object of which a copy is desired (see Details).
#' @param N an integer. Maximum order of k-grams to use in the language
#' model. This muss be less than or equal to the order of the underlying
#' \code{kgram_freqs} object.
#' @param smoother a character vector. Indicates the smoothing technique to
#' be applied to compute k-gram continuation probabilities. A list of 
#' available smoothers can be obtained with \code{smoothers()}, and 
#' further information on a particular smoother through 
#' \code{info()}.
#' @param ... possible additional parameters required by the smoother.
#' 
#' @return A \code{language_model} object.
#' @details
#' These generics are used to construct objects of class \code{language_model}.
#' The \code{language_model} method isonly needed to create copies of 
#' \code{language_model} objects (that is to say, new copies which are not 
#' altered by methods which modify the original object in place, 
#' see e.g. \link[kgrams]{parameters}). The discussion below focuses on 
#' language models and the \code{kgram_freqs} method.
#' 
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
#' a warning. \code{info(smoother)} lists all parameters needed by a 
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

#' @rdname language_model
#' @export
language_model <- function(object, ...)
        UseMethod("language_model", object)

#' @rdname language_model
#' @export
language_model.language_model <- function(object, ...) {
        cpp_freqs <- attr(object, "cpp_freqs")
        smoother <- class(object)[[2]]
        args <- parameters(object)
        N <- args[["N"]]
        cpp_obj <- switch(smoother, 
                sbo = new(SBOSmoother, cpp_freqs, N, args[["lambda"]]),
                add_k = new(AddkSmoother, cpp_freqs, N, args[["k"]]),
                laplace = new(AddkSmoother, cpp_freqs, N, 1.0),
                ml = new(MLSmoother, cpp_freqs, N),
                kn = new(KNSmoother, cpp_freqs, N, args[["D"]])
        )
        new_language_model(cpp_obj, 
                           cpp_freqs, 
                           attr(object, ".preprocess"), 
                           attr(object, ".tokenize_sentences"),
                           smoother
        )
}

#' @rdname language_model
#' @export
language_model.kgram_freqs <- 
        function(object, smoother = "ml", N = param(object, "N"), ...) 
{
        if (isFALSE(is.numeric(N) & 0 < N & N <= param(object, "N"))) {
                msgs <- "'N' must be a positive integer less than or equal" %+%
                        "to 'param(object, \"N\")'."
                rlang::abort(message = msgs, class = "domain_error")
        }
        validate_smoother(smoother, ...)
        args <- list(...)
        for (parameter in list_parameters(smoother)) 
                if (is.null(args[[parameter$name]]))
                        args[[parameter$name]] <- parameter$default
        cpp_freqs <- attr(object, "cpp_obj")
        cpp_obj <- switch(smoother, 
               sbo = new(SBOSmoother, cpp_freqs, N, args[["lambda"]]),
               add_k = new(AddkSmoother, cpp_freqs, N, args[["k"]]),
               laplace = new(AddkSmoother, cpp_freqs, N, 1.0),
               ml = new(MLSmoother, cpp_freqs, N),
               kn = new(KNSmoother, cpp_freqs, N, args[["D"]])
        )
        new_language_model(cpp_obj, 
                           cpp_freqs, 
                           attr(object, ".preprocess"), 
                           attr(object, ".tokenize_sentences"),
                           smoother
                           )
}
