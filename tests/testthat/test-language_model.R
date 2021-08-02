test_that("new_language_model returns the desired structure", {
        # Dummy arguments, to test matching expectation
        args <- list(
                cpp_obj = "obj",
                cpp_freqs = "freqs",
                .preprocess = gsub,
                .tknz_sent = identity,
                smoother = "ml"
                )
        class <- "language_model"
        
        res <- do.call(new_language_model, args)
                
        expect_s3_class(res, class)
        for (name in names(args))
                expect_identical(attr(res, name), args[[name]])
})

test_that("language_model.kgram_freqs throws for N larger than the kgram order",
{
        f <- kgram_freqs(3)
        expect_error(
                language_model(f, smoother = "ml", N = 4), 
                class = "kgrams_lm_max_order_error"
                )
})

test_that("language_model.language_model works like a copy constructor", {
        m <- language_model(kgram_freqs(2), "ml")
        m1 <- language_model(m)
        expect_false(identical(m, m1))
        
        attr(m1, "cpp_obj") <- attr(m, "cpp_obj") 
        expect_identical(m, m1)
})

test_that("language_model() uses defaults if model parameters are not specified", {
        suppressWarnings(m <- language_model(kgram_freqs(2), "add_k"))
        expect_equal(param(m, "k"), 1)
})


test_that("language_model class has print, str and summary methods", {
        skip_if(R.version$major < 4,
                message = "format() method of methods(..) different in R < 4"
        )
        funs <- c("print", "str", "summary")
        methods <- format(methods(class = "language_model"))
        expect_true(all(funs %in% methods))
})

test_that("print, str and summary methods return invisibly", {
        funs <- list(print, str, summary)
        m <- language_model(kgram_freqs(3))
        capture_output(
                for (fun in funs) {
                        expect_invisible(fun(m))
                        expect_identical(fun(m), m)
                })
})