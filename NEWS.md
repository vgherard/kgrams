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
