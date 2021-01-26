#' @export
probability <- function(freqs, word, context, 
                        method = c("StupidBackoff", "Add-k", "Laplace", "ML"), 
                        par
                        )
{
        check_method(method, par)
        f <- attr(freqs, "cpp_obj")
        if (method == "StupidBackoff") {
                res <- probability_sbo(f, word, context, par[["lambda"]])        
        } else if (method == "Add-k") {
                res <- probability_addk(f, word, context, par[["k"]])        
        } else if (method == "Laplace") {
                res <- probability_addk(f, word, context, 1.0)        
        } else if (method == "ML") {
                res <- probability_ml(f, word, context)        
        }
        
        return(prob)
}