test_that("assert_positive_integer", {
        class <- "kgrams_domain_error"
        expect_error(assert_positive_integer(1), NA)
        expect_error(assert_positive_integer("1"), class = class)
        expect_error(assert_positive_integer(c(1, 2)), class = class)
        expect_error(assert_positive_integer(NA_integer_), class = class)
        expect_error(assert_positive_integer(3.14), class = class)
        expect_error(assert_positive_integer(-1), class = class)
        
        # Test behaviour with Inf 
        expect_error(assert_positive_integer(Inf), class = class)
        expect_error(assert_positive_integer(Inf, can_be_inf = TRUE), NA)
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

test_that("assert_kgram_freqs", {
        class <- "kgrams_domain_error"
        expect_error(assert_kgram_freqs(kgram_freqs(1)), NA)
        expect_error(assert_kgram_freqs("kgram_freqs"), class = class)
        
        # Should throw if some attribute of 'kgram_freqs is missing
        x <- kgram_freqs(1); attr(x, "cpp_obj") <- NULL
        expect_error(assert_kgram_freqs(x), class = class)
})