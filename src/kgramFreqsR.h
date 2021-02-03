#ifndef KGRAM_FREQS_R_H
#define KGRAM_FREQS_R_H

#include <Rcpp.h>
#include "kgramFreqs.h"
#include "DictionaryR.h"
using namespace Rcpp;

class kgramFreqsR : public kgramFreqs {
public:
        kgramFreqsR(size_t N) : kgramFreqs(N) {}
        kgramFreqsR(size_t N, const Dictionary & dict) : kgramFreqs(N, dict) {}
        
        //--------Process k-gram counts--------//
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
        void process_sentencesR(
                CharacterVector & sentences, 
                bool fixed_dictionary = false,
                bool verbose = false
        );
        
        IntegerVector queryR (CharacterVector) const;
        DictionaryR dictionaryR() const { return DictionaryR(dictionary()); };
};

#endif