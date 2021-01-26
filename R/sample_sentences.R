#' @export
sample_sentences <- function(
        freqs, 
        n, 
        max_length,
        method = c("StupidBackoff", "Add-k", "Laplace", "ML"),
        par
        ) {
        check_method(method, par)
        f <- attr(freqs, "cpp_obj")
        if (method == "StupidBackoff") {
                res <- sample_sentences_sbo(f, n, max_length, par[["lambda"]])        
        } else if (method == "Add-k") {
                res <- sample_sentences_addk(f, n, max_length, par[["k"]])
        } else if (method == "Laplace") {
                res <- sample_sentences_addk(f, n, max_length, 0.1)        
        } else if (method == "ML") {
                res <- sample_sentences_ml(f, n, max_length)        
        }
        
        return(res)
}
