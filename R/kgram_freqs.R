#' k-gram frequency tables
#'
#' Extract k-gram frequency counts from a text or a connection.
#'
#' @author Valerio Gherardi
#' @md
#'
#' @param object a character vector or a connection. Source of text from which
#' k-gram frequencies are to be extracted.
#' @param N a length one integer. Maximum order of k-grams to be considered.
#' @param dict either a \code{sbo_dictionary} object, a character vector, 
#' or a formula (see details). The language model dictionary.
#' @param .preprocess a function to apply before k-gram
#' tokenization.
#' @param erase a length one character vector. Regular expression matching
#' parts  of text to be erased from input. The default removes anything not
#' alphanumeric, white space, apostrophes or punctuation characters
#' (i.e. ".?!:;").
#' @param lower_case a length one logical vector. If TRUE, puts everything to
#' lower case.
#' @param EOS a length one character vector listing all (single character)
#' end-of-sentence tokens.
#' @return A \code{sbo_kgram_freqs} object, containing the k-gram
#' frequency tables for k = 1, 2, ..., N.
#' @details These functions extract all k-gram frequency tables from a text
#' corpus up to a specified k-gram order N. These are
#' the building blocks to train any N-gram model. The functions 
#' \code{sbo_kgram_freqs()} and \code{sbo_kgram_freqs_fast()} are aliases for
#' \code{kgram_freqs()} and \code{kgram_freqs_fast()}, respectively.
#' 
#' The optimized version \code{kgram_freqs_fast(erase = x, lower_case = y)}
#' is equivalent to
#' \code{kgram_freqs(.preprocess = preprocess(erase = x, lower_case = y))},
#' but more efficient (both from the speed and memory point of view).
#'
#' Both \code{kgram_freqs()} and \code{kgram_freqs_fast()} employ a fixed
#' (user specified) dictionary: any out-of-vocabulary word gets effectively
#' replaced by an "unknown word" token. This is specified through the argument
#' \code{dict}, which accepts three types of arguments: a `sbo_dictionary` 
#' object, a character vector (containing the words of the dictionary) or a 
#' formula. In this last case, valid formulas can be either \code{max_size ~ V} 
#' or \code{target ~ f}, where \code{V} and \code{f} represent a dictionary size
#' and a corpus word coverage fraction (of \code{corpus}), respectively. This 
#' usage of the \code{dict} argument allows to build the model dictionary 
#' 'on the fly'.
#'
#' The return value is a "\code{sbo_kgram_freqs}" object, i.e. a list of N tibbles, 
#' storing frequency counts for each k-gram observed in the training corpus, for
#' k = 1, 2, ..., N. In these tables, words are represented by
#' integer numbers corresponding to their position in the
#' reference dictionary. The special codes \code{0},
#' \code{length(dictionary)+1} and \code{length(dictionary)+2}
#' correspond to the "Begin-Of-Sentence", "End-Of-Sentence"
#' and "Unknown word" tokens, respectively.
#' 
#' Furthermore, the returned objected has the following attributes: 
#'
#' - \code{N}: The highest order of N-grams.
#' - \code{dict}: The reference dictionary, sorted by word frequency.
#' - \code{.preprocess}: The function used for text preprocessing.
#' - \code{EOS}: A length one character vector listing all (single character)
#' end-of-sentence tokens employed in k-gram tokenization.
#'
#' The \code{.preprocess} argument of \code{kgram_freqs} allows the user to
#' apply a custom transformation to the training corpus, before kgram 
#' tokenization takes place.
#'
#' The algorithm for k-gram tokenization considers anything separated by
#' (any number of) white spaces (i.e. " ") as a single word. Sentences are split
#' according to end-of-sentence (single character) tokens, as specified
#' by the \code{EOS} argument. Additionally text belonging to different entries of
#' the preprocessed input vector which are understood to belong to different
#' sentences.
#' 
#' \emph{Nota Bene}: It is useful to keep in mind that the function 
#' passed through the  \code{.preprocess} argument also captures its enclosing 
#' environment, which is by default the environment in which the former 
#' was defined.
#' If, for instance, \code{.preprocess} was defined in the global environment, 
#' and the latter binds heavy objects, the resulting \code{sbo_kgram_freqs} will
#' contain bindings to the same objects. If \code{sbo_kgram_freqs} is stored out of
#' memory and recalled in another R session, these objects will also be reloaded
#' in memory.
#' For this reason, for non interactive use, it is advisable to avoid using 
#' preprocessing functions defined in the global environment 
#' (for instance, \code{base::identity} is preferred to \code{function(x) x}).
#' 
#' @name kgram_freqs
NULL

new_kgram_freqs <- function(f, N, dictionary, .preprocess, .tokenize_sentences)
{
        structure(list(),
                  N = N, 
                  dictionary = dictionary, 
                  .preprocess = .preprocess,
                  .tokenize_sentences = .tokenize_sentences,
                  cpp_obj = f,
                  class = "kgram_freqs")
}

#' @rdname kgram_freqs
#' @export
kgram_freqs <- function(object, 
                        N,
                        .preprocess = identity, 
                        .tokenize_sentences = identity,
                        batch_size = NULL,
                        dictionary = NULL,
                        fixed_dictionary = FALSE,
                        ...
) 
{
        dictionary <- dictionary(dictionary)
        f <- new(kgramFreqs, N, attr(dictionary, "cpp_obj"))
        process <- function(batch) 
        {
                batch <- .preprocess(batch)
                batch <- .tokenize_sentences(batch)
                f$process_sentences(batch, fixed_dictionary)
        }
        UseMethod("kgram_freqs", object)
}

#' @rdname kgram_freqs
#' @export
kgram_freqs.character <- function(object, 
                                  N,
                                  .preprocess = identity, 
                                  .tokenize_sentences = identity,
                                  batch_size = NULL,
                                  dictionary = character(),
                                  fixed_dictionary = FALSE,
                                  ...
)
{
        len <- length(object)
        if (is.null(batch_size)) 
                batch_size <- len
        
        start <- 1
        while (start <= len) {
                end <- min(start + batch_size - 1, len)
                process(object[start:end])
                start <- end + 1
        }
        
        new_kgram_freqs(f, N, dictionary, .preprocess, .tokenize_sentences)
}

#' @rdname kgram_freqs
#' @export
kgram_freqs.connection <- function(object,
                                   N,
                                   .preprocess = identity,
                                   .tokenize_sentences = identity,
                                   batch_size = NULL,
                                   dictionary = character(),
                                   fixed_dictionary = FALSE,
                                   ...
)
{
        
        if (is.null(batch_size)) 
                batch_size <- -1L
        
        open(object, "r")
        while (length(batch <- readLines(object, batch_size)))
                process(batch)
        close(object)
        
        new_kgram_freqs(f, N, dictionary, .preprocess, .tokenize_sentences)
}