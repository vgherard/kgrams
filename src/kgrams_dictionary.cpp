#include "Dictionary.h"
#include "kgramFreqs.h"
#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
void dict_insert(Dictionary & dict, Rcpp::CharacterVector text, size_t thresh) 
{
        std::unordered_map<std::string, size_t> counts;
        std::string word;
        for (SEXP line : text) {
                WordStream ws(Rcpp::as<std::string>(line));
                while ((word = ws.pop_word()) != EOS_TOK) {
                        if (dict.contains_word(word))
                                continue;
                        counts[word]++;
                        if (counts[word] > thresh) 
                                dict.insert(word);
                }
        }
} 

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