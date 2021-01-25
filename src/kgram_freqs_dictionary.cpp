#include "Dictionary.h"
#include "kgramFreqs.h"
#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
LogicalVector find_cpp(XPtr<Dictionary> xptr, CharacterVector words) 
{
        size_t len = words.length();
        LogicalVector res(len);
        for (size_t i = 0; i < len; ++i) {
                res[i] = xptr->contains_word(as<std::string>(words[i]));
        }
        return res;
}

// [[Rcpp::export]]
size_t length_kgrams_dictionary(XPtr<Dictionary> xptr) 
{
        return xptr->length();
}