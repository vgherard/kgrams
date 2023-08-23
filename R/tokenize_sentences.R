#' Sentence tokenizer
#'
#' Extract sentences from a batch of text lines.
#'
#' @author Valerio Gherardi
#' @md
#'
#' @param input a character vector.
#' @param EOS a regular expression matching an End-Of-Sentence delimiter.
#' @param keep_first TRUE or FALSE? Should the first character of the matches
#' be appended to the returned sentences (with a space)?
#' @return a character vector, each entry of which corresponds to a single
#' sentence.
#' @details
#' \code{tknz_sent()} splits text into sentences using a list of 
#' single character delimiters, specified by the parameter \code{EOS}. 
#' Specifically, when an EOS token is found, the next sentence begins at the
#' first position in the input string not containing any of the EOS tokens 
#' \emph{or white space} (so that entries like \code{"Hi there!!!"} or 
#' \code{"Hello . . ."} are both recognized as a single sentence).
#' 
#' If \code{keep_first} is \code{FALSE}, the delimiters are stripped off from 
#' the returned sequences, which means that all delimiters are treated 
#' symmetrically.
#' 
#' In the absence of any \code{EOS} delimiter, \code{tknz_sent()} 
#' returns the input as is, since parts of text corresponding to different 
#' entries of the input vector \code{x} are understood as parts of separate 
#' sentences.
#' @examples
#' tknz_sent("Hi there! I'm using `sbo`.")
#' @name tknz_sent
#' @export
tknz_sent <- function(input, EOS = "[.?!:;]+", keep_first = FALSE) {
        
        if (.Platform$OS.type == "windows") 
                res <- tknz_sent_win(input, EOS, keep_first)
        else
                res <- tknz_sent_cpp(input, EOS, keep_first)
        
        tknz_sent_postproc(res)
}


# Fallback implementation for windows (C++ implementation does not work) due
# to https://github.com/RcppCore/Rcpp/issues/810
tknz_sent_win <- function(input, EOS, keep_first) {
        assert_string(EOS)
        assert_true_or_false(keep_first)
        
        if (EOS == "") 
                return(input)
        
        sent_bare <- strsplit(input, EOS)
        
        if (!keep_first) {
                return( unlist(sent_bare) )
        }

        puncts <- regmatches(input, gregexpr(EOS, input))
        
        sent_puncts <- lapply(seq_along(sent_bare), function(i) {
                n_sents <- length(sent_bare[[i]])
                endings <- substr(puncts[[i]], 1, 1)
                
                if( length(endings) == n_sents )
                        return(paste(sent_bare[[i]], endings))
                
                c(paste(sent_bare[[i]][-n_sents], endings),
                  sent_bare[[i]][n_sents]
                )
        }) 
        
        return( unlist(sent_puncts) )        
}

tknz_sent_postproc <- function(s) {
        s <- trimws(s, which = "both")
        s[s != ""]
}