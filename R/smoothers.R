#' k-gram Probability Smoothers
#' 
#' Informations on available k-gram continuation probability smoothers
#'
#' @author Valerio Gherardi
#' @md
#' 
#' @param code a string. Code name of probability smoother.
#' 
#' @return \code{smoothers()} returns a character vector, the list of code names
#' of probability smoothers available in \link[kgrams]{kgrams}. 
#' \code{smoother_info(code)} returns \code{NULL} and prints some information on 
#' the selected smoothing technique.
#' @examples
#' # List available smoothers
#' smoothers()
#' 
#' # Get information on smoother "kn", i.e. Interpolated Kneser-Ney
#' smoother_info("kn")
#' @name smoothers

#' @rdname smoothers
#' @export
smoothers <- function() c("sbo", "add_k", "laplace", "ml", "kn")

#' @rdname smoothers
#' @export
info <- function(smoother) {
        if (isFALSE(is.character(smoother) & smoother %in% smoothers())) {
                msgs <- paste("Unrecognized smoother name:", smoother)
                msgs <- c(msgs,
                          i = "You can obtain a list of available" %+%
                                  "smoothing techniques with `smoothers()`"
                )
                rlang::inform(message = msgs, class = "unrecognized_smoother")
        }
        
        if (smoother == "sbo")
                cat("Stupid Backoff\n",
                    "* code: 'sbo'\n",
                    "* parameters: lambda (backoff penalization)\n",
                    "* constraints: 0 < lambda < 1\n",
                    "* notes: does not produce normalized probabilities")
        
        if (smoother == "add_k")
                cat("Add-k Smoother\n",
                    "* code: 'add_k'\n",
                    "* parameters: k (additive constant in k-gram counts)\n",
                    "* constraints: k > 0\n")
        
        if (smoother == "laplace")
                cat("Laplace Smoother\n",
                    "* code: 'laplace'\n",
                    "* parameters: none\n",
                    "* constraints: none\n",
                    "* notes: particular case of Add-k smoothing for k = 1")
        
        if (smoother == "ml")
                cat("Maximum-Likelihood estimate\n",
                    "* code: 'ml'\n",
                    "* parameters: none\n",
                    "* constraints: none\n",
                    "* notes: conditional probabilities are undefined for unseen contexts")
        
        if (smoother == "kn")
                cat("Interpolated Kneser-Ney with fixed discount\n",
                    "* code: 'kn'\n",
                    "* parameters: D (discount in higher order probability part)\n",
                    "* constraints: 0 < D < 1\n")
}