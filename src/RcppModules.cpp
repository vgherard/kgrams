#include <Rcpp.h>
#include "kgramFreqs.h"
#include "Dictionary.h"
using namespace Rcpp;

RCPP_EXPOSED_CLASS(kgramFreqs);
RCPP_EXPOSED_CLASS(Dictionary);

Rcpp::XPtr<Dictionary> get_dict_xptr(kgramFreqs & freqs) {
        // set_delete_finalizer = false, so that R doesn't try to destroy
        // the dictionary of kgramFreqs if the ptr is garbage collected
        return Rcpp::XPtr<Dictionary>(freqs.dictionary(), false);
}

RCPP_MODULE(kgramFreqs) {
        class_<kgramFreqs>("kgramFreqs")
        
        .constructor<size_t>()
        .constructor<size_t, std::vector<std::string> >()

        .method("process_sentences", &kgramFreqs::process_sentences)
        
        .const_method("N", &kgramFreqs::N)
        .const_method("V", &kgramFreqs::V)
        .const_method("query", &kgramFreqs::query)
        ;
        
        function("get_dict_xptr", &get_dict_xptr)
        ;
}
