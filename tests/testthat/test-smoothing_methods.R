test_that("probabilities sum to one in simple case", {
        N <- 2
        txt <- c("a a b a b a")
        f <- kgram_freqs(txt, N, verbose = F)
        all_words <- c(as.character(dictionary(txt)), EOS(), UNK())
        contexts <- c("", "a", "b", "c", BOS(), BOS() %+% BOS(), UNK())

        for (smoother in smoothers()) {
                if (smoother %in% c("sbo", "ml")) next
                pars <- list_parameters(smoother)
                args <- sapply(pars, function(x) x$default)
                names(args) <- sapply(pars, function(x) x$name)
                FUN <- function(...) language_model(f, smoother, ...)
                model <- do.call(FUN, as.list(args))
                if (smoother == "mkn") {
                        param(model, "D1") <- 0.25
                        param(model, "D2") <- 0.5
                        param(model, "D3") <- 0.75
                }
                for (context in contexts) {
                        p <- probability(all_words %|% context, model)
                        sum_prob <- sum(p)
                        label <- smoother %+% context
                        expect_equal(sum_prob, 1, label = label)
                }
        }


})

test_that("probabilities sum to one in complex case", {
        text <- tknz_sent(much_ado)
        N <- 4
        dict <- dictionary(text)
        f <- kgram_freqs(text, N, dict = dict, verbose = F)
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
                model <- do.call(FUN, as.list(args))
                if (smoother == "mkn") {
                        param(model, "D1") <- 0.25
                        param(model, "D2") <- 0.5
                        param(model, "D3") <- 0.75
                }
                for (i in 1:N) {
                        param(model, "N") <- i
                        for (context in contexts) {
                                p <- probability(all_words %|% context, model)
                                sum_prob <- sum(p)
                                label <- smoother %+% i %+% context %+% sum_prob
                                expect_equal(sum_prob, 1, label = label)
                        }
                }
        }

})

test_that("Correct probabilities in simple case", {
        N <- 2
        f <- kgram_freqs(c("a a b a b a"), N, verbose = F)
        models <- sapply(smoothers(), function(smoother) {
                pars <- list_parameters(smoother)
                args <- sapply(pars, function(x) x$default)
                names(args) <- sapply(pars, function(x) x$name)
                FUN <- function(...) language_model(f, smoother, ...)
                do.call(FUN, as.list(args))
                })

        param(models[["mkn"]], "D1") <- 0.25
        param(models[["mkn"]], "D2") <- 0.5
        param(models[["mkn"]], "D3") <- 0.75
        
        with(list(wc = "a" %|% "b"), {

                expect_equal(1, probability(wc, models[["ml"]]))
                expect_equal(0.5, probability(wc, models[["add_k"]]))
                expect_equal(
                        (2 - 0.75) / 2 + 0.75 * 1 / 2 *
                                ((4 - 0.75) / 7 + 0.75 * 3 / 7 * 1 / 4
                                 ),
                        probability(wc, models[["abs"]])
                )
                expect_equal(
                        (2 - 0.75) / 2 + 0.75 * 1 / 2 *
                                ((3 - 0.75) / 5 + 0.75 * 3 / 5 * 1 / 4
                                ),
                        probability(wc, models[["kn"]])
                )
                expect_equal(
                        (2 - 0.5) / 2 + (0.5) / 2 *
                                ((3 - 0.75) / 5 + (2 * 0.25 + 0.75) / 5 * 1 / 4
                                ),
                        probability(wc, models[["mkn"]])
                )
                
                expect_equal(1, probability(wc, models[["sbo"]]))
                expect_equal(
                        (2 + 1 * (4 + 3 * 1 / 4) / (7 + 3) ) / (2 + 1),
                        probability(wc, models[["wb"]]),
                        label = c(probability(wc, models[["wb"]]))
                        )
        })
        
        with(list(wc = "a" %|% BOS()), {
                
                expect_equal(1, probability(wc, models[["ml"]]))
                expect_equal(0.4, probability(wc, models[["add_k"]]))
                expect_equal(
                        (1 - 0.75) / 1 + 0.75 * 1 / 1 *
                                ((4 - 0.75) / 7 + 0.75 * 3 / 7 * 1 / 4
                                ),
                        probability(wc, models[["abs"]])
                )
                expect_equal(
                        (1 - 0.75) / 1 + 0.75 * 1 / 1 *
                                ((3 - 0.75) / 5 + 0.75 * 3 / 5 * 1 / 4
                                ),
                        probability(wc, models[["kn"]])
                )
                expect_equal(
                        (1 - 0.25) / 1 + 0.25 / 1 *
                                ((3 - 0.75) / 5 + (2 * 0.25 + 0.75) / 5 * 1 / 4
                                ),
                        probability(wc, models[["mkn"]])
                )
                expect_equal(1, probability(wc, models[["sbo"]]))
                expect_equal(
                        (1 + 1 * (4 + 3 * 1 / 4) / (7 + 3) ) / (1 + 1),
                        probability(wc, models[["wb"]]),
                        label = c(probability(wc, models[["wb"]]))
                )
        })


})