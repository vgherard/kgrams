#' @export
sample_sentences <- function(
        freqs, 
        n, 
        max_length,
        method = c("StupidBackoff", "Add-k", "Laplace", "ML"),
        par,
        t = 1.0
        ) {
        check_method(method, par)
        f <- attr(freqs, "cpp_obj")
        if (method == "StupidBackoff") {
                sample_sentences_sbo(f, n, max_length, par[["lambda"]], t)        
        } else if (method == "Add-k") {
                sample_sentences_addk(f, n, max_length, par[["k"]], t)
        } else if (method == "Laplace") {
                sample_sentences_addk(f, n, max_length, 1.0, t)        
        } else if (method == "ML") {
                sample_sentences_ml(f, n, max_length, t)        
        } else {
                stop("method '", method, "' is not available")
        }
}
