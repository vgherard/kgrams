test_that("tknz_sent returns a character vector", {
        input <- c("This is a sentence.", "This is another one.")
        res <- tknz_sent(input)
        
        expect_vector(res, character())
})

test_that("character(0) in, character(0) out", {
        expect_identical(tknz_sent(character()), character())
})

test_that("NA input results in an error", {
        expect_error(tknz_sent(NA))
})

test_that("empty string in, empty string out", {
        expect_identical(tknz_sent(""), character())
})

test_that("default args split at subsequent punctuation characters", {
        input <- "Sentence one. Sentence two?? Sentence three!!!"
        actual <- tknz_sent(input)
        expected <- c("Sentence one", "Sentence two", "Sentence three")
        
        expect_identical(actual, expected)
})

test_that("keep_first = TRUE adds a spaced punctuation token", {
        input <- "Sentence one. Sentence two?? Sentence three!!!"
        actual <- tknz_sent(input, keep_first = TRUE)
        expected <- c("Sentence one .", "Sentence two ?", "Sentence three !")
        
        expect_identical(actual, expected)
})

test_that("only punctuation leads to no sentence", {
        inputs <- c(".",
                   "...",
                   " .",
                   ". ",
                   " . .. . ")
        
        for (input in inputs)
                expect_identical(tknz_sent(input), character(0))
})

test_that("left space is trimmed when tokenizing some sentence", {
        input <- "   this is a sentence."
        actual <- tknz_sent(input)
        expected <- "this is a sentence"
        
        expect_identical(actual, expected)
})

test_that("left space is trimmed when tokenizing some sentence - bis", {
        input <- "   this is a sentence."
        actual <- tknz_sent(input, keep_first = TRUE)
        expected <- "this is a sentence ."
        
        expect_identical(actual, expected)
})

test_that("right space is trimmed when tokenizing some sentence", {
        input <- "this is a sentence     ."
        actual <- tknz_sent(input)
        expected <- "this is a sentence"
        
        expect_identical(actual, expected)
})