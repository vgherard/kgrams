test_that("process_sentences_init creates true copies", {
        f <- kgram_freqs(1)
        f_reference <- process_sentences_init(f, in_place = T)
        f_copy <- process_sentences_init(f, in_place = F)
        expect_identical(f, f_reference)
        expect_false(
                identical(attr(f, "cpp_obj"), attr(f_copy, "cpp_obj"))
        )
})
