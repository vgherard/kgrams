#' Language Model Perplexities
#' 
#' Compute language model perplexities on a test corpus.
#' 
#' @author Valerio Gherardi
#' @md
#'
#'
#' @param text a character vector or connection. Test corpus from which 
#' language model perplexity is computed.
#' @param model an object of class \code{language_model}.
#' @param .preprocess a function taking a character vector as input and 
#' returning a character vector as output. Preprocessing transformation  
#' applied to input before computing perplexity.
#' @param .tknz_sent a function taking a character vector as input and 
#' returning a character vector as output. Optional sentence tokenization step
#' applied before computing perplexity.
#' @param batch_size a length one positive integer or \code{Inf}.
#' Size of text batches when reading text from a \code{connection}. 
#' If \code{Inf}, all input text is processed in a single batch.
#' @param ... further arguments passed to or from other methods.
#' @return a number. Perplexity of the language model on the test corpus.
#' 
#' @details
#' These generic functions are used to compute a \code{language_model} 
#' perplexity on a test corpus, which may be either a plain character vector 
#' of text, or a connection from which text can be read in batches. 
#' The second option is useful if one wants to avoid loading 
#' the full text in physical memory, and allows to process text from 
#' different sources such as files, compressed files or URLs.
#' 
#' "Perplexity" is defined here, following Ref. 
#' \insertCite{chen1999empirical}{kgrams}, as the exponential of the normalized 
#' language model cross-entropy with the test corpus. Cross-entropy is
#' normalized by the total number of words in the corpus, where we include
#' the End-Of-Sentence tokens, but not the Begin-Of-Sentence tokens, in the
#' word count.
#' 
#' The custom .preprocess and .tknz_sent arguments allow to apply
#' transformations to the text corpus before the perplexity computation takes
#' place. By default, the same functions used during model building are 
#' employed, c.f. \link[kgrams]{kgram_freqs} and \link[kgrams]{language_model}.
#' 
#' A note of caution is in order. Perplexity is not defined for all language
#' models available in \link[kgrams]{kgrams}. For instance, smoother 
#' \code{"sbo"} (i.e. Stupid Backoff \insertCite{brants-etal-2007-large}{kgrams}) 
#' does not produce normalized probabilities,
#' and this is signaled by a warning (shown once per session) if the user 
#' attempts to compute the perplexity for such a model. 
#' In these cases, when possible, perplexity computations are performed 
#' anyway case, as the results might still be useful (e.g. to tune the model's 
#' parameters), even if their probabilistic interpretation does no longer hold.  
#' @examples
#' # Train 4-, 6-, and 8-gram models on Shakespeare's "Much Ado About Nothing",
#' # compute their perplexities on the training and test corpora.
#' # We use Shakespeare's "A Midsummer Night's Dream" as test.
#' 
#' \donttest{
#' train <- much_ado
#' test <- midsummer
#' 
#' tknz <- function(text) tknz_sent(text, keep_first = TRUE)
#' f <- kgram_freqs(train, 8, .tknz_sent = tknz)
#' m <- language_model(f, "kn", D = 0.75)
#' 
#' # Compute perplexities for 4-, 6-, and 8-gram models 
#' FUN <- function(N) {
#'         param(m, "N") <- N
#'         c(train = perplexity(train, m), test = perplexity(test, m))
#'         }
#' sapply(c("N = 4" = 4, "N = 6" = 6, "N = 8" = 8), FUN)
#' }
#' 
#' @references 
#' \insertAllCited{}
#' 
#' @name perplexity

#' @rdname perplexity
#' @export
perplexity <- function(text,
                       model,
                       .preprocess = attr(model, ".preprocess"),
                       .tknz_sent = attr(model, ".tknz_sent"),
                       ...
                       )
{
        assert_function(.preprocess)
        assert_function(.tknz_sent)
        assert_language_model(model)
        check_model_perplexity(model)
        UseMethod("perplexity", text)
}
        
#' @rdname perplexity
#' @export
perplexity.character <- function(
        text,
        model,
        .preprocess = attr(model, ".preprocess"),
        .tknz_sent = attr(model, ".tknz_sent"),
        ...
        ) 
{
        assert_character_no_NA(text)
        text <- .preprocess(text)
        text <- .tknz_sent(text)
        lp <- attr(model, "cpp_obj")$log_probability_sentence(text)
        cross_entropy <- -sum(lp$log_prob) / sum(lp$n_words) 
        return(exp(cross_entropy))
}

#' @rdname perplexity
#' @export
perplexity.connection <- function(
        text,
        model,
        .preprocess = attr(model, ".preprocess"),
        .tknz_sent = attr(model, ".tknz_sent"),
        batch_size = Inf,
        ...
        ) 
{
        assert_positive_integer(batch_size, can_be_inf = TRUE)
        
        if (!isOpen(text))
                open(text, "r")
        if (is.infinite(batch_size)) 
                batch_size <- -1L
        
        sum_log_prob <- n_words <- 0
        while (length(batch <- readLines(text, batch_size))) {
                batch <- .tknz_sent( .preprocess(batch) )
                lp <- attr(model, "cpp_obj")$log_probability_sentence(batch)
                sum_log_prob <- sum_log_prob + sum(lp$log_prob)
                n_words <- sum(lp$n_words)
        }
        close(text)
        cross_entropy <- -sum_log_prob / n_words 
        return(exp(cross_entropy))
}


check_model_perplexity <- function(model) {
        check_sbo_perplexity(model)
        check_ml_perplexity(model)
}

check_sbo_perplexity <- function(model) {
        if (attr(model, "smoother") != "sbo") 
                return(invisible(NULL))
        h <- "Computing perplexity for Stupid Backoff model."
        x <- "'sbo' smoother does not produce normalized probabilities."
        i <- "Using Stupid Backoff scores for the computation."
        msgs <- c(h, x = x, i = i)
        rlang::warn(msgs, 
                    class = "sbo_perplexity_warning",
                    .frequency = "once", 
                    .frequency_id = "sbo_perplex"
                    )
}

check_ml_perplexity <- function(model) {
        if (attr(model, "smoother") != "ml")
                return(invisible(NULL))
        h <- "Computing perplexity for Maximum-Likelihood model."
        x <- "'ml' probabilities can be 'NA'."
        i <- "Result may be 'NA'."
        msgs <- c(h, x = x, i = i)
        rlang::warn(msgs, 
                    class = "ml_perplexity_warning",
                    .frequency = "once", 
                    .frequency_id = "ml_perplex"
        )
}
