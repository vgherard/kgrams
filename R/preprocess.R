#' Text preprocessing
#'
#' A minimal text preprocessing utility.
#'
#' @author Valerio Gherardi
#' @md
#'
#' @param input a character vector.
#' @param erase a length one character vector. Regular expression matching 
#' parts of text to be \emph{erased} from input. The default removes anything 
#' not  alphanumeric (\code{[A-z0-9]}), space (white space, tab, 
#' vertical tab, newline, form feed, carriage return), apostrophes or 
#' punctuation characters (\code{"[.?!:;]"}).
#' @param lower_case a length one logical vector. If TRUE, puts everything to 
#' lower case.
#' @return a character vector containing the processed output.
#' @details 
#' The expressions \code{preprocess(x, erase = pattern, lower_case = TRUE)} and
#' \code{preprocess(x, erase = pattern, lower_case = FALSE)} are roughly
#' equivalent to \code{tolower(gsub(pattern, "", x))} and 
#' \code{gsub(pattern, "", x)}, respectively, provided that the regular 
#' expression 'pattern' is correctly recognized by R.
#' 
#' **Note.** This function, as well as \link[kgrams]{tknz_sent}, are included 
#' in the library for illustrative purposes only, and are not optimized for 
#' performance. Furthermore (for performance reasons) the function has a 
#' separate implementation for Windows and UNIX OS types, respectively, so that 
#' results obtained in the two cases may differ slightly. 
#' In contexts that require full reproducibility, users are encouraged to define 
#' their own preprocessing and tokenization custom functions - or to work with
#' externally processed data.
#' 
#' @examples
#' preprocess("#This Is An Example@@-@@!#")
#' @name preprocess
#' @export
preprocess <- function(input, 
                       erase = "[^.?!:;'[:alnum:][:space:]]", 
                       lower_case = TRUE
) {
        if (.Platform$OS.type != "windows") 
                return(preprocess_cpp(input, erase, lower_case))
        
        assert_string(erase)
        assert_true_or_false(lower_case)        
        
        res <- gsub(erase, "", input)
        
        if (lower_case)
                return(tolower(res))
        
        return(res)
}
