#' Word-context conditional expression
#' 
#' Create word-context conditional expression with the infix notation.
#'
#' @name conditional
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