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
#' unknown word token. It is by default \code{TRUE} if \code{dictionary} is
#' specified, \code{FALSE} otherwise.
#' @param in_place \code{TRUE} or \code{FALSE}. Should the initial 
#' \code{kgram_freqs} object be modified in place?
#' @param verbose Print current progress to the console.
#' @param ... further arguments passed to or from other methods.
#' @param max_lines a length one positive integer or \code{Inf}.
#' Maximum number of lines to be read from the \code{connection}. 
#' If \code{Inf}, keeps reading until the End-Of-File.
#' @param batch_size a length one positive integer less than or equal to
#' \code{max_lines}.Size of text batches when reading text from 
#' \code{connection}.
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
#' # Build a k-gram frequency table from a file connection
#' 
#' \dontrun{
#' f <- kgram_freqs(file("myfile.txt"), 3)
#' }
#' 
#' 
#' # Build a k-gram frequency table from an URL connection
#' \dontrun{
#' ### Shakespeare's "Much Ado About Nothing" (entire play)
#' con <- url("http://shakespeare.mit.edu/much_ado/full.html")
#' 
#' # Apply some basic preprocessing
#' .preprocess <- function(x) {
#'         # Remove character names and locations (boldfaced in original html)
#'         x <- gsub("<b>[A-z]+</b>", "", x)
#'         # Remove html tags
#'         x <- gsub("<[^>]+>||<[^>]+$||^[^>]+>$", "", x)
#'         # Remove character names (all-caps in original text)
#'         x <- gsub("[A-Z]{2,}", "", x)
#'         # Apply standard preprocessing including lower-case
#'         x <- kgrams::preprocess(x)
#'         return(x)
#' }
#'
#' .tokenize_sentences <- function(x) {
#'         # Tokenize sentences keeping Shakespeare's punctuation
#'         x <- kgrams::tokenize_sentences(x, keep_first = TRUE)
#'         # Remove empty sentences
#'         x <- x[x != ""]
#'         return(x)
#' }
#' 
#' f <- kgram_freqs(con, 3, .preprocess, .tokenize_sentences, batch_size = 1000)
#' 
#' query(f, c("leonato", "thy", "smartphones")) # c(145, 52, 0)
#' }
#' @name kgram_freqs
NULL

# Generic constructor
#' @rdname kgram_freqs
#' @export
kgram_freqs <- function(
        text,
        N,
        .preprocess = identity,
        .tokenize_sentences = identity,
        dictionary = NULL,
        open_dictionary = is.null(dictionary),
        verbose = TRUE,
        ...
) 
        UseMethod("kgram_freqs", text)

# Constructor from character vector
#' @rdname kgram_freqs
#' @export
kgram_freqs.character <- function(
        text, 
        N,
        .preprocess = identity, 
        .tokenize_sentences = identity,
        dictionary = NULL,
        open_dictionary = is.null(dictionary),
        verbose = TRUE,
        ...
)
{
        freqs <- kgram_freqs_init(
                N, dictionary, open_dictionary, .preprocess, .tokenize_sentences
        ) 
        process_sentences.character(
                text, 
                freqs, 
                open_dictionary = open_dictionary, 
                in_place = TRUE,
                verbose = verbose,
                ...
        ) # return
}

# Constructor from connection
#' @rdname kgram_freqs
#' @export
kgram_freqs.connection <- function(
        text,
        N,
        .preprocess = identity,
        .tokenize_sentences = identity,
        dictionary = NULL,
        open_dictionary = is.null(dictionary),
        verbose = TRUE,
        max_lines = max_lines,
        batch_size = NULL,
        ...
)
{
        freqs <- kgram_freqs_init(
                N, dictionary, open_dictionary, .preprocess, .tokenize_sentences
        ) 
        process_sentences.connection(
                text,
                freqs,
                open_dictionary = open_dictionary,
                in_place = TRUE,
                max_lines = max_lines,
                batch_size = batch_size,
                verbose = TRUE,
                ...
        )
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
        verbose = TRUE,
        ...
) 
        UseMethod("process_sentences", text)


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
        verbose = TRUE,
        ...
)
{
        freqs <- process_sentences_init(freqs, in_place)
        process <- kgram_process_task(freqs, open_dictionary, verbose)
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
        .tokenize_sentences = attr(freqs, ".tokenize_sentences"),
        open_dictionary = TRUE,
        in_place = TRUE,
        verbose = TRUE,
        max_lines = Inf,
        batch_size = max_lines,
        ...
)
{
        freqs <- process_sentences_init(freqs, in_place)
        # Progress is printed directly from R
        process <- kgram_process_task(freqs, open_dictionary, verbose = F)
        
        open(text, "r")
        if (batch_size == Inf) 
                batch_size <- -1L
        left <- max_lines
        if (verbose) progress <- new_progress()
        while (left > 0) {
                batch <- readLines(text, min(left, batch_size))
                left <- left - batch_size
                if (length(batch) == 0) 
                        break # Reached EOF
                process(batch)
                if (verbose) progress$show()
        }
        if (verbose) progress$terminate()
        close(text)
        
        return(invisible(freqs))
}

kgram_freqs_init <- function(
        N, dictionary, open_dictionary, .preprocess, .tokenize_sentences
) 
{
        if (is.null(dictionary))
                dictionary <- dictionary()
        dictionary <- as.dictionary(dictionary)
        cpp_obj <- new(kgramFreqs, N, attr(dictionary, "cpp_obj"))
        new_kgram_freqs(cpp_obj, .preprocess, .tokenize_sentences)
}

process_sentences_init <- function(freqs, in_place) {
        if (!in_place) {
                old <- attr(freqs, "cpp_obj")
                attr(freqs, "cpp_obj") <- new(kgramFreqs, old)
        }
        return(freqs)
}

kgram_process_task <- function(freqs, open_dictionary, verbose) {
        cpp_obj <- attr(freqs, "cpp_obj")
        .preprocess <- attr(freqs, ".preprocess")
        .tokenize_sentences <- attr(freqs, ".tokenize_sentences")
        function(batch) {
                batch <- .preprocess(batch)
                batch <- .tokenize_sentences(batch)
                cpp_obj$process_sentences(batch, !open_dictionary, verbose)
        } # return
}
