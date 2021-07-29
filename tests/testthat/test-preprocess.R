test_that("preprocess returns a character vector", {
        input <- c("This is a sentence.", "This is another one.")
        res <- preprocess(input)
        expect_vector(res, character())
})


test_that("character(0) in, character(0) out", {
        expect_vector(preprocess(character()), character(), 0)
})

test_that("Errors on NA input", {
        
})
