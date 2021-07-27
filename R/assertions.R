#' @srrstats {G2.0} 
#' *Implement assertions on lengths of inputs*

kgrams_domain_error <- function(name, what) {
        h <- "Invalid argument"
        x <- paste0("'", name, "'", " must be ", what, ".")
        rlang::abort(c(h, x = x), class = "kgrams_domain_error")
}

assert_positive_integer <- function(
        x, can_be_inf = FALSE, name = deparse(substitute(x))
        ) 
{
        p <- is.numeric(x) && length(x) == 1 && !is.na(x) &&
                (
                        (is.infinite(x) && can_be_inf) || 
                        (!is.infinite(x) && as.integer(x) == x && x > 0)
                )
        if (p) 
                return(invisible(NULL))
        kgrams_domain_error(name = name, what = "a length one positive integer")
}

assert_probability <- function(x, name = deparse(substitute(x))) 
{
        p <- is.numeric(x) && length(x) == 1 && !is.na(x) && 0 <= x && x <= 1
        if (p)
                return(invisible(NULL))
        kgrams_domain_error(name = name, what = "a number between 0 and 1")
}

assert_function <- function(x, name = deparse(substitute(x))) {
        if (is.function(x))
                return(invisible(NULL))
        kgrams_domain_error(name = name, what = "a function")
}

assert_true_or_false <- function(x, name = deparse(substitute(x))) {
        p <- is.logical(x) && length(x) == 1 && !is.na(x)
        if (p)
                return(invisible(NULL))
        kgrams_domain_error(name = name, what = "TRUE or FALSE")
}

identical_s3_structure <- function(x, y) {
        identical(
                c(class(x), names(attributes(x))),
                c(class(y), names(attributes(y)))
        )
}

assert_kgram_freqs <- function(x, name = deparse(substitute(x))) {
        if ( identical_s3_structure(x, kgram_freqs(1)) )
                return(invisible(NULL))
        kgrams_domain_error(name = name, what = "a 'kgram_freqs' class object")
}

assert_smoother <- function(x, name = deparse(substitute(x))) {
        if (!is.character(x) || length(x) != 1 || is.na(x))
                kgrams_domain_error(name, "a length one character (not NA).")
        if (!(x %in% smoothers()))
                rlang::abort(
                        message = c("Invalid smoother",
                                    i = "List of available smoothers:",
                                    paste(smoothers(), collapse = ", ")
                                    ),
                        class = c("kgrams_smoother_error")
                )
}
        