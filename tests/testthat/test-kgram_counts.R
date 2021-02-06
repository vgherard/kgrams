test_that("Correct k-gram counts in simple case: 1", {
        txt <- c("a b b a", "b a b b", "b a b a")
        f <- kgram_freqs(txt, 2, verbose = F)
        
        
        unigrams <- c("a", "b", BOS(), EOS(), UNK())
        bigrams <- outer(unigrams, unigrams, "%+%")
        test <- vector("integer", 1 + length(unigrams) + length(bigrams))
        names(test)[[1]] <- ""
        names(test)[1 + seq_along(unigrams)] <- unigrams
        names(test)[1 + length(unigrams) + seq_along(bigrams)] <- bigrams
        
        test[[1]] <- 15
        test["a"] <- 5
        test["b"] <- 7
        test[BOS()] <- 3 # Stored for a 2-gram model
        test[EOS()] <- 3
        test[UNK()] <- 0
        test["a" %+% "a"] <- 0
        test["a" %+% "b"] <- 3
        test["a" %+% BOS()] <- 0
        test["a" %+% EOS()] <- 2
        test["a" %+% UNK()] <- 0
        test["b" %+% "a"] <- 4
        test["b" %+% "b"] <- 2
        test["b" %+% BOS()] <- 0
        test["b" %+% EOS()] <- 1
        test["b" %+% UNK()] <- 0
        test[BOS() %+% "a"] <- 1
        test[BOS() %+% "b"] <- 2
        test[BOS() %+% BOS()] <- 0 # Only stored if 3-gram model
        test[BOS() %+% EOS()] <- 0
        test[BOS() %+% UNK()] <- 0
        test[EOS() %+% "a"] <- 0
        test[EOS() %+% "b"] <- 0
        test[EOS() %+% BOS()] <- 0
        test[EOS() %+% EOS()] <- 0
        test[EOS() %+% UNK()] <- 0
        test[UNK() %+% "a"] <- 0
        test[UNK() %+% "b"] <- 0
        test[UNK() %+% BOS()] <- 0
        test[UNK() %+% EOS()] <- 0
        test[UNK() %+% UNK()] <- 0
        
        actual <- query(f, names(test))
        expected <- as.integer(test)
        
        expect_identical(actual, expected)
})

test_that("Correct k-gram counts in simple case: 2", {
        txt <- c("a b c a", "b a b c", "b c b a")
        f <- kgram_freqs(txt, 2, dict = c("a", "b"), verbose = F) # 'c' is UNK
        
        unigrams <- c("a", "b", BOS(), EOS(), UNK())
        bigrams <- outer(unigrams, unigrams, "%+%")
        test <- vector("integer", 1 + length(unigrams) + length(bigrams))
        names(test)[[1]] <- ""
        names(test)[1 + seq_along(unigrams)] <- unigrams
        names(test)[1 + length(unigrams) + seq_along(bigrams)] <- bigrams
        
        test[[1]] <- 15
        test["a"] <- 4
        test["b"] <- 5
        test[BOS()] <- 3 # Stored for a 2-gram model
        test[EOS()] <- 3
        test[UNK()] <- 3
        test["a" %+% "a"] <- 0
        test["a" %+% "b"] <- 2
        test["a" %+% BOS()] <- 0
        test["a" %+% EOS()] <- 2
        test["a" %+% UNK()] <- 0
        test["b" %+% "a"] <- 2
        test["b" %+% "b"] <- 0
        test["b" %+% BOS()] <- 0
        test["b" %+% EOS()] <- 0
        test["b" %+% UNK()] <- 3
        test[BOS() %+% "a"] <- 1
        test[BOS() %+% "b"] <- 2
        test[BOS() %+% BOS()] <- 0 # Only stored if 3-gram model
        test[BOS() %+% EOS()] <- 0
        test[BOS() %+% UNK()] <- 0
        test[EOS() %+% "a"] <- 0
        test[EOS() %+% "b"] <- 0
        test[EOS() %+% BOS()] <- 0
        test[EOS() %+% EOS()] <- 0
        test[EOS() %+% UNK()] <- 0
        test[UNK() %+% "a"] <- 1
        test[UNK() %+% "b"] <- 1
        test[UNK() %+% BOS()] <- 0
        test[UNK() %+% EOS()] <- 1
        test[UNK() %+% UNK()] <- 0
        
        actual <- query(f, names(test))
        expected <- as.integer(test)
        
        expect_identical(actual, expected)
})