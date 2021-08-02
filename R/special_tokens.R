#' Special Tokens
#'
#' Return Begin-Of-Sentence, End-Of-Sentence and Unknown-Word special tokens.
#'
#' @author Valerio Gherardi
#' @md
#'
#' @return a string representing the appropriate special token.
#' @details 
#' These functions return the internal representation of BOS, EOS and UNK tokens
#' respectively. Their actual returned values are irrelevant and their only 
#' purpose is to simplify queries of k-gram counts and probabilities involving 
#' the special tokens, as shown in the examples. 
#' @examples
#' f <- kgram_freqs("a b b a b", 2)
#' query(f, c(BOS(), EOS(), UNK()))
#' 
#' m <- language_model(f, "add_k", k = 1)
#' probability(c("a", "b") %|% BOS(), m)
#' probability("a b b a" %+% EOS(), m)
#' 
#' # The actual values of BOS(), EOS() and UNK() are irrelevant
#' c(BOS(), EOS(), UNK())
#' 
#' 
#' @name special_tokens
NULL