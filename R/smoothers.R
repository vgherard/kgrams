#' k-gram Probability Smoothers
#' 
#' @description
#' 
#' Information on available k-gram continuation probability smoothers.
#' 
#' ### List of smoothers currently supported by \code{kgrams}
#' 
#' - \code{"ml"}: Maximum Likelihood estimate 
#' \insertCite{markov1913essai}{kgrams}.
#' - \code{"add_k"}: Add-k smoothing 
#' \insertCite{dale1995philosophical,lidstone1920note,johnson1932probability,jeffreys1998theory}{kgrams}.
#' - \code{"abs"}: Absolute discounting \insertCite{ney1991smoothing}{kgrams}.
#' - \code{"wb"}: Witten-Bell smoothing \insertCite{bell1990text,witten1991zero}{kgrams}
#' - \code{"kn"}: Interpolated Kneser-Ney with fixed discount. 
#' \insertCite{Kneser1995ImprovedBF,chen1999empirical}{kgrams}.
#' - \code{"sbo"}: Stupid Backoff \insertCite{brants-etal-2007-large}{kgrams}.
#'
#' @author Valerio Gherardi
#' @md
#' 
#' @param smoother a string. Code name of probability smoother.
#' 
#' @return \code{smoothers()} returns a character vector, the list of code names
#' of probability smoothers available in \link[kgrams]{kgrams}. 
#' \code{info(smoother)} returns \code{NULL} and prints some information on 
#' the selected smoothing technique.
#' @examples
#' # List available smoothers
#' smoothers()
#' 
#' # Get information on smoother "kn", i.e. Interpolated Kneser-Ney
#' info("kn")
#' 
#' @references 
#' \insertAllCited{}
#' 
#' @name smoothers

#' @rdname smoothers
#' @export
smoothers <- function() c("ml", "add_k", "abs", "kn", "sbo", "wb")

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
        
        if (smoother == "abs")
                cat("Absolute discounting\n",
                    "* code: 'abs'\n",
                    "* parameters: D (discount in higher order probability part)\n",
                    "* constraints: 0 < D < 1\n")
        
        if (smoother == "wb")
                cat("Witten-Bell Smoothing\n",
                    "* code: 'wb'\n",
                    "* parameters: none\n",
                    "* constraints: none\n")
}