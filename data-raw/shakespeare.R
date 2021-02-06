.preprocess <- function(x) {
        # Remove character names and locations (boldfaced in original html)
        x <- gsub("<b>[A-z]+</b>", "", x)
        # Remove all other html tags
        x <- gsub("<[^>]+>||<[^>]+$||^[^>]+>$", "", x)
        # Apply standard preprocessing including lower-case
        x <- kgrams::preprocess(x)
        # Tokenize sentences keeping Shakespeare's punctuation
        x <- kgrams::tknz_sent(x, keep_first = TRUE)
        # Remove empty sentences
        x <- x[x != ""]
        # Collapse everything into a single string
        x <- paste(x, collapse = " ")
}

local({

con <- url("http://shakespeare.mit.edu/much_ado/full.html")
much_ado <- readLines(con)
close(con)
much_ado <- .preprocess(much_ado)
usethis::use_data(much_ado, overwrite = TRUE)

con <- url("http://shakespeare.mit.edu/midsummer/full.html")
midsummer <- readLines(con)
close(con)
midsummer <- .preprocess(midsummer)
usethis::use_data(midsummer, overwrite = TRUE)

})
