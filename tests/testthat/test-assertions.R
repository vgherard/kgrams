test_that("assert_number", {
        class <- "kgrams_domain_error"
        expect_error(assert_number(0), NA)
        expect_error(assert_number("0"), class = class)
        expect_error(assert_number(1:10), class = class)
        expect_error(assert_number(NA_real_), class = class)
})

test_that("assert_positive_number", {
        class <- "kgrams_domain_error"
        expect_error(assert_positive_number(1), NA)
        expect_error(assert_positive_number(-1), class = class)
})

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

test_that("assert_string", {
        expect_error(assert_string("a string"), NA)
        
        class <- "kgrams_domain_error"
        expect_error(assert_string(1), class = class)
        expect_error(assert_string(c("a", "b")), class = class)
        expect_error(assert_string(NA_character_), class = class)
})

test_that("assert_character_no_NA", {
        expect_error(assert_character_no_NA(letters), NA)
        
        class <- "kgrams_domain_error"
        expect_error(assert_character_no_NA(1:10), class = class)
        expect_error(assert_character_no_NA(c("hello", NA)), class = class)
})


test_that("assert_probability", {
        class <- "kgrams_domain_error"
        expect_error(assert_probability(0.5), NA)
        expect_error(assert_probability(0), NA)
        expect_error(assert_probability(1), NA)
        expect_error(assert_probability("0.5"), class = class)
        expect_error(assert_probability(c(0.3, 0.6)), class = class)
        expect_error(assert_probability(NA_real_), class = class)
        expect_error(assert_probability(-0.5), class = class)
        expect_error(assert_probability(1.5), class = class)
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

test_that("assert_language_model", {
        class <- "kgrams_domain_error"
        lm <- language_model(kgram_freqs(1), "ml")
        expect_error(assert_language_model(lm), NA)
        expect_error(assert_language_model("lm"), class = class)
        
        # Should throw if some attribute of 'kgram_freqs is missing
        attr(lm, "cpp_obj") <- NULL
        expect_error(assert_language_model(lm), class = class)
})


test_that("assert_smoother", {
        expect_error(assert_smoother("sbo"), NA)
        
        class <- "kgrams_domain_error"
        expect_error(assert_smoother(1), class = class)
        expect_error(assert_smoother(c("sbo", "ml")), class = class)
        expect_error(assert_smoother(NA_character_), class = class)
        
        class <- "kgrams_smoother_error"
        expect_error(assert_smoother("unexisting smoother"), class = class)
})