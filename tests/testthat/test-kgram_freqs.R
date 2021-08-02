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

test_that("process_sentences() returns invisibly iff in place", {
        f <- kgram_freqs(1)
        expect_invisible(process_sentences("a b c", f, in_place = T))
        expect_visible(process_sentences("a b c", f, in_place = F))
})

test_that("process_sentences() processes correctly from character", {
        freqs <- kgram_freqs(1)
        txt <- c("a", "a b", "b a b a")
        process_sentences(txt, freqs)
        
        expect_equal(query(freqs, "a"), 4)
        expect_equal(query(freqs, "b"), 3)
})

test_that("process_sentences() processes correctly from open connection", {
        freqs <- kgram_freqs(1)
        txt <- textConnection(c("a", "a b", "b a b a"))
        process_sentences(txt, freqs)
        
        expect_equal(query(freqs, "a"), 4)
        expect_equal(query(freqs, "b"), 3)
})

test_that("process_sentences() processes correctly from file connection", {
        freqs <- kgram_freqs(1)
        temp <- tempfile()
        writeLines(c("a", "a b", "b a b a"), temp)
        con <- file(temp)
        process_sentences(con, freqs)
        unlink(temp)
        
        expect_equal(query(freqs, "a"), 4)
        expect_equal(query(freqs, "b"), 3)
})

test_that("kgram_freqs() processes correctly from character", {
        txt <- c("a", "a b", "b a b a")
        freqs <- kgram_freqs(txt, 1)
        
        expect_equal(query(freqs, "a"), 4)
        expect_equal(query(freqs, "b"), 3)
})

test_that("kgram_freqs() processes correctly from connection", {
        txt <- textConnection(c("a", "a b", "b a b a"))
        freqs <- kgram_freqs(txt, 1)
        
        expect_equal(query(freqs, "a"), 4)
        expect_equal(query(freqs, "b"), 3)
})

test_that("kgram_reqs class has print, str and summary methods", {
        skip_if(R.version$major < 4,
                message = "format() method of methods(..) different in R < 4"
                )
        funs <- c("print", "str", "summary")
        methods <- format(methods(class = "kgram_freqs"))
        expect_true(all(funs %in% methods))
})

test_that("print, str and summary methods return invisibly", {
        funs <- list(print, str, summary)
        freqs <- kgram_freqs(1)
        capture_output(
                for (fun in funs) {
                        expect_invisible(fun(freqs))
                        expect_identical(fun(freqs), freqs)
                })
})

test_that("new_kgram_freqs throws if 'dict' is not coercible to dictionary", {
        expect_error(new_kgram_freqs(1, dict = 840, identity, identity),
                     class = "kgrams_domain_error")
})

test_that("preprocessing error throws condition of proper class", {
        expect_error(
                kgram_freqs(
                        "This is a string", 
                        N = 2, 
                        .preprocess = stop
                        ),
                     class = "kgrams_preproc_error"
                )
})

test_that("tokenization error throws condition of proper class", {
        expect_error(
                kgram_freqs(
                        "This is a string", 
                        N = 2, 
                        .tknz_sent = stop
                ),
                class = "kgrams_tknz_sent_error"
        )
})