test_that("query.kgram_freqs returns an integer of same length of input", {
        f <- kgram_freqs("a a a b a b b", 3)
        x <- c("a", "b", "a a", "a b", "b a", "b b")
        expect_vector(query(f, x), integer(), length(x))
})

test_that("query.kgram_freqs char(0) corner case", {
        f <- kgram_freqs("a a a b a b b", 3)
        x <- character()
        expect_identical(query(f, x), integer())
})

test_that("query.kgram_freqs NA corner case", {
        f <- kgram_freqs("a a a b a b b", 3)
        expect_error(query(f, NA), class = "kgrams_domain_error")
})

test_that("query.kgram_freqs on \"\" returns total words including EOS and UNK", 
          {
                  f <- kgram_freqs("a a a b a b b", 3)
                  expect_equal(query(f, ""), 8)
                  
                  f <- kgram_freqs("a c c b a b b", 3, dict = c("a", "b"))
                  expect_equal(query(f, ""), 8)
          })

test_that("query.kgram_freqs returns correct counts in simple case", 
          {
                  f <- kgram_freqs("a a a b a b b", 3)
                  x <- c("a", "b", "a a", "a b", "b a", "b b")
                  
                  actual <- query(f, x)
                  expected <- c(4, 3, 2, 2, 1, 1)
                  
                  expect_equal(actual, expected)
          })

test_that("query.kgram_freqs and [.kgram_freqs agree on simple case", {
        f <- kgram_freqs("a a a b a b b", 3)
        x <- c("a", "b", "a a", "a b", "b a", "b b")
        
        actual <- f[x]
        expected <- c(4, 3, 2, 2, 1, 1)
        
        expect_equal(actual, expected)
})

test_that("[.kgram_freqs throws error on NA input", {
        f <- kgram_freqs("a a a b a b b", 3)
        expect_error(f[NA], class = "kgrams_domain_error")
})