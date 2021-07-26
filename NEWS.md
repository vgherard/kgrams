# kgrams (development version)

### Improvements
* Extended testing and improved argument checking

### Bug Fixes
* Fixed bug which caused .preprocess and .tknz_sent arguments to be impossible 
to replace with `process_sentences()`.
* Fixed previously wrong defaults for `max_lines` and `batch_size` arguments in `kgram_freqs.connection()`.

### New features
* `as_dictionary(NULL)` now returns an empty `dictionary`.
