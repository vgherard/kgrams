test_that("%|% returns a two element list with correct S3 class", {
        obj <- letters %|% "b"
        expect_vector(unclass(obj), list(), 2)
        expect_s3_class(obj, class = "kgrams_word_context", exact = TRUE)
})

test_that("\"word_context\" class has print method", {
        skip_if(R.version$major < 4,
                message = "format() method of methods(..) different in R < 4"
        )
        methods <- format(methods(class = "kgrams_dictionary"))
        expect_true("print" %in% methods)
})