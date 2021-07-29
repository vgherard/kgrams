test_that("preprocess returns a character vector", {
        input <- c("This is a sentence.", "This is another one.")
        res <- preprocess(input)
        expect_vector(res, character())
})


test_that("character(0) in, character(0) out", {
        expect_identical(preprocess(character()), character())
})

test_that("NA in, NA out", {
        expect_identical(preprocess(NA), NA_character_)
        
        # Test with mixed input
        input <- c("hello", NA, "world")
        expect_identical(preprocess(input), input)
})

