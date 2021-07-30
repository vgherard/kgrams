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

test_that("empty string in, empty string out", {
        expect_identical(preprocess(""), "")
})


test_that("erase = \"\" and lower_case = F is equivalent to no preprocessing", 
{
        input <- paste(
                "A string containing:",
                letters, LETTERS, "0123456789", ".,!?;:"
                )
        output <- preprocess(input, erase = "", lower_case = FALSE)
        
        expect_identical(output, input)
})

test_that("R style regexes as 'erase' argument correctly work in simple cases", 
{
        input <- "this string contains spaced words"
        actual <- preprocess(input, erase = "[[:space:]]")
        expected <- "thisstringcontainsspacedwords"
        
        input <- "1 string, 2 digits"
        actual <- preprocess(input, erase = "[[:digit:]]")
        expected <- " string,  digits"
        
        expect_identical(actual, expected)
})

test_that("lower_case argument works for simple case", {
        input <- LETTERS
        actual <- preprocess(input, erase = "", lower_case = TRUE)
        expected <- letters
        
        expect_identical(actual, expected)
})
