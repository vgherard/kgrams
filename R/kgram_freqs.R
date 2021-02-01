# Low-level constructor 
new_kgram_freqs <- function(cpp_obj, .preprocess, .tokenize_sentences) {
        dictionary <- new_dictionary(cpp_obj$dictionary())
        stopifnot(is.function(.preprocess), is.function(.tokenize_sentences))
        structure(list(), 
                  dictionary = dictionary,
                  .preprocess = utils::removeSource(.preprocess),
                  .tokenize_sentences = utils::removeSource(.tokenize_sentences),
                  cpp_obj = cpp_obj, 
                  class = "kgram_freqs"
                  )
}

#' k-gram Frequency Tables
#'
#' Extract k-gram frequency counts from a text or a connection.
#'
#' @author Valerio Gherardi
#' @md
#'
#' @param text a character vector or a connection. Source of text from which
#' k-gram frequencies are to be extracted.
#' @param freqs a \code{kgram_freqs} object, to which new k-gram counts from
#' \code{text} are to be added.
#' @param N a length one integer. Maximum order of k-grams to be considered.
#' @param .preprocess a function taking a character vector as input and returning
#' a character vector as output. Optional preprocessing transformation  
#' applied to text before k-gram tokenization. See  ‘Details’.
#' @param .tokenize_sentences a function taking a character vector as input and 
#' returning a character vector as output. Optional sentence tokenization step
#' applied to text after preprocessing and before k-gram tokenization. See 
#' ‘Details’. 
#' @param dictionary anything coercible to class 
#' \link[kgrams]{dictionary}. Optional pre-specified word dictionary. 
#' @param open_dictionary \code{TRUE} or \code{FALSE}. If \code{TRUE}, any new 
#' word encountered during processing not appearing in the original dictionary 
#' is included into the dictionary. Otherwise, new words are replaced by an
#' unknown word token.
#' @param in_place \code{TRUE} or \code{FALSE}. Should the initial 
#' \code{kgram_freqs} object be modified in place?
#' @param batch_size a length one positive integer or \code{NULL}.
#' Size of text batches when reading text from \code{connection}. 
#' If \code{NULL}, all input text is processed in a single batch.
#' @param ... further arguments passed to or from other methods.
#' 
#' @return A \code{kgram_freqs} class object: k-gram frequency table storing
#' k-gram counts from text. For \code{process_sentences()}, the updated 
#' \code{kgram_freqs} object is returned invisibly if \code{in_place} is 
#' \code{TRUE}, visibly otherwise. 
#' @details These generic functions extract k-gram 
#' frequency counts from a text source, which may be either a character vector 
#' or a connection. The second option is useful if one wants to avoid loading 
#' the full text corpus in physical memory, allowing to process text from 
#' different sources such as files, compressed files or URLs.
#'
#' The returned object is of class \code{kgram_freqs} (a thin wrapper 
#' around the internal C++ class where all k-gram computations take place). 
#' \code{kgram_freqs} objects have methods for querying bare k-gram frequencies
#' (\link[kgrams]{query}) and maximum likelihood estimates of sentence
#' probabilities or word continuation probabilities 
#' (see \link[kgrams]{probability})) . More importantly 
#' \code{kgram_freqs} objects are used to create \link[kgrams]{language_model} 
#' objects, which support various probability smoothing techniques.
#' 
#' The function \code{kgram_freqs()} is used to \emph{construct} a new
#' \code{kgram_freqs} object, initializing it with the k-gram counts from 
#' the \code{text} input, whereas \code{process_sentences()} is used to 
#' add k-gram counts from a new \code{text} to an \emph{existing} 
#' \code{kgram_freqs} object, \code{freqs}. In this second case, the initial 
#' object \code{freqs} can either be modified in place
#' (for \code{in_place == TRUE}, the default) or by making a copy 
#' (\code{in_place == FALSE}). The final object is returned invisibly when 
#' modifying in place, visibly in the second case. 
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
#' tokens, respectively. This is illustrated in the examples). For basic
#' usage, this package offers the utilities \link[kgrams]{preprocess} and 
#' \link[kgrams]{tokenize_sentences}.
#' 
#' @seealso \link[kgrams]{dictionary} \link[kgrams]{language_model} 
#' \link[kgrams]{preprocess} \link[kgrams]{tokenize_sentences}
#' 
#' @name kgram_freqs
NULL

# Generic constructor
#' @rdname kgram_freqs
#' @export
kgram_freqs <- function(text,
                        N,
                        .preprocess = identity,
                        .tokenize_sentences = identity,
                        dictionary = NULL,
                        open_dictionary = TRUE,
                        ...
) 
{
        if (missing(dictionary) || is.null(dictionary))
                dictionary <- dictionary()
        dictionary <- as.dictionary(dictionary)
        
        cpp_obj <- new(kgramFreqs, N, attr(dictionary, "cpp_obj"))
        
        process <- kgram_process_task(
                cpp_obj, .preprocess, .tokenize_sentences, open_dictionary
        )
        
        UseMethod("kgram_freqs", text)
}

# Constructor from character vector
#' @rdname kgram_freqs
#' @examples
#' # Build a k-gram frequency table from a character vector
#' 
#' f <- kgram_freqs("a b b a a", 3)
#' query(f, c("a", "b")) # c(3, 2)
#' query(f, c("a b", "a" %+% EOS(), BOS() %+% "a b")) # c(1, 1, 1)
#' query(f, "a b b a") # NA (counts for k-grams of order k > 3 are not known)
#' 
#' 
#' 
#' @export
kgram_freqs.character <- function(text, 
                                  N,
                                  .preprocess = identity, 
                                  .tokenize_sentences = identity,
                                  dictionary = NULL,
                                  open_dictionary = TRUE,
                                  ...
)
{
        process(text)
        new_kgram_freqs(cpp_obj, .preprocess, .tokenize_sentences)
}

# Constructor from connection
#' @rdname kgram_freqs
#' @examples
#' # Build a k-gram frequency table from a file connection
#' 
#' \dontrun{
#' f <- kgram_freqs(file("myfile.txt"), 3)}
#' 
#' 
#' 
#' # Build a k-gram frequency table from an URL connection
#' 
#' \dontrun{
#' ### Shakespeare's "Much Ado About Nothing" (entire play)
#' con <- url("http://shakespeare.mit.edu/much_ado/full.html")
#' 
#' ### Strip-off html tags and put everything to lowercase 
#' .preprocess <- function(x) {
#'         x <- gsub("<[^>]+>||<[^>]+$||^[^>]+>$", "", x)
#'         x <- x[x != ""]
#'         return(tolower(x))
#' }
#' 
#' ### Keep Shakespeare's punctuation 
#' .tokenize_sentences <- function(x) {
#'         kgrams::tokenize_sentences(x, keep_first = TRUE)
#' }
#' 
#' f <- kgram_freqs(con, 3, .preprocess, .tokenize_sentences, batch_size = 1000)
#' 
#' query(f, c("leonato", "thy", "smartphones")) # c(145, 52, 0)}
#' @export
kgram_freqs.connection <- function(text,
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
        
        open(text, "r")
        while (length(batch <- readLines(text, batch_size)))
                process(batch)
        close(text)
        
        new_kgram_freqs(cpp_obj, .preprocess, .tokenize_sentences)
}

# Process sentences generic
#' @rdname kgram_freqs
#' @export
process_sentences <- function(
        text,
        freqs,
        .preprocess = attr(freqs, ".preprocess"),
        .tokenize_sentences = attr(freqs, ".tokenize_sentences"),
        open_dictionary = TRUE,
        in_place = TRUE,
        ...
) 
{
        UseMethod("process_sentences", text)
}

# Process sentences from character vector
#' @rdname kgram_freqs
#' @export
process_sentences.character <- function(
        text,
        freqs,
        .preprocess = attr(freqs, ".preprocess"),
        .tokenize_sentences = attr(freqs, ".tokenize_sentences"),
        open_dictionary = TRUE,
        in_place = TRUE,
        ...
)
{
        if (!in_place)
                attr(freqs, "cpp_obj") <- new(kgramFreqs, attr(freqs, "cpp_obj"))
        cpp_obj <- attr(freqs, "cpp_obj")
        process <- kgram_process_task(
                cpp_obj, .preprocess, .tokenize_sentences, open_dictionary
        )
        
        process(text)
        return(invisible(freqs))
}

# Process sentences from connection
#' @rdname kgram_freqs
#' @export
process_sentences.connection <- function(
        text,
        freqs,
        .preprocess = attr(freqs, ".preprocess"),
        tokenize_sentences = attr(freqs, ".tokenize_sentences"),
        open_dictionary = TRUE,
        in_place = TRUE,
        batch_size = NULL,
        ...
)
{
        if (!in_place)
                attr(freqs, "cpp_obj") <- new(kgramFreqs, attr(freqs, "cpp_obj"))
        cpp_obj <- attr(freqs, "cpp_obj") 
        
        process <- kgram_process_task(
                cpp_obj, .preprocess, .tokenize_sentences, open_dictionary
        )
        
        if (is.null(batch_size)) 
                batch_size <- -1L
        
        open(text, "r")
        while (length(batch <- readLines(text, batch_size)))
                process(batch)
        close(text)
        
        return(invisible(freqs))
}


kgram_process_task <- function(
        cpp_obj, .preprocess, .tokenize_sentences, open_dictionary
)
        function(batch) 
        {
                batch <- .preprocess(batch)
                batch <- .tokenize_sentences(batch)
                cpp_obj$process_sentences(batch, !open_dictionary)
        }