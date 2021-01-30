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
#' Internally, \code{preprocess()} converts the string 'pattern' is converted 
#' into a C++ \code{std::regex} class by the default constructor 
#' \code{std::regex::regex(std::string)}.
#' @examples
#' preprocess("#This Is An Example@@-@@!#")
#' @name preprocess
NULL

# Defined in UtilitiesR.cpp