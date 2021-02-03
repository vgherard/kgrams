#include <Rcpp.h>
#include "kgramFreqsR.h"
#include "Dictionary.h"
using namespace Rcpp;

IntegerVector kgramFreqsR::queryR(CharacterVector kgram) const
{
        size_t len = kgram.length();
        IntegerVector res(len);
        for (size_t i = 0; i < len; ++i) {
                res[i] = query(as<std::string>(kgram[i]));
                if (res[i] == -1) res[i] = NA_INTEGER;
        }
        return res;
}

/// @brief store k-gram counts from a list of sentences.
/// @param sentences Vector of strings. A list of sentences from 
/// which to store k-gram counts
/// @param fixed_dictionary true or false. If true, any new word 
/// not appearing in the dictionary encountered during processing is 
/// replaced by an Unknown-Word  token. Otherwise, new words are 
/// added to the dictionary.
/// @details Each entry of 'sentences' is considered a single sentence. 
/// For each sentence, anything separated by one or more space 
/// characters is considered a word.
void kgramFreqsR::process_sentencesR(
        CharacterVector & sentences, bool fixed_dictionary, bool verbose
        ) 
{
        add_BOS_counts(sentences.size());
        std::string sentence;
        
        size_t each = sentences.size() / 10, left = each, progress = 0;
        if (verbose) 
                Rprintf("0 / 10\n");
        auto itend = sentences.end();
        for (auto it = sentences.begin(); it != itend; ++it) {
                if (verbose and left-- == 0) {
                        left = each;
                        progress += 1;
                        Rprintf("%d / 10\n", progress);
                }
                sentence = *it;
                process_sentence(sentence, fixed_dictionary);
        }
        if (verbose) 
                Rprintf("10 / 10\n");
        update_satellites();
}

RCPP_EXPOSED_CLASS(Dictionary);
RCPP_EXPOSED_CLASS(DictionaryR);
RCPP_EXPOSED_CLASS(kgramFreqsR);

RCPP_MODULE(kgramFreqs) {
        class_<kgramFreqs>("___kgramFreqs")
                .property("N", &kgramFreqs::N)
                .property("V", &kgramFreqs::V)
        ;
        
        class_<kgramFreqsR>("kgramFreqs")
                .derives<kgramFreqs>("___kgramFreqs")
                .constructor<size_t, const Dictionary & >()
                .constructor<const kgramFreqsR & >()
                .method("process_sentences", &kgramFreqsR::process_sentencesR)
                .const_method("query", &kgramFreqsR::queryR)
                .const_method("dictionary", &kgramFreqsR::dictionaryR)
        ;
}
