
<!-- README.md is generated from README.Rmd. Please edit that file -->

# kgrams

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CircleCI build
status](https://circleci.com/gh/vgherard/kgrams.svg?style=svg)](https://circleci.com/gh/vgherard/kgrams)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/vgherard/kgrams?branch=main&svg=true)](https://ci.appveyor.com/project/vgherard/kgrams)
[![R-CMD-check](https://github.com/vgherard/kgrams/workflows/R-CMD-check/badge.svg)](https://github.com/vgherard/kgrams/actions)
[![Codecov test
coverage](https://codecov.io/gh/vgherard/kgrams/branch/main/graph/badge.svg)](https://codecov.io/gh/vgherard/kgrams?branch=main)
<!-- badges: end -->

`kgrams` provides tools for training and evaluating k-gram language
models, including several probability smoothing methods, perplexity
computations, random text generation and more.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("vgherard/kgrams")
```

## Example

This example shows how to train a modified Kneser-Ney 4-gram model on
Shakespeare’s “Much Ado About Nothing” using `kgrams` and generate
random text from the model’s distribution.

``` r
library(kgrams)
# Get k-gram frequency counts from text, for k = 1:4
freqs <- kgram_freqs(kgrams::much_ado, N = 4)
# Build modified Kneser-Ney 4-gram model, with discount parameters D1, D2, D3.
mkn <- language_model(freqs, smoother = "mkn", D1 = 0.25, D2 = 0.5, D3 = 0.75)
```

We can now use this `language_model` to compute sentence and word
continuation probabilities:

``` r
# Compute sentence probabilities
probability(c("did he break out into tears ?",
              "we are predicting sentence probabilities ."
              ), 
            model = mkn
            )
#> [1] 2.466856e-04 1.184963e-20
# Compute word continuation probabilities
probability(c("tears", "pieces") %|% "did he break out into", model = mkn)
#> [1] 9.389238e-01 3.834498e-07
```

Here are some sentences sampled from the language model’s distribution
at temperatures `t = c(1, 0.1, 10)`:

``` r
# Compute sentence probabilities
set.seed(840)
sample_sentences(model = mkn, n = 3, max_length = 10, t = 1)
#> [1] "i have studied eight or nine truly by your office [...] (truncated output)"
#> [2] "ere you go : <EOS>"                                                        
#> [3] "don pedro welcome signior : <EOS>"
sample_sentences(model = mkn, n = 3, max_length = 10, t = 0.1)
#> [1] "i will not be sworn but love may transform me [...] (truncated output)" 
#> [2] "i will not fail . <EOS>"                                                
#> [3] "i will go to benedick and counsel him to fight [...] (truncated output)"
sample_sentences(model = mkn, n = 3, max_length = 10, t = 10)
#> [1] "july cham's incite start ancientry effect torture tore pains endings [...] (truncated output)"   
#> [2] "lastly gallants happiness publish margaret what by spots commodity wake [...] (truncated output)"
#> [3] "born all's 'fool' nest praise hurt messina build afar dancing [...] (truncated output)"
```

## Website

[website](https://vgherard.github.io/kgrams/)
