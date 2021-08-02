#' Random Text Generation
#' 
#' Sample sentences from a language model's probability distribution.
#' 
#' @author Valerio Gherardi
#' @md
#'
#' @param model an object of class \code{language_model}.
#' @param n an integer. Number of sentences to sample.
#' @param max_length an integer. Maximum length of sampled sentences. 
#' @param t a positive number. Sampling temperature (optional); see Details.
#' @return a character vector of length \code{n}. Random sentences generated 
#' from the language model's distribution.
#' @details
#' This function samples sentences according the prescribed language model's
#' probability distribution, with an optional temperature parameter.
#' The temperature transform of a probability distribution is defined by 
#' \code{p(t) = exp(log(p) / t) / Z(t)} where \code{Z(t)} is the partition
#' function, fixed by the normalization condition \code{sum(p(t)) = 1}.
#' 
#' Sampling is performed word by word, using the already sampled string
#' as context, starting from the Begin-Of-Sentence context (i.e. \code{N - 1} 
#' BOS tokens). Sampling stops either when an End-Of-Sentence token is 
#' encountered, or when the string exceeds \code{max_length}, in which case
#' a truncated output is returned.
#' 
#' A word of caution on some special smoothers: 'sbo' smoother (Stupid Backoff),
#' does not produce normalized continuation probabilities, but rather 
#' continuation \emph{scores}. Sampling is here performed by assuming that 
#' Stupid Backoff scores are \emph{proportional} to actual probabilities.
#' 'ml' smoother (Maximum Likelihood) does not assign probabilities when the
#' k-gram count of the context is zero. When this happens, the next word is 
#' chosen uniformly at random from the model's dictionary.
#' 
#' @examples 
#' # Sample sentences from 8-gram Kneser-Ney model trained on Shakespeare's
#' # "Much Ado About Nothing"
#' 
#' \donttest{
#' 
#' ### Prepare the model and set seed
#' freqs <- kgram_freqs(much_ado, 8, .tknz_sent = tknz_sent)
#' model <- language_model(freqs, "kn", D = 0.75)
#' set.seed(840)
#' 
#  ### Sampling at normal temperature
#' sample_sentences(model, n = 3, max_length = 10)
#' 
#' ### Sampling at high temperature
#' sample_sentences(model, n = 3, max_length = 10, t = 100)
#' 
#' ### Sampling at low temperature
#' sample_sentences(model, n = 3, max_length = 10, t = 0.01)
#' 
#' }
#' @export
sample_sentences <- function(model, n, max_length, t = 1.0) 
{
        assert_language_model(model)
        assert_positive_integer(n)
        assert_positive_number(t)
        attr(model, "cpp_obj")$sample(n, max_length, t)
}
