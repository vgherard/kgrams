#include "Utilities.h"
#include <Rcpp.h>
using namespace Rcpp;

RCPP_MODULE(Utilities) {
        CharacterVector (*tokenize_sentences_R) 
                (CharacterVector, std::string, bool) = & tokenize_sentences;
                function("tokenize_sentences_cpp", tokenize_sentences_R);
                function("preprocess_cpp", &preprocess);
}