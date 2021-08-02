#include "DictionaryR.h"
#include <queue>
#include <algorithm>
#include <Rcpp.h>
using namespace Rcpp;

CharacterVector DictionaryR::as_character() const {
        size_t V = length();
        CharacterVector res(V);
        for(size_t i = 1; i <= V; ++i)
                res[i - 1] = word(std::to_string(i));
        return res;
}

LogicalVector DictionaryR::query(CharacterVector word) const
{
        size_t len = word.length();
        LogicalVector res(len);
        for (size_t i = 0; i < len; ++i) {
                res[i] = contains(as<std::string>(word[i]));
        }
        return res;
}

void DictionaryR::insertR(CharacterVector word_list)
{
        std::string str;
        for (String word : word_list) {
                str = word;
                insert(str);       
        } 
}

RCPP_EXPOSED_CLASS(Dictionary);
RCPP_EXPOSED_CLASS(DictionaryR);

RCPP_MODULE(Dictionary) {
        class_<Dictionary>("___Dictionary")
                .constructor()
                .const_method("length", &Dictionary::length)
        ;
        
        class_<DictionaryR>("Dictionary")
                .derives<Dictionary>("___Dictionary")
                .constructor()
                .constructor<CharacterVector>()
                .const_method("as_character", &DictionaryR::as_character)
                .const_method("query", &DictionaryR::query)
                .method("insert", &DictionaryR::insertR)
        ;
}
