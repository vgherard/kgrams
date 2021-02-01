new_dictionary <- function(cpp_obj) {
        structure(list(), cpp_obj = cpp_obj, class = "kgrams_dictionary")
}

#' Word dictionaries
#'
#' Construct or coerce to a dictionary.
#'
#' @author Valerio Gherardi
#' @md
#'
#' @param text a character vector, a connection or missing/\code{NULL}. 
#' Source of text from which k-gram frequencies are to be extracted.
#' @param object an object to be coerced to dictionary.
#' @param .preprocess a function taking a character vector as input and returning
#' a character vector as output. Optional preprocessing transformation  
#' applied to text before creating the dictionary.
#' @param size either \code{NULL} or a positive integer. Predefined size of the
#' required dictionary (the top \code{size} most frequent words are retained).
#' @param cov either \code{NULL} or a number between \code{0} and \code{1}. 
#' Predefined text coverage fraction of the dictionary 
#' (the most frequent words providing the required coverage are retained).
#' @param thresh either \code{NULL} or a positive integer. 
#' Predefined text coverage fraction of the dictionary 
#' (the most frequent words providing the required coverage are retained).
#' @param batch_size a length one positive integer or \code{NULL}.
#' Size of text batches when reading text from a \code{file} or a generic 
#' \code{connection}. If \code{NULL}, all input text is processed in a single 
#' batch.
#' @param ... further arguments passed to or from other methods.
#' 
#' @return A \code{dictionary}.
#' @details These generic functions are used to build dictionaries from a text
#' source, or to coerce other formats to \code{dictionary}. By now, the only 
#' non-trivial coercible type is \code{character}, in which case each entry 
#' of the input vector is considered as a single word.
#' 
#' Dictionaries can be \emph{built} from text coming either directly from a 
#' character vector, or from a connection. The second option is useful if one 
#' wants to avoid loading the full text corpus in physical memory, 
#' allowing to process text from different sources such as files, compressed 
#' files or URLs.
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
#' raises an error. 
#' 
#' @name dictionary
NULL

#' @rdname dictionary
#' @export
dictionary <- function(text, ...) {
        if (missing(text) || is.null(text))
                return(dictionary_missing())
        cpp_obj <- new(Dictionary)
        UseMethod("dictionary", text)
}
        
#' @rdname dictionary
#' @export
dictionary.character <- function(text,
                                 .preprocess = identity, 
                                 size = NULL, 
                                 cov = NULL, 
                                 thresh = NULL,
                                 ...
                                 )
{
        process <- dict_insert_task(cpp_obj, .preprocess, size, cov, thresh)
        process(text)
        new_dictionary(cpp_obj)
}

#' @rdname dictionary
#' @export
dictionary.connection <- function(text,
                                  .preprocess = identity,
                                  size = NULL, 
                                  cov = NULL, 
                                  thresh = NULL,
                                  batch_size = NULL,
                                  ...
                                  )
{
        process <- dict_insert_task(cpp_obj, .preprocess, size, cov, thresh)
        if (is.null(batch_size)) 
                batch_size <- -1L
        
        open(text, "r")
        while (length(batch <- readLines(text, batch_size)))
                process(batch)
        close(text)
        
        return(new_dictionary(cpp_obj))
}

dictionary_missing <- function() {
        cpp_obj <- new(Dictionary)
        return(new_dictionary(cpp_obj))
}

dict_insert_task <- function(cpp_obj, .preprocess, size, cov, thresh) {
        # if (!is.null(size) + !is.null(size) + !is.null(thresh) > 1)
        #         stop("At most one of 'size', 'cov' or 'thresh' can be specified"
        #         )
        function(batch) {
                batch <- .preprocess(batch)
                if (!is.null(size)) {
                        cpp_obj$insert_n(batch, size)
                } else if (!is.null(thresh)) {
                        cpp_obj$insert_cover(batch, cov)
                } else if (!is.null(thresh)) {
                        cpp_obj$insert_above(batch, thresh)
                } else {
                        cpp_obj$insert_above(batch, 0L)
                }
        }
}

#' @rdname dictionary
#' @export       
as.dictionary <- function(object) UseMethod("as.dictionary", object)

#' @rdname dictionary
#' @export
as.dictionary.kgrams_dictionary <- function(object) return(object)

#' @rdname dictionary
#' @export
as.dictionary.character <- function(object) {
        cpp_obj <- new(Dictionary, object)
        return(new_dictionary(cpp_obj))
}

#' @export
length.kgrams_dictionary <- function(x)
       attr(x, "cpp_obj")$length()