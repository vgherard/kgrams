test_that("new_dictionary() returns the desired structure", {
        # Use dummy cpp_obj, for testing purposes
        cpp_obj <- 840L
        res <- new_dictionary(cpp_obj)
        
        expect_s3_class(res, "kgrams_dictionary", exact = TRUE)
        expect_identical(attr(res, "cpp_obj"), cpp_obj)
})

test_that("kgrams_dictionary class has print, str and summary methods", {
        funs <- c("print", "str", "summary")
        methods <- format(methods(class = "kgrams_dictionary"))
        expect_true(all(funs %in% methods))
})

test_that("print, str and summary methods return invisibly", {
        funs <- list(print, str, summary)
        dict <- dictionary()
        capture_output(
        for (fun in funs) {
                expect_invisible(fun(dict))
                expect_identical(fun(dict), dict)
        })
})