new_kgram_freqs <- function(cpp_obj, .preprocess, .tokenize_sentences) {
        dictionary <- new_kgrams_dictionary(cpp_obj$dictionary())
        structure(list(), 
                  dictionary = dictionary,
                  .preprocess = utils::removeSource(.preprocess),
                  .tokenize_sentences = utils::removeSource(.tokenize_sentences),
                  cpp_obj = cpp_obj, 
                  class = "kgram_freqs"
                  )
}

#' k-gram frequency tables
#'
#' Extract k-gram frequency counts from a text or a connection.
#'
#' @author Valerio Gherardi
#' @md
#'
#' @param text a character vector or a connection. Source of text from which
#' k-gram frequencies are to be extracted.
#' @param N a length one integer. Maximum order of k-grams to be considered.
#' @param .preprocess a function taking a character vector as input and returning
#' a character vector as output. Optional preprocessing transformation to be 
#' applied before k-gram tokenization.
#' @param .tokenize_sentences a function taking a character vector as input and 
#' returning a character vector as output. Optional sentence tokenization step
#' to be applied after preprocessing and before k-gram tokenization. 
#' The default (\code{identity}) amounts to consider each entries of input
#' (after preprocessing) as one sentence.
#' @param dictionary anything coercible to class 
#' \link[kgrams]{kgrams_dictionary}. Optional pre-specified word dictionary. 
#' @param open_dictionary \code{TRUE} or \code{FALSE}. If \code{TRUE}, any new 
#' word encountered during processing not appearing in the original dictionary 
#' is included into the dictionary. Otherwise, new words are replaced by an
#' unknown word token.
#' @param batch_size a length one positive integer or \code{NULL}.
#' Size of text batches when reading text from a \code{file} or a generic 
#' \code{connection}. If \code{NULL}, all input text is processed in a single 
#' batch.
#' 
#' @return A \code{kgram_freqs} class object.
#' @details The generic function \code{kgram_freqs()} allows to obtain k-gram 
#' frequency counts from a text source, which may be either a character vector 
#' or a connection. The second option is useful if one wants to avoid loading 
#' the full text corpus in physical memory, allowing to process text from 
#' different sources such as files, compressed files or URLs.
#'
#' The \code{dictionary} argument allows to provide an initial set of known 
#' words. Subsequently, one can either work with such a closed dictionary 
#' (\code{open_dictionary == FALSE}), or extended the dictionary with all 
#' new words encountered during k-gram processing 
#' (\code{open_dictionary == TRUE}) is \code{FALSE}).   
#'
#' The \code{.preprocess} and \code{.tokenize_sentences} functions are applied
#' \emph{before} k-gram counting takes place, and are in principle 
#' arbitrary transformations of the original text.
#' \emph{After} preprocessing and sentence tokenization, each line of the 
#' transformed input is presented to the tokenization algorithm as separate 
#' sentence (these sentences are implicitly padded 
#' with \code{N - 1} Begin-Of-Sentence (BOS) and one End-Of-Sentence (EOS) 
#' tokens, respectively. This is illustrated in the examples).
#' 
#' The returned value is \code{kgram_freqs} class object (a thin wrapper around
#' the internal C++ class where all k-gram computations take place). 
#' \code{kgram_freqs} objects have methods for querying bare k-gram frequencies
#' (\link[kgrams]{query}), obtaining smoothed continuation probability estimates 
#' (\link[kgrams]{probability}) using various methods, sampling sentences 
#' from various language models probability distributions and 
#' \strong{(not yet implemented)} computing perplexities.
#' 
#' @name kgram_freqs
NULL

#' @rdname kgram_freqs
#' @export
kgram_freqs <- function(object,
                        N,
                        .preprocess = identity,
                        .tokenize_sentences = identity,
                        dictionary = NULL,
                        open_dictionary = TRUE,
                        ...
                        ) 
{
        dictionary <- as.kgrams_dictionary(dictionary)
        cpp_obj <- new(kgramFreqs, N, attr(dictionary, "cpp_obj"))
        process <- function(batch) 
        {
                batch <- .preprocess(batch)
                batch <- .tokenize_sentences(batch)
                cpp_obj$process_sentences(batch, !open_dictionary)
        }
        UseMethod("kgram_freqs")
}


#' @rdname kgram_freqs
#' @export
kgram_freqs.character <- function(object, 
                                  N,
                                  .preprocess = identity, 
                                  .tokenize_sentences = identity,
                                  dictionary = NULL,
                                  open_dictionary = TRUE,
                                  ...
)
{
        process(object)
        new_kgram_freqs(cpp_obj, .preprocess, .tokenize_sentences)
}

#' @rdname kgram_freqs
#' @export
kgram_freqs.connection <- function(object,
                                   N,
                                   .preprocess = identity,
                                   .tokenize_sentences = identity,
                                   dictionary = NULL,
                                   open_dictionary = TRUE,
                                   batch_size = NULL,
                                   ...
)
{
        
        if (is.null(batch_size)) 
                batch_size <- -1L
        
        open(object, "r")
        while (length(batch <- readLines(object, batch_size)))
                process(batch)
        close(object)
        
        new_kgram_freqs(cpp_obj, .preprocess, .tokenize_sentences)
}