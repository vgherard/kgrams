test_that("probabilities sum to one in simple case", {
        f <- kgram_freqs(c("a a b a b a !",
                           " b c b a b a .",
                           "a c b b b a"), 3, verbose = F)
        all_words <- c("a", "b", "c", "!", ".", EOS(), UNK())
        contexts <- c("", "a", "b", "c", BOS(), BOS() %+% BOS(), UNK())

        for (smoother in smoothers()) {
                if (smoother %in% c("sbo", "ml")) next
                pars <- list_parameters(smoother)
                args <- sapply(pars, function(x) x$default)
                names(args) <- sapply(pars, function(x) x$name)
                FUN <- function(...) language_model(f, smoother, ...)
                model <- do.call(FUN, as_list(args))
                for (context in contexts) {
                        p <- probability(all_words %|% context, model)
                        sum_prob <- sum(p)
                        label <- smoother %+% context
                        expect_equal(sum_prob, 1, label = label)
                }
        }


})

test_that("probabilities sum to one in complex case", {
        text <- tokenize_sentences(much_ado)
        N <- 3
        dict <- dictionary(text)
        f <- kgram_freqs(text, 3, dictionary = dict, verbose = F)
        all_words <- c(as.character(dict), EOS(), UNK())

        contexts <- c("",
                      "enter",
                      "enter leonato",
                      BOS(),
                      BOS() %+% BOS(),
                      UNK(),
                      UNK() %+% UNK()
                      )

        for (smoother in smoothers()) {
                if (smoother %in% c("sbo", "ml")) next
                pars <- list_parameters(smoother)
                args <- sapply(pars, function(x) x$default)
                names(args) <- sapply(pars, function(x) x$name)
                FUN <- function(...) language_model(f, smoother, ...)
                model <- do.call(FUN, as_list(args))
                for (i in 1:N) {
                        param(model, "N") <- i
                        for (context in contexts) {
                                p <- probability(all_words %|% context, model)
                                sum_prob <- sum(p)
                                label <- smoother %+% N %+% context %+% sum_prob
                                expect_equal(sum_prob, 1, label = label)
                        }
                }
        }

})
