check_method <- function(method, par) {
        if (method == "StupidBackoff") {
                if (missing(par) || is.null(par[["lambda"]]))
                        stop("method 'StupidBackoff'", 
                             "requires parameter 'lambda'" )
        } else if (method == "Add-k") {
                if (missing(par) || is.null(par[["k"]]))
                        stop("method 'Add-k' requires parameter 'k'")
        }
}