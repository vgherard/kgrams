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
smoother_info <- function(code) {
        if (isFALSE(is.character(code) & code %in% smoothers())) {
                msgs <- paste("Unrecognized smoother name:", code)
                msgs <- c(msgs,
                          i = "You can obtain a list of available" %+%
                                  "smoothing techniques with `smoothers()`"
                )
                rlang::inform(message = msgs, class = "unrecognized_smoother")
        }
        
        if (code == "sbo")
                cat("Stupid Backoff\n",
                    "* code: 'sbo'\n",
                    "* parameters: lambda (backoff penalization)\n",
                    "* constraints: 0 < lambda < 1\n",
                    "* notes: does not produce normalized probabilities"
                )
        
        if (code == "add_k")
                cat("Add-k Smoother\n",
                    "* code: 'add_k'\n",
                    "* parameters: k (additive constant in k-gram counts)\n",
                    "* constraints: k > 0\n"
                )
        
        if (code == "laplace")
                cat("Laplace Smoother\n",
                    "* code: 'laplace'\n",
                    "* parameters: none\n",
                    "* constraints: none\n",
                    "* notes: particular case of Add-k smoothing for k = 1"
                )
        
        if (code == "ml")
                cat("Maximum-Likelihood estimate\n",
                    "* code: 'ml'\n",
                    "* parameters: none\n",
                    "* constraints: none\n",
                    "* notes: probabilities are undefined for unseen contexts"
                )
        
        if (code == "kn")
                cat("Interpolated Kneser-Ney with fixed discount\n",
                    "* code: 'kn'\n",
                    "* parameters: D (discount in higher order probability part)\n",
                    "* constraints: 0 < D < 1\n"
                )
} 


# list of parameters for the various smoothers
parameters <- function(smoother) 
        switch(smoother,
               sbo = list(
                       list(name = "lambda",
                            expected = "a number between zero and one",
                            default = 0.4,
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x & x < 1)
                       )
               ),
               add_k = list(
                       list(name = "k",
                            expected = "a positive number",
                            default = 1.0,  
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x)
                       )
               ),
               laplace = list(),
               ml = list(),
               kn = list(
                       list(name = "D",
                            expected = "a number between zero and one",
                            default = 0.75,
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x & x < 1)
                       )
               )
        )