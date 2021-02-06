# Not implemented

#' Coerce to k-gram frequency table
#' 
#' $author Valerio Gherardi
#' $md
#' 
#' $description
#' 
#' At present, this is just an utility for recovering a /code{kgram_freqs}
#' object from a /link[kgrams]{language_model}.
#' 
#' $param object object to be coerced to /code{kgram_freqs}.
#' $param ... further argument passed to or from other methods.
#' $return a /code{kgram_freqs} object.
#' $examples
#' model <- language_model( kgram_freqs("a b b a b", 3) )
#' freqs <- as_kgram_freqs(model)
#' $name as_kgram_freqs
# NULL

#' $rdname as_kgram_freqs
# as_kgram_freqs <- function(object, ...)
#         UseMethod("as_kgram_freqs", object)

#' $rdname as_kgram_freqs
#' $export
# as_kgram_freqs.language_model <- function(object, ...) {
#         cpp_obj <- attr(object, "cpp_freqs")
#         .preprocess <- attr(object, ".preprocess")
#         .tknz_sent <- attr(object, ".tknz_sent")
#         new_kgram_freqs(cpp_obj, .preprocess, .tknz_sent)
# }
