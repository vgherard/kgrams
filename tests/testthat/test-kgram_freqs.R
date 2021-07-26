test_that("process_sentences_init creates true copies", {
        f <- kgram_freqs(1)
        f_reference <- process_sentences_init(f, in_place = T)
        f_copy <- process_sentences_init(f, in_place = F)
        
        expect_identical(f, f_reference)
        expect_false(
                identical(attr(f, "cpp_obj"), attr(f_copy, "cpp_obj"))
        )
})

test_that("kgram_process_task returns a function", {
        f <- kgram_freqs(1)
        res <- kgram_process_task(
                f, 
                .preprocess = identity, 
                .tknz_sent = identity, 
                open_dict = TRUE, 
                verbose = FALSE
                )
        
        expect_true(is.function(res))
})

test_that("kgram_process_task modifies freqs in place", {
        f <- kgram_freqs(1)
        res <- kgram_process_task(
                f, 
                .preprocess = identity, 
                .tknz_sent = identity, 
                open_dict = TRUE, 
                verbose = FALSE
        )
        res("this this this")
        
        expect_equal(query(f, "this"), 3)
})

test_that("kgram_process_task correctly passes preprocessing functions", {
        f <- kgram_freqs(1)
        res <- kgram_process_task(
                f, 
                .preprocess = tolower, 
                .tknz_sent = function(x) unlist(strsplit(x, "\\.")), 
                open_dict = TRUE, 
                verbose = FALSE
        )
        res("THIS THIS. THIS.")
        
        expect_equal(query(f, "this"), 3)
        expect_equal(query(f, EOS()), 2)
})