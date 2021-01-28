#include <Rcpp.h>
#include "kgramFreqsR.h"
#include "Dictionary.h"
using namespace Rcpp;

IntegerVector kgramFreqsR::queryR(CharacterVector kgram)
{
        size_t len = kgram.length();
        IntegerVector res(len);
        for (size_t i = 0; i < len; ++i) {
                res[i] = query(as<std::string>(kgram[i]));
        }
        return res;
}

RCPP_EXPOSED_CLASS(kgramFreqs);
RCPP_EXPOSED_CLASS(Dictionary);
RCPP_EXPOSED_CLASS(DictionaryR);

RCPP_MODULE(kgramFreqs) {
        class_<kgramFreqs>("___kgramFreqs")
                .constructor<size_t>()
                .constructor<size_t, const Dictionary & >()
                .method("process_sentences", &kgramFreqs::process_sentences)
                .const_method("N", &kgramFreqs::N)
                .const_method("V", &kgramFreqs::V)
        ;
        
        class_<kgramFreqsR>("kgramFreqs")
                .derives<kgramFreqs>("___kgramFreqs")
                .constructor<size_t>()
                .constructor<size_t, const Dictionary & >()
                .method("query", &kgramFreqsR::queryR)
                .method("dictionary", &kgramFreqsR::dictionaryR)
        ;
}
