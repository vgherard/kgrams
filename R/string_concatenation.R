#' String concatenation
#' 
#' @author Valerio Gherardi
#' 
#' Brief synthax for string concatenation.
#' 
#' @param lhs a string or vector of strings.
#' @param rhs a string or vector of strings.
#' @return a string or vector of strings.
#' @details The expression \code{lhs %+% rhs} is equivalent to
#' \code{paste(lhs, rhs, sep = " ", collapse = NULL, recycle0 = FALSE)}.
#' See \link[base]{paste} for more details.
#' @examples 
#' "i love" %+% c("cats", "jazz", "you")
#' @seealso \link[base]{paste}
#' 
#' @export
`%+%` <- function(lhs, rhs) {
        return(paste(lhs, rhs, sep = " ", collapse = NULL, recycle0 = FALSE))
}