new_dictionary <- function(cpp_obj = new(Dictionary)) {
        structure(list(), cpp_obj = cpp_obj, class = "kgrams_dictionary")
}

#' @export
print.kgrams_dictionary <- function(x, ...) {
        cat("A dictionary.\n")
        return(invisible(x))
}
        

#' @export
summary.kgrams_dictionary <- function(object, ...) {
        cat("A dictionary of size ", length(dictionary), ".\n")
        return(invisible(object))
}

#' @export
str.kgrams_dictionary <- function(object, ...) summary(object)


#' Word dictionaries
#'
#' Construct or coerce to and from a dictionary.
#'
#' @author Valerio Gherardi
#' @md
#'
#' @param object object from which to extract a dictionary, or to be coerced to 
#' dictionary.
#' @param .preprocess a function taking a character vector as input and returning
#' a character vector as output. Optional preprocessing transformation  
#' applied to text before creating the dictionary.
#' @param size either \code{NULL} or a length one positive integer. Predefined size of the
#' required dictionary (the top \code{size} most frequent words are retained).
#' @param cov either \code{NULL} or a length one numeric between \code{0} and \code{1}. 
#' Predefined text coverage fraction of the dictionary 
#' (the most frequent words providing the required coverage are retained).
#' @param thresh either \code{NULL} or length one a positive integer. 
#' Minimum word count threshold to include a word in the dictionary.
#' @param max_lines a length one positive integer or \code{Inf}.
#' Maximum number of lines to be read from the \code{connection}. 
#' If \code{Inf}, keeps reading until the End-Of-File.
#' @param batch_size a length one positive integer less than or equal to
#' \code{max_lines}.Size of text batches when reading text from 
#' \code{connection}.
#' @param ... further arguments passed to or from other methods.
#' @param x a \code{dictionary}.
#' 
#' @return A \code{dictionary} for \code{dictionary()} and 
#' \code{as_dictionary()}, a character vector for the \code{as.character()}
#' method.
#' @details These generic functions are used to build \code{dictionary} objects, 
#' or to coerce from other formats to \code{dictionary}, and from a 
#' \code{dictionary} to a character vector. By now, the only 
#' non-trivial type coercible to \code{dictionary} is \code{character}, 
#' in which case each entry of the input vector is considered as a single word.
#' Coercion from \code{dictionary} to \code{character} returns the list of
#' words included in the dictionary as a regular character vector.
#' 
#' Dictionaries can be extracted from \code{kgram_freqs} objects, or \emph{built} 
#' from text coming either directly from a character vector or a connection.
#' 
#' A single preprocessing transformation can be applied before processing the 
#' text for unique words. After preprocessing, 
#' \emph{anything delimited by one or more white space characters} 
#' in the transformed text input \emph{is counted as a word} and may be added
#' to the dictionary modulo additional constraints.
#' 
#' The possible constraints for including a word in the dictionary can be of
#' three types: (i) fixed size of dictionary, implemented by the \code{size} 
#' argument; (ii) fixed text covering fraction, as specified by the \code{cov}
#' argument; or (iii) minimum word count threshold, \code{thresh} argument. 
#' \emph{Only one of these constraints can be applied at a time}, 
#' so that specifying more than one of \code{size}, \code{cov} or \code{thresh} 
#' results in an error. 
#' 
#' @examples 
#' # Building a dictionary from Shakespeare's "Much Ado About Nothing"
#' 
#' dict <- dictionary(much_ado)
#' length(dict)
#' query(dict, "leonato") # TRUE
#' query(dict, c("thy", "thou")) # c(TRUE, TRUE)
#' query(dict, "smartphones") # FALSE
#' 
#' # Getting list of words as regular character vector
#' words <- as.character(dict)
#' head(words)
#' 
#' # Building a dictionary from a list of words
#' dict <- as_dictionary(c("i", "the", "a"))
#' 
#' @name dictionary
NULL

#' @rdname dictionary
#' @export
dictionary <- function(object, ...) {
        if (missing(object) || is.null(object))
                return(new_dictionary())
        UseMethod("dictionary", object)
}

#' @rdname dictionary
#' @export
dictionary.kgram_freqs <- function(
        object, 
        size = NULL, 
        cov = NULL, 
        thresh = NULL,
        ...
        ) 
{
        x <- sum(!is.null(size), !is.null(cov), !is.null(thresh))
        
        if (x > 1) {
                h <- "Invalid input"
                x <- "Only one of 'size', 'cov' or 'thresh' can be != NULL."
                rlang::abort(c(h, x), class = "kgrams_domain_error")
        }
        
        full_dict <- new_dictionary(attr(object, "cpp_obj")$dictionary())
        if (x == 0)
                return(full_dict)
        
        words <- as.character(full_dict)
        freqs <- query(object, words)
        o <- order(freqs, decreasing = TRUE)
        words <- words[o]
        freqs <- freqs[o]
        
        if (!is.null(size)) {
                assert_positive_integer(size)
                subset <- 1:min(size, length(words))
        } else if (!is.null(cov)) {
                subset <- 1:which.max(cumsum(freqs) / sum(freqs) >= cov)
        } else if (!is.null(thresh)) {
                assert_positive_integer(thresh)
                subset <- 1:(which.max(freqs < thresh) - 1)
        }
        
        as_dictionary(words[subset])
}
        
        
#' @rdname dictionary
#' @export
dictionary.character <- function(
        object,
        .preprocess = identity, 
        size = NULL, 
        cov = NULL, 
        thresh = NULL,
        ...
        )
{
        f <- kgram_freqs(object, 1, .preprocess = .preprocess)
        dictionary(f, size, cov, thresh)
}

#' @rdname dictionary
#' @export
dictionary.connection <- function(
        object,
        .preprocess = identity,
        size = NULL, 
        cov = NULL, 
        thresh = NULL,
        max_lines = Inf,
        batch_size = max_lines,
        ...
        )
{
        f <- kgram_freqs(
                object, 1, 
                .preprocess = .preprocess, 
                max_lines = max_lines,
                batch_size = batch_size
                )
        dictionary(f, size, cov, thresh)
}

#' @rdname dictionary
#' @export       
as_dictionary <- function(object) {
        if (is.null(object))
                return(new_dictionary())
        UseMethod("as_dictionary", object)
}
        

#' @rdname dictionary
#' @export
as_dictionary.kgrams_dictionary <- function(object) return(object)

#' @rdname dictionary
#' @export
as_dictionary.character <- function(object) {
        cpp_obj <- new(Dictionary, object)
        return(new_dictionary(cpp_obj))
}

#' @rdname dictionary
#' @export
as.character.kgrams_dictionary <- function(x, ...)
        return( attr(x, "cpp_obj")$as_character() )

#' @export
length.kgrams_dictionary <- function(x)
       attr(x, "cpp_obj")$length()
