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
