test_that("probability returns a double of the same length of the input", {
        f <- kgram_freqs("a a a b a b b", 3)
        m <- language_model(f, smoother = "ml")
        
        x <- c("a b a", "b a b", "a")
        expect_vector(probability(x, m), double(), length(x))
        
        words <- c("b", "a")
        x <- words %|% "a a"
        expect_vector(probability(x, m), double(), length(words))
})

test_that("char(0) corner cases are correctly handled", {
        f <- kgram_freqs("a a a b a b b", 3)
        m <- language_model(f, smoother = "ml")
        
        expect_identical(probability(character(0), m), double(0))
        expect_identical(probability(character(0) %|% "a", m), double(0))
})

test_that("NA input results in an error", {
        f <- kgram_freqs("a a a b a b b", 3)
        m <- language_model(f, smoother = "ml")
        
        expect_error(probability(c("a", NA), m), class = "kgrams_domain_error")
})

test_that("contextual probability gives correct results for simple case",{
        f <- kgram_freqs("a a a b a b b", 3)
        m <- language_model(f, smoother = "ml")
        
        check <- function(input, expected) 
                expect_equal(probability(input, m), expected)
                
        input <- c("a", "b") %|% c("a a")
        expected <- c(0.5, 0.5)
        check(input, expected)
        
        input <- c("a", "b") %|% c("a")
        expected <- c(0.5, 0.5)
        check(input, expected)
        
        input <- c("a", "b") %|% BOS()
        expected <- c(1, 0)
        check(input, expected)
        
        input <- c("a", "b") %|% "b"
        expected <- c(1/3, 1/3)
        check(input, expected)
        
        input <- c("a", "b") %|% "b b"
        expected <- c(0, 0)
        check(input, expected)
})