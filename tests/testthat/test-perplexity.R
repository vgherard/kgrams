test_that("check_model_perplexity warns on correct arguments", {
        model <- list()
        
        # Warn for these smoothers:
        warning_smoothers <- c("ml", "sbo")
        for (smoother in warning_smoothers) {
                attr(model, "smoother") <- smoother
                class <- paste0(smoother, "_perplexity_warning")
                expect_warning(
                        check_model_perplexity(model),
                        class = class
                )        
        }
        
        # No warning for other smoothers
        for (smoother in smoothers()) {
                if (smoother %in% warning_smoothers)
                        next
                attr(model, "smoother") <- smoother
                expect_warning(
                        check_model_perplexity(model),
                        NA
                )        
        }
})

test_that("identical results for corresponding connection and character input", {
        model <- language_model(kgram_freqs("a a a b a b b", 3), "wb")
        
        text <- c("a a b a b c b a", "b b a b a", "c c c c")
        con <- textConnection(text)
        expect_identical(perplexity(text, model), perplexity(con, model))
})

test_that("results are correct for simple test case", {
        model <- language_model(kgram_freqs("a a a b a b b", 2), "add_k", k = 1)
        
        text <- c("a a b a b c b a")
        
        # Add_1 probabilities
        p_a_bos <- log((1 + 1) / (1 + 4))
        p_a_a <- log((2 + 1) / (4 + 4))
        p_b_a <- log((2 + 1) / (4 + 4))
        p_a_b <- log((1 + 1) / (3 + 4))
        p_unk_b <- log((0 + 1) / (3 + 4))
        p_b_unk <- log((0 + 1) / (0 + 4))
        p_eos_a <- log((0 + 1) / (4 + 4))
        
        log_prob_sent <- 
                p_eos_a + p_a_b + p_b_unk + p_unk_b + p_b_a + p_a_b + 
                p_b_a + p_a_a + p_a_bos
        n_words <- 9
        expected_perp <- exp(-log_prob_sent / n_words)
        
        expect_equal(perplexity(text, model), expected_perp)
})

