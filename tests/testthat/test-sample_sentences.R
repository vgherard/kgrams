test_that("sample_sentences() returns a character of the correct length", {
        model <- language_model(kgram_freqs("a a b a b b a", 3), "add_k", k = 1)
        len <- 7
        res <- sample_sentences(model, n = len, max_length = 100)
        
        expect_vector(res, character(), len)
})
