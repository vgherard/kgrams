test_that("list_parameters has the required structure", {
        for (smoother in smoothers()) {
                l <- list_parameters(smoother)
                expect_vector(l, list())
                for (par in l) {
                        expect_vector(par, list(), 4)
                        expect_vector(par[["name"]], character(), 1)
                        expect_vector(par[["expected"]], character(), 1)
                        expect_vector(par[["default"]], numeric(), 1)
                        expect_true(is.function(par[["validator"]]))
                }
        }
})

test_that("smoother_par_missing throws a warning of the correct class", {
        expect_warning(
                smoother_par_missing("smoother", "par", "default"),
                class = "kgrams_missing_par_warning"
                )
})

test_that("smoother_par_missing throws a warning only once", {
        capture_output(smoother_par_missing("smoother", "par", 1))
        expect_warning(
                smoother_par_missing("smoother", "par", 1),
                NA
        )
})

test_that("smoother_par_error throws an error of the correct class", {
        expect_error(
                smoother_par_error("smoother", "par", "expected"),
                class = "kgrams_invalid_par_error"
        )
})

test_that("validate_smoother does not throw errors on default values", {
        for (smoother in smoothers()) {
                l <- list_parameters(smoother)
                args <- lapply(l, function(x) x$default)
                names(args) <- sapply(l, function(x) x$name)
                args <- c(list(smoother = smoother), args)
                expect_error(do.call(validate_smoother, args), NA)
        }
})

test_that("validate_smoother throws a warning for missing parameter", {
        expect_warning(
                validate_smoother("sbo"),
                class = "kgrams_missing_par_warning"
        )
})

test_that("validate_smoother throws an error for invalid parameter", {
        expect_error(
                validate_smoother("sbo", lambda = -1),
                class = "kgrams_invalid_par_error"
        )
})
