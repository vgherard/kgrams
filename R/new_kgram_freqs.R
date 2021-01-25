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