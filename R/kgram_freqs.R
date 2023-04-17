#' k-gram Frequency Tables
#'
#' @description 
#'
#' Extract k-gram frequency counts from a text or a connection. 
#' 
#' ### Principal methods supported by objects of class \code{kgram_freqs}
#' 
#' - \code{query()}: query k-gram counts from the table. 
#' See \link[kgrams]{query}
#' 
#' - \code{probability()}: compute word continuation and sentence probabilities
#' using Maximum Likelihood estimates. See \link[kgrams]{probability}.
#' 
#' - \code{language_model()}: build a k-gram language model using various 
#' probability smoothing techniques. See \link[kgrams]{language_model}.
#'
#' @author Valerio Gherardi
#' @md
#' 
#' 
#' @param object any type allowed by the available methods. The type defines the 
#' behaviour of \code{kgram_freqs()} as a default constructor, a copy 
#' constructor or a constructor of a non-trivial object. See ‘Details’.
#' @param text a character vector or a connection. Source of text from which
#' k-gram frequencies are to be extracted.
#' @param freqs a \code{kgram_freqs} object, to which new k-gram counts from
#' \code{text} are to be added.
#' @param N a length one integer. Maximum order of k-grams to be considered.
#' @param .preprocess a function taking a character vector as input and returning
#' a character vector as output. Optional preprocessing transformation  
#' applied to text before k-gram tokenization. See  ‘Details’.
#' @param .tknz_sent a function taking a character vector as input and 
#' returning a character vector as output. Optional sentence tokenization step
#' applied to text after preprocessing and before k-gram tokenization. See 
#' ‘Details’. 
#' @param dict anything coercible to class 
#' \link[kgrams]{dictionary}. Optional pre-specified word dictionary. 
#' @param open_dict \code{TRUE} or \code{FALSE}. If \code{TRUE}, any new 
#' word encountered during processing not appearing in the original dictionary 
#' is included into the dictionary. Otherwise, new words are replaced by an
#' unknown word token. It is by default \code{TRUE} if \code{dict} is
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
#' @details The function \code{kgram_freqs()} is a generic constructor for
#' objects of class \code{kgram_freqs}, i.e. k-gram frequency tables. The 
#' constructor from \code{integer} returns an empty 'kgram_freqs' of fixed 
#' order, with an optional
#' predefined dictionary (which can be empty) and \code{.preprocess} and 
#' \code{.tknz_sent} functions to be used as defaults in other \code{kgram_freqs} 
#' methods. The constructor from \code{kgram_freqs} returns a copy of an 
#' existing object, and it is provided because, in general, \code{kgram_freqs}
#' objects have reference semantics, as discussed below. 
#' 
#' The following discussion focuses on \code{process_sentences()} generic, as 
#' well as on the \code{character} and \code{connection} methods of the 
#' constructor \code{kgram_freqs()}. These functions extract k-gram 
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
#' (\code{in_place == FALSE}), see the examples below. 
#' The final object is returned invisibly when modifying in place, 
#' visibly in the second case. It is worth to mention that modifying in place
#' a \code{kgram_freqs} object \code{freqs} will also affect 
#' \code{language_model} objects created from \code{freqs} with 
#' \code{language_model()}, which will also be updated with the new information.
#' If one wants to avoid this behaviour, one can make copies using either the
#' \code{kgram_freqs()} copy constructor, or the \code{in_place = FALSE} 
#' argument.
#'
#' The \code{dict} argument allows to provide an initial set of known 
#' words. Subsequently, one can either work with such a closed dictionary 
#' (\code{open_dict == FALSE}), or extended the dictionary with all 
#' new words encountered during k-gram processing 
#' (\code{open_dict == TRUE})  .
#'
#' The \code{.preprocess} and \code{.tknz_sent} functions are applied
#' \emph{before} k-gram counting takes place, and are in principle 
#' arbitrary transformations of the original text.
#' \emph{After} preprocessing and sentence tokenization, each line of the 
#' transformed input is presented to the k-gram counting algorithm as a separate 
#' sentence (these sentences are implicitly padded 
#' with \code{N - 1} Begin-Of-Sentence (BOS) and one End-Of-Sentence (EOS) 
#' tokens, respectively. This is illustrated in the examples). For basic
#' usage, this package offers the utilities \link[kgrams]{preprocess} and 
#' \link[kgrams]{tknz_sent}. Notice that, strictly speaking, there is 
#' some redundancy in these two arguments, as the processed input to the k-gram
#' counting algorithm is \code{.tknz_sent(.preprocess(text))}.
#' They appear explicitly as separate arguments for two main reasons:
#' 
#' - The presence of \code{.tknz_sent} is a reminder of the
#' fact that sentences have to be explicitly separeted in different entries
#' of the processed input, in order for \code{kgram_freqs()} to append the 
#' correct Begin-Of-Sentence and End-Of-Sentence paddings to each sentence.
#' 
#' - At prediction time (e.g. with \link[kgrams]{probability}), by default only
#' \code{.preprocess} is applied when computing conditional probabilities,
#' whereas both \code{.preprocess()} and \code{.tknz_sent()} are 
#' applied when computing sentence absolute probabilities.
#'  
#' 
#' @seealso \link[kgrams]{query}, \link[kgrams]{probability}
#' \link[kgrams]{language_model}, \link[kgrams]{dictionary}
#' 
#' @examples
#' # Build a k-gram frequency table from a character vector
#' 
#' f <- kgram_freqs("a b b a a", 3)
#' f
#' summary(f)
#' query(f, c("a", "b")) # c(3, 2)
#' query(f, c("a b", "a" %+% EOS(), BOS() %+% "a b")) # c(1, 1, 1)
#' query(f, "a b b a") # NA (counts for k-grams of order k > 3 are not known)
#' 
#' process_sentences("b", f)
#' query(f, c("a", "b")) # c(3, 3): 'f' is updated in place
#' 
#' f1 <- process_sentences("b", f, in_place = FALSE)
#' query(f, c("a", "b")) # c(3, 3): 'f' is copied
#' query(f1, c("a", "b")) # c(3, 4): the new 'f1' stores the updated counts
#'
#'
#'
#'
#' # Build a k-gram frequency table from a file connection
#' 
#' \dontrun{
#' f <- kgram_freqs(file("my_text_file.txt"), 3)
#' }
#' 
#' 
#' # Build a k-gram frequency table from an URL connection
#' \dontrun{
#' f <- kgram_freqs(url("http://my.website/my_text_file.txt"), 3)
#' }
#' @name kgram_freqs
NULL

#---------------------------- kgram_freqs constructors ------------------------#

#' @rdname kgram_freqs
#' @export
kgram_freqs <- function(object, ...) 
        UseMethod("kgram_freqs", object)

#' @rdname kgram_freqs
#' @export
kgram_freqs.numeric <- function(
        object, 
        .preprocess = identity, 
        .tknz_sent = identity, 
        dict = NULL,
        ...
        ) 
        new_kgram_freqs(object, dict, .preprocess, .tknz_sent)

#' @rdname kgram_freqs
#' @export
kgram_freqs.kgram_freqs <- function(object, ...) {
        old <- attr(object, "cpp_obj")
        attr(object, "cpp_obj") <- new(kgramFreqs, old)
        return(object)
}

#' @rdname kgram_freqs
#' @export
kgram_freqs.character <- function(
        object, 
        N,
        .preprocess = identity, 
        .tknz_sent = identity,
        dict = NULL,
        open_dict = is.null(dict),
        verbose = FALSE,
        ...
)
{
        freqs <- new_kgram_freqs(N, dict, .preprocess, .tknz_sent) 
        res <- process_sentences(
                object, 
                freqs, 
                open_dict = open_dict, 
                in_place = TRUE,
                verbose = verbose,
                ...
                )
        return(res) # Constructor returns visibly
} # kgram_freqs.character

#' @rdname kgram_freqs
#' @export
kgram_freqs.connection <- function(
        object,
        N,
        .preprocess = identity,
        .tknz_sent = identity,
        dict = NULL,
        open_dict = is.null(dict),
        verbose = FALSE,
        max_lines = Inf,
        batch_size = max_lines,
        ...
)
{
        freqs <- new_kgram_freqs(N, dict, .preprocess, .tknz_sent) 
        res <- process_sentences(
                object,
                freqs,
                open_dict = open_dict,
                in_place = TRUE,
                max_lines = max_lines,
                batch_size = batch_size,
                verbose = verbose,
                ...
                )
        return(res) # Constructor returns visibly
} # kgram_freqs.connection

#------------------------------ process_sentences -----------------------------#

#' @rdname kgram_freqs
#' @export
process_sentences <- function(
        text,
        freqs,
        .preprocess = attr(freqs, ".preprocess"),
        .tknz_sent = attr(freqs, ".tknz_sent"),
        open_dict = TRUE,
        in_place = TRUE,
        verbose = FALSE,
        ...
        ) 
{
        assert_kgram_freqs(freqs)
        assert_function(.preprocess)
        assert_function(.tknz_sent)
        assert_true_or_false(open_dict)
        assert_true_or_false(in_place)
        assert_true_or_false(verbose)
        
        UseMethod("process_sentences", text)
}
        


#' @rdname kgram_freqs
#' @export
process_sentences.character <- function(
        text,
        freqs,
        .preprocess = attr(freqs, ".preprocess"),
        .tknz_sent = attr(freqs, ".tknz_sent"),
        open_dict = TRUE,
        in_place = TRUE,
        verbose = FALSE,
        ...
)
{
        freqs <- process_sentences_init(freqs, in_place)
        process <- kgram_process_task(
                freqs, .preprocess, .tknz_sent, open_dict, verbose
                )
        process(text)
        if (in_place)
                return(invisible(freqs))
        return(freqs)
} # process_sentences.character

#' @rdname kgram_freqs
#' @export
process_sentences.connection <- function(
        text,
        freqs,
        .preprocess = attr(freqs, ".preprocess"),
        .tknz_sent = attr(freqs, ".tknz_sent"),
        open_dict = TRUE,
        in_place = TRUE,
        verbose = FALSE,
        max_lines = Inf,
        batch_size = max_lines,
        ...
)
{
        assert_positive_integer(max_lines, can_be_inf = TRUE)
        assert_positive_integer(batch_size, can_be_inf = TRUE)
        
        freqs <- process_sentences_init(freqs, in_place)
        # Progress is printed directly from R, so verbose = F here.
        process <- kgram_process_task(
                freqs, .preprocess, .tknz_sent, open_dict, verbose = F
                )
        
        if (!isOpen(text))
                open(text, "r")
        if (is.infinite(batch_size)) 
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
        
        if (in_place)
                return(invisible(freqs))
        return(freqs)
} # process_sentences.connection

#-------------------------------- print methods -------------------------------#
#' @export
print.kgram_freqs <- function(x, ...) {
        cat("A k-gram frequency table.\n")
        return(invisible(x))
}

#' @export
summary.kgram_freqs <- function(object, ...) {
        cat("A k-gram frequency table.\n\n")
        cat("Parameters:\n")
        for (name in names(parameters(object)))
                cat("* ", name, ": ", param(object, name), "\n", sep = "")
        cat("\n")
        cat("Number of words in training corpus:\n")
        cat("* W: ", attr(object, "cpp_obj")$tot_words(), "\n", sep = "")
        cat("\n")
        cat("Number of distinct k-grams with positive counts:\n")
        for (k in 1:param(object, "N"))
                cat("* ", k, "-grams:", attr(object, "cpp_obj")$unique(k), "\n",
                    sep = "")
        return(invisible(object))
}

#' @export
str.kgram_freqs <- function(object, ...) summary(object)

#-------------------------------- internal ------------------------------------#

# Low level constructor for class 'kgram_freqs'
new_kgram_freqs <- function(N, dict, .preprocess, .tknz_sent) 
{
        assert_positive_integer(N)
        assert_function(.preprocess)
        assert_function(.tknz_sent)
        tryCatch(
                dict <- as_dictionary(dict),
                error = function(cnd) {
                        kgrams_domain_error(
                                name = "dict", 
                                what = "coercible to dict"
                                )
                })
        
        cpp_obj <- new(kgramFreqs, N, attr(dict, "cpp_obj"))
        structure(list(),
                  .preprocess = utils::removeSource(.preprocess),
                  .tknz_sent = utils::removeSource(.tknz_sent),
                  cpp_obj = cpp_obj, 
                  class = "kgram_freqs"
                  )
}

process_sentences_init <- function(freqs, in_place) {
        if (!in_place) {
                old <- attr(freqs, "cpp_obj")
                attr(freqs, "cpp_obj") <- new(kgramFreqs, old)
        }
        return(freqs)
}

kgram_process_task <- function(
        freqs, .preprocess, .tknz_sent, open_dict, verbose
) {
        cpp_obj <- attr(freqs, "cpp_obj")
        function(batch) {
                tryCatch(
                        batch <- .preprocess(batch),
                        error = function(cnd) {
                                h <- "Preprocessing error"
                                x <- "There was an error during text preprocessing."
                                i <- "Try checking the '.preprocess' argument."
                                rlang::abort(
                                        c(h, x = x, i = i),
                                        class = "kgrams_preproc_error"
                                        )
                        })
                tryCatch(
                        batch <- .tknz_sent(batch),
                        error = function(cnd) {
                                h <- "Sentence tokenization error"
                                x <- "There was an error during sentence tokenization."
                                i <- "Try checking the '.tknz_sent' argument."
                                rlang::abort(
                                        c(h, x = x, i = i),
                                        class = "kgrams_tknz_sent_error"
                                )
                        })
                cpp_obj$process_sentences(batch, !open_dict, verbose)
        } # return
}
