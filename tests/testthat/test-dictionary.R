test_that("new_dictionary() returns the desired structure", {
        expect_s3_class(new_dictionary(), "kgrams_dictionary", exact = TRUE)
        
        # Test with dummy cpp_obj
        cpp_obj <- 840L
        res <- new_dictionary(cpp_obj)
        expect_s3_class(res, "kgrams_dictionary", exact = TRUE)
        expect_identical(attr(res, "cpp_obj"), cpp_obj)
})

test_that("coercion to and from character works as expected", {
        words <- c("a", "b", "c")
        expect_identical(as.character(as_dictionary(words)), words)
})

test_that("Creating dictionary from character works as expected", {
        words <- c("a", "b", "c")
        expect_identical(as.character(dictionary(words)), words)
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