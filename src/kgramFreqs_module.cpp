#include <Rcpp.h>
#include "kgramFreqs.h"
using namespace Rcpp;

RCPP_MODULE(kgramFreqs) {
        class_<kgramFreqs>("kgramFreqs")
        
        .constructor<size_t>()

        .method("process_sentences", &kgramFreqs::process_sentences)
        .const_method("N", &kgramFreqs::N)
        .const_method("query", &kgramFreqs::query)
        ;
}