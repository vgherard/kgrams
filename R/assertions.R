

kgrams_domain_error <- function(name, what) {
        h <- "Invalid argument"
        x <- paste0("'", name, "'", " must be ", what, ".")
        rlang::abort(c(h, x = x), class = "kgrams_domain_error")
}

assert_number <- function(x, name = deparse(substitute(x)))
{
        if (is.numeric(x) && length(x) == 1 && !is.na(x))
                return(invisible(NULL))
        kgrams_domain_error(name = name, what = "a length one numeric (not NA)")
}

assert_character_no_NA <- function(x, name = deparse(substitute(x)))
{
        if (!is.character(x) || any(is.na(x)))
                kgrams_domain_error(name, "a character vector without any NAs.")
}


assert_string <- function(x, name = deparse(substitute(x))) {
        if (is.character(x) && length(x) == 1 && !is.na(x))
                return(invisible(NULL))
        kgrams_domain_error(name, what = "a length one character (not NA)")
}

assert_positive_number <- function(x, name = deparse(substitute(x)))
{
        assert_number(x, name = name)
        if (x <= 0)
                kgrams_domain_error(name = name, what = "positive")
}

assert_positive_integer <- function(
        x, can_be_inf = FALSE, name = deparse(substitute(x))
        ) 
{
        assert_number(x, name = name)
        p <- (is.infinite(x) && can_be_inf) || 
                (!is.infinite(x) && as.integer(x) == x && x > 0)
        if (p) 
                return(invisible(NULL))
        kgrams_domain_error(name = name, what = "a positive integer")
}

assert_probability <- function(x, name = deparse(substitute(x))) 
{
        assert_number(x, name = name)
        if (0 <= x && x <= 1)
                return(invisible(NULL))
        kgrams_domain_error(name = name, what = "a number between 0 and 1")
}

assert_function <- function(x, name = deparse(substitute(x))) {
        if (is.function(x))
                return(invisible(NULL))
        kgrams_domain_error(name = name, what = "a function")
}

assert_true_or_false <- function(x, name = deparse(substitute(x))) {
        if (is.logical(x) && length(x) == 1 && !is.na(x))
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

assert_language_model <- function(x, name = deparse(substitute(x))) {
        if ( identical_s3_structure(x, language_model(kgram_freqs(1), "ml")) )
                return(invisible(NULL))
        kgrams_domain_error(name = name, what = "a 'language_model' object")
}

assert_smoother <- function(x, name = deparse(substitute(x))) {
        assert_string(x, name = name)
        if (!(x %in% smoothers()))
                rlang::abort(
                        message = c("Invalid smoother",
                                    i = "List of available smoothers:",
                                    paste(smoothers(), collapse = ", ")
                                    ),
                        class = c("kgrams_smoother_error")
                )
}