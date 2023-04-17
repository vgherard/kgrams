# kgrams 0.1.5

* Removed "Tools for..." at the beginning of package DESCRIPTION, as per CRAN's 
request.
* Simplified examples in `?kgram_freqs`.

# kgrams 0.1.4

* Updated `R` requirements `3.5 -> 4.0`.
* Removed `SystemRequirements: C++11` (see [this tidyverse blog post](https://www.tidyverse.org/blog/2023/03/cran-checks-compiled-code/#note-regarding-systemrequirements-c11))

# kgrams 0.1.3

* Remove dependency from external online sources in vignette.

# kgrams 0.1.2

### Overall Software Improvements
* The package's test suite has been greatly extended.
* Improved error/warning conditions for wrong arguments.
* Re-enabled compiler diagnostics as per CRAN policy (#19)

### API Changes
* `verbose` arguments now default to `FALSE`.
* `probability()`, `perplexity()` and `sample_sentences()` are restricted to
accept only `language_model` class objects as their `model` argument.

### New features
* `as_dictionary(NULL)` now returns an empty `dictionary`.

### Bug Fixes
* Fixed bug causing `.preprocess` and `.tknz_sent` arguments to be ignored in `process_sentences()`.
* Fixed previously wrong defaults for `max_lines` and `batch_size` arguments in `kgram_freqs.connection()`.
* Added print method for class `dictionary`.
* Fixed bug causing invalid results in `dictionary()` with batch processing and
non-trivial size constraints on vocabulary size.

### Other
* Maintainer's email updated
