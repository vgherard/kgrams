#' Language Model Probabilities
#' 
#' Compute sentence probabilities and word continuation conditional 
#' probabilities from a language model
#' 
#' @author Valerio Gherardi
#' @md
#'
#' @param text a character vector or connection. Test corpus from which 
#' language model perplexity is computed.
#' @param model either an object of class \code{language_model}, or a 
#' \code{kgram_freqs} object. The language model from which probabilities 
#' are computed.
#' @param .preprocess a function taking a character vector as input and 
#' returning a character vector as output. Preprocessing transformation  
#' applied to input before computing perplexity.
#' @param .tokenize_sentences a function taking a character vector as input and 
#' returning a character vector as output. Optional sentence tokenization step
#' applied before computing perplexity.
#' @param batch_size a length one positive integer or \code{NULL}.
#' Size of text batches when reading text from a \code{connection}. 
#' If \code{NULL}, all input text is processed in a single batch.
#' @return a number. Perplexity of the language model on the test corpus.
#' 
#' @details
#'
#' @name perplexity

#' @rdname perplexity
#' @export
perplexity <- function(text,
                       model,
                       .preprocess = attr(model, ".preprocess"),
                       .tokenize_senteces = attr(model, ".tokenize_sentences"),
                       ...
                       )
{
        # If 'model' is not a language model, try to coerce it to language model
        model <- as.language_model(model)
        UseMethod("perplexity", text)
}
        
#' @rdname perplexity
#' @export
perplexity.character <- function(
        text,
        model,
        .preprocess = attr(model, ".preprocess"),
        .tokenize_senteces = attr(model, ".tokenize_sentences"),
        ...
        ) 
{
        text <- .preprocess(text)
        text <- .tokenize_senteces(text)
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
        .tokenize_senteces = attr(model, ".tokenize_sentences"),
        batch_size = NULL,
        ...
) 
{
        
        if (is.null(batch_size)) 
                batch_size <- -1L
        
        sum_log_prob <- n_words <- 0 
        
        open(text, "r")
        while (length(batch <- readLines(text, batch_size))) {
                batch <- .tokenize_senteces( .preprocess(batch) )
                lp <- attr(model, "cpp_obj")$log_probability_sentence(text)
                sum_log_prob <- sum_log_prob + sum(lp$log_prob)
                n_words <- sum(lp$n_words)
        }
        close(text)
        cross_entropy <- -sum_log_prob / n_words 
        return(exp(cross_entropy))
}



