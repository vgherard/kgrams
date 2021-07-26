#' @srrstats {G2.0} 
#' *Implement assertions on lengths of inputs.* 

kgrams_domain_error <- function(name, what) {
        h <- "Invalid argument"
        x <- paste0("'", name, "'", " must be ", what, ".")
        rlang::abort(c(h, x = x), class = "kgrams_domain_error")
}

assert_positive_integer <- function(x) {
        p <- is.numeric(x) && length(x) == 1 && !is.na(x) &&
                as.integer(x) == x && x > 0
        if (p) 
                return(invisible(NULL))
        kgrams_domain_error(
                name = deparse(substitute(x)), 
                what = "a length one positive integer"
                )
}

assert_function <- function(x) {
        if (is.function(x))
                return(invisible(NULL))
        kgrams_domain_error(name = deparse(substitute(x)), what = "a function")
}

assert_true_or_false <- function(x) {
        p <- is.logical(x) && length(x) == 1 && !is.na(x)
        if (p)
                return(invisible(NULL))
        kgrams_domain_error(
                name = deparse(substitute(x)), 
                what = "TRUE or FALSE"
                )
}

identical_s3_structure <- function(x, y) {
        identical(
                c(class(x), names(attributes(x))),
                c(class(y), names(attributes(y)))
        )
}

assert_kgram_freqs <- function(x) {
        if ( identical_s3_structure(x, kgram_freqs(1)) )
                return(invisible(NULL))
        kgrams_domain_error(
                name = deparse(substitute(x)), 
                what = "a 'kgram_freqs' class object"
        )
}
        