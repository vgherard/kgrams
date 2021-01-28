#ifndef KGRAM_FREQS_R_H
#define KGRAM_FREQS_R_H

#include <Rcpp.h>
#include "kgramFreqs.h"
#include "DictionaryR.h"
using namespace Rcpp;

class kgramFreqsR : private kgramFreqs {
public:
        kgramFreqsR(size_t N) : kgramFreqs(N) {}
        kgramFreqsR(size_t N, const Dictionary & d) : kgramFreqs(N, d) {}
        
        IntegerVector queryR (CharacterVector);
        DictionaryR dictionaryR() { return DictionaryR(dictionary()); };
};

#endif