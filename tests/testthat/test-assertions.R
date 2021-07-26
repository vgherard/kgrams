test_that("assert_positive_integer", {
        class <- "kgrams_domain_error"
        expect_error(assert_positive_integer(1), NA)
        expect_error(assert_positive_integer("1"), class = class)
        expect_error(assert_positive_integer(c(1, 2)), class = class)
        expect_error(assert_positive_integer(NA_integer_), class = class)
        expect_error(assert_positive_integer(3.14), class = class)
        expect_error(assert_positive_integer(-1), class = class)
})

test_that("assert_function", {
        class <- "kgrams_domain_error"
        expect_error(assert_function(identity), NA)
        expect_error(assert_function("identity"), class = class)
})

test_that("assert_true_or_false", {
        class <- "kgrams_domain_error"
        expect_error(assert_true_or_false(TRUE), NA)
        expect_error(assert_true_or_false(FALSE), NA)
        expect_error(assert_true_or_false("TRUE"), class = class)
        expect_error(assert_true_or_false(c(TRUE, FALSE)), class = class)
        expect_error(assert_true_or_false(NA), class = class)
})