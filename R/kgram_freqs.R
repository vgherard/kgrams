new_kgram_freqs <- function(f, N, dictionary, .preprocess, .tokenize_sentences)
{
        structure(list(),
                  N = N, 
                  dictionary = dictionary, 
                  .preprocess = .preprocess,
                  .tokenize_sentences = .tokenize_sentences,
                  cpp_obj = f,
                  class = "kgram_freqs")
}

#' @export
kgram_freqs <- function(object, 
                        N,
                        .preprocess = identity, 
                        .tokenize_sentences = identity,
                        batch_size = NULL,
                        dictionary = character(),
                        fixed_dictionary = FALSE,
                        ...
                        ) 
{
        # ...argcheck()...
        f <- new(kgramFreqs, N, dictionary)
        process <- function(batch) 
        {
                batch <- .preprocess(batch)
                batch <- .tokenize_sentences(batch)
                f$process_sentences(batch, fixed_dictionary)
        }
        UseMethod("kgram_freqs", object)
}
                

#' @export
kgram_freqs.character <- function(object, 
                                  N,
                                  .preprocess = identity, 
                                  .tokenize_sentences = identity,
                                  batch_size = NULL,
                                  dictionary = character(),
                                  fixed_dictionary = FALSE,
                                  ...
                                  )
{
        len <- length(object)
        if (is.null(batch_size)) 
                batch_size <- len
        
        start <- 1
        while (start <= len) {
                end <- min(start + batch_size - 1, len)
                process(object[start:end])
                start <- end + 1
        }
        
        new_kgram_freqs(f, N, dictionary, .preprocess, .tokenize_sentences)
}

#' @export
kgram_freqs.connection <- function(object,
                                   N,
                                   .preprocess = identity,
                                   .tokenize_sentences = identity,
                                   batch_size = NULL,
                                   dictionary = character(),
                                   fixed_dictionary = FALSE,
                                   ...
                                   )
{
        
        if (is.null(batch_size)) 
                batch_size <- -1L
        
        open(object, "r")
        while (length(batch <- readLines(object, batch_size)))
                process(batch)
        close(object)
        
        new_kgram_freqs(f, N, dictionary, .preprocess, .tokenize_sentences)
}