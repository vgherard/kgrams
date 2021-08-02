test_that("new_dictionary() returns the desired structure", {
        expect_s3_class(new_dictionary(), "kgrams_dictionary", exact = TRUE)
        
        # Test with dummy cpp_obj
        cpp_obj <- 840L
        res <- new_dictionary(cpp_obj)
        expect_s3_class(res, "kgrams_dictionary", exact = TRUE)
        expect_identical(attr(res, "cpp_obj"), cpp_obj)
})

test_that("Coercion to and from character works in simple example", {
        words <- c("a", "b", "c")
        expect_identical(as.character(as_dictionary(words)), words)
})

test_that("Creating dictionary from character works in simple example", {
        words <- c("a b c")
        expect_identical(as.character(dictionary(words)), c("a", "b", "c"))
})

test_that("Creating a dictionary of fixed size works in simple example", {
        words <- c("a a a b b c")
        dict <- dictionary(words, size = 2)
        res <- sort(as.character(dict))
        expect_identical(res, c("a", "b"))
})

test_that("Creating a dictionary with fixed cov works in simple example", {
        words <- c("a a a a a a a a b b c")
        dict <- dictionary(words, cov = 0.5)
        res <- sort(as.character(dict))
        expect_identical(res, "a")
})


test_that("Creating a dictionary with fixed thresh works in simple example", {
        words <- c("a a a b b c")
        dict <- dictionary(words, thresh = 2)
        res <- sort(as.character(dict))
        expect_identical(res, c("a", "b"))
})

test_that("dictionary.kgram_freqs throws if more than one of size, thresh, cov", {
        f <- kgram_freqs(c("a a a b b c"), 1)
        
        class <- "kgrams_domain_error"
        expect_error(dictionary(f, size = 10, thresh = 2), class = class)
        expect_error(dictionary(f, size = 10, cov = 0.7), class = class)
        expect_error(dictionary(f, thresh = 10, cov = 0.7), class = class)
        expect_error(dictionary(f, size = 10, thresh = 1, cov = 0.7), class = class)
})

test_that("dictionary.connection works in simple test case", {
        con <- textConnection(c("a b b b a b a"))
        dict <- dictionary(con)
        res <- sort(as.character(dict))
        expect_identical(res, c("a", "b"))
})

test_that("kgrams_dictionary class has print, str and summary methods", {
        skip_if(R.version$major < 4,
                message = "format() method of methods(..) different in R < 4"
        )
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

test_that("length.kgrams_dictionary works in simple case", {
        dict <- dictionary(letters)
        expect_identical(length(dict), length(letters))
})
