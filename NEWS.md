# kgrams (development version)

### Software Improvements
* Extended testing and improved argument checking

### API Changes
* `verbose` arguments now default to `FALSE` 

### New features
* `as_dictionary(NULL)` now returns an empty `dictionary`.

### Bug Fixes
* Fixed bug which caused .preprocess and .tknz_sent arguments to be impossible 
to replace with `process_sentences()`.
* Fixed previously wrong defaults for `max_lines` and `batch_size` arguments in `kgram_freqs.connection()`.
* Fixed broken print method for `dictionary`.
* Fixed bug causing invalid results in `dictionary()` with batch processing and
non-trivial size constraints on vocabulary size.
