.preprocess <- function(x) {
        x <- gsub("<[^>]+>||<[^>]+$||^[^>]+>$", "", x)
        x <- x[x != ""]
        return(tolower(x))
}

.tokenize_sentences <- function(x) {
        kgrams::tokenize_sentences(x, keep_first = TRUE)
}

much_ado <- readLines(url("http://shakespeare.mit.edu/much_ado/full.html"))
much_ado <- .tokenize_sentences( .preprocess(much_ado) )
usethis::use_data(much_ado, overwrite = TRUE)

midsummer <- readLines(url("http://shakespeare.mit.edu/midsummer/full.html"))
midsummer <- .tokenize_sentences( .preprocess(midsummer) )
usethis::use_data(midsummer, overwrite = TRUE)