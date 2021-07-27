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
