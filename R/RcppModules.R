#' @export kgramFreqs
Rcpp::loadModule(module = "kgramFreqs", TRUE)
Rcpp::loadModule(module = "Probability", TRUE)
Rcpp::loadModule(module = "Utilities", TRUE)
#' @export Dictionary
Rcpp::loadModule(module = "Dictionary", TRUE)