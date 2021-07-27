test_that("param.kgram_freqs gives expected results in simple case", {
        f <- kgram_freqs(2, dict = c("a", "b", "c"))
        expect_equal(param(f, "N"), 2)
        expect_equal(param(f, "V"), 3)
})

test_that("param.kgram_freqs throws error for unknown parameter", {
        f <- kgram_freqs(2)
        expect_error(param(f, "slope"), class = "kgrams_unknown_par_error")
})

test_that("param<-.kgram_freqs throws error in simple case", {
        f <- kgram_freqs(2, dict = c("a", "b", "c"))
        expect_error(param(f, "N") <- 4, class = "kgrams_read_only_par_error")
})


test_that("parameters.kgram_freqs gives expected results in simple case", {
        f <- kgram_freqs(2, dict = c("a", "b", "c"))
        expect_equal(parameters(f), list(N = 2, V = 3))
})

test_that("param.language_model gives expected results in simple case", {
        f <- kgram_freqs(2, dict = c("a", "b", "c"))
        m <- language_model(f, "sbo", lambda = 0.4)
        expect_equal(param(m, "N"), 2)
        expect_equal(param(m, "V"), 3)
        expect_equal(param(m, "lambda"), 0.4)
})

test_that("param.language_model throws error for unknown parameter", {
        f <- kgram_freqs(2, dict = c("a", "b", "c"))
        m <- language_model(f, "sbo", lambda = 0.4)
        expect_error(param(m, "slope"), class = "kgrams_unknown_par_error")
})

test_that("parameters.language_model gives expected results in simple case", {
        f <- kgram_freqs(2, dict = c("a", "b", "c"))
        m <- language_model(f, "sbo", lambda = 0.4)
        expect_equal(parameters(m), list(N = 2, V = 3, lambda = 0.4))
})

test_that("parameters does not throw for default args", {
        f <- kgram_freqs(3)
        for (smoother in smoothers()) {
                l <- list_parameters(smoother)
                pars <- lapply(l, function(x) x$default)
                names(pars) <- sapply(l, function(x) x$name)
                args <- c(list(f, smoother = smoother), pars)
                m <- do.call(language_model, args)

                for (name in names(pars))
                        expect_error(param(m, name) <- pars[[name]], NA)
        }
})

test_that("param<- throws for invalid parameter values", {
        f <- kgram_freqs(3)
        m <- language_model(f, "sbo", lambda = 0.75)
        expect_error(
                param(m, "lambda") <- 10, class = "kgrams_invalid_par_error"
        )
        expect_error(
                param(m, "x") <- 840, class = "kgrams_unknown_par_error"
        )
        expect_error(
                param(m, "V") <- 840, class = "kgrams_read_only_par_error"
        )
        expect_error(
                param(m, "N") <- 840, class = "kgrams_invalid_par_error"
        )
        
        
})