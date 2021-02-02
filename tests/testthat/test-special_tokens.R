test_that("tokens are length one character vectors", {
        expect_type(BOS(), typeof(character()))
        expect_length(BOS(), 1L)
        
        expect_type(EOS(), typeof(character()))
        expect_length(EOS(), 1L)
        
        expect_type(UNK(), typeof(character()))
        expect_length(UNK(), 1L)
})
