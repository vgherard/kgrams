#' @export
probability <- function(object, model)
        UseMethod("probability", object)

#' @export
probability.kgrams_word_context <- function(object, model) {
        if (!inherits(model, "language_model"))
                if (inherits(model, "kgram_freqs")) {
                        model <- language_model(model, "ml")
                } else {
                        msgs <- "'model' should be either of class" %+%
                                "'language_model' or 'kgram_freqs'."
                        rlang::abort(message = msgs, class = "domain_error")
                }
        return(attr(model, "cpp_obj")$probability(object$word, object$context))        
}
        

#' @export
probability.character <- function(object, model) {
        ### ... compute probability of a sentence        
}
        
        