#' Word-context conditional expression
#' 
#' Create word-context conditional expression with the `%|%` operator.
#' 
#' @author Valerio Gherardi
#' 
#' @param word a character vector. Word or words to include as the variable
#' part of the conditional expression.
#' @param context a character vector of length one. The fixed (or "given") part
#' of the conditional expression.
#' 
#' @return a \code{word_context} class object.
#' @details 
#' The intuitive meaning of the operator `%|%` is that of the mathematical 
#' symbol `|` (given). This operator is used to create conditional expressions
#' representing the occurrence of some word after a given context (for instance,
#' the expression \code{"you" %|% "i love"} would represent the occurrence of 
#' the word \code{"you"} after the string "i love"). The purpose of `%|%` is to
#' create objects which can be given as input to probability() (see 
#' \link[kgrams]{probability} for further examples). 
#' 
#' @examples 
#' f <- kgram_freqs(much_ado, 2, .tknz_sent = tknz_sent)
#' m <- language_model(f, "kn", D = 0.5)
#' probability("leonato" %|% "enter", m)
#' 
#' @name word_context
#'
#' @export
`%|%` <- function(word, context) {
        if (!is.character(word)) {
                msg <- "lhs of %|% must be a character vector."
                rlang::abort(message = msg, class = "infix_domain_error") 
        }
        if (!is.character(context) || length(context) != 1) {
                msg <- "rhs of %|% must be a length one character vector."
                rlang::abort(message = msg, class = "infix_domain_error") 
        }
        structure(list(word = word, context = context), 
                  class = "kgrams_word_context")
}

#' @export
print.kgrams_word_context <- function(x, n = 5, ...) {
        cat("Word-context conditional expression: ")
        cat(paste0(head(x$word, n = n), "|", x$context, collapse = ", "))
        if (length(x$word) > n) cat(", ...")
}
