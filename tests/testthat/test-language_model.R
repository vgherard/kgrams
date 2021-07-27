test_that("new_language_model returns the desired structure", {
        # Dummy arguments, to ensure matching
        args <- list(
                cpp_obj = "obj",
                cpp_freqs = "freqs",
                .preprocess = gsub,
                .tknz_sent = identity,
                smoother = "ml"
                )
        class <- "language_model"
        
        res <- do.call(new_language_model, args)
                
        expect_s3_class(res, class)
        for (name in names(args))
                expect_identical(attr(res, name), args[[name]])
})
