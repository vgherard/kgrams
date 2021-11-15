
<!-- README.md is generated from README.Rmd. Please edit that file -->

# kgrams

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/vgherard/kgrams/workflows/R-CMD-check/badge.svg)](https://github.com/vgherard/kgrams/actions)
[![Codecov test
coverage](https://codecov.io/gh/vgherard/kgrams/branch/main/graph/badge.svg)](https://app.codecov.io/gh/vgherard/kgrams?branch=main)
[![CRAN
status](https://www.r-pkg.org/badges/version/kgrams)](https://CRAN.R-project.org/package=kgrams)
[![R-universe
status](https://vgherard.r-universe.dev/badges/kgrams)](https://vgherard.r-universe.dev/)
[![Website](https://img.shields.io/badge/Website-here-blue)](https://vgherard.github.io/kgrams/)
[![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=%7Bkgrams%7D:%20Classical%20k-gram%20Language%20Models&url=https://github.com/vgherard/kgrams&via=ValerioGherardi&hashtags=rstats,MachineLearning,NaturalLanguageProcessing)
<!-- badges: end -->

[`kgrams`](https://vgherard.github.io/kgrams/) provides tools for
training and evaluating *k*-gram language models, including several
probability smoothing methods, perplexity computations, random text
generation and more. It is based on an C++ back-end which makes `kgrams`
fast, coupled with an accessible R API which aims at streamlining the
process of model building, and can be suitable for small- and
medium-sized NLP experiments, baseline model building, and for
pedagogical purposes.

## For beginners

If you have no idea about what *k*-gram models are *and* didn’t get here
by accident, you can check out my hands-on [tutorial post on *k*-gram
language
models](https://datascienceplus.com/an-introduction-to-k-gram-language-models-in-r/)
using R at [DataScience+](https://datascienceplus.com/).

## Installation

#### Released version

You can install the latest release of `kgrams` from
[CRAN](https://CRAN.R-project.org/package=kgrams) with:

``` r
install.packages("kgrams")
```

#### Development version

You can install the development version from [my
R-universe](https://vgherard.r-universe.dev/) with:

``` r
install.packages("kgrams", repos = "https://vgherard.r-universe.dev/")
```

## Example

This example shows how to train a modified Kneser-Ney 4-gram model on
Shakespeare’s play “Much Ado About Nothing” using `kgrams`.

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
# Sample sentences from the language model at different temperatures
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

## Getting Help

For further help, you can consult the reference page of the `kgrams`
[website](https://vgherard.github.io/kgrams/) or [open an
issue](https://github.com/vgherard/kgrams/issues) on the GitHub
repository of `kgrams`. A vignette is available on the website,
illustrating the process of building language models in-depth.
