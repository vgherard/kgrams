#' @export
probability <- function(freqs, word, context, method = c("StupidBackoff"), par)
{
        if (method == "StupidBackoff") {
                if (missing(par) || is.null(par[["lambda"]])) {
                        stop("Stupid Backoff requires parameter 'lambda'")
                }
                lambda <- par[["lambda"]]
                probability_sbo(attr(freqs, "cpp_obj"), word, context, lambda)        
        }
        
}