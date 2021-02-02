#ifndef DICTIONARY_R_H
#define DICTIONARY_R_H

#include "Dictionary.h"
#include <queue>
#include <algorithm>
#include <Rcpp.h>

class DictionaryR : public Dictionary {
        struct WordCount {
                std::string word;
                size_t count;
                WordCount (std::string w, size_t c) : word(w), count(c) {}
                WordCount & operator++() { count++; return *this; }
                friend bool operator< (const WordCount & l, const WordCount & r) 
                {
                        if (l.count != r.count) return l.count < r.count; 
                        else return l.word > r.word;         
                }
        };
        
        double make_word_heap(Rcpp::CharacterVector, std::vector<WordCount> &);
        
public:
        DictionaryR () : Dictionary() {}
        DictionaryR (Rcpp::CharacterVector word_list) 
                : Dictionary() { insertR(word_list); }
        DictionaryR (const Dictionary & dict) : Dictionary(dict) {}
        
        Rcpp::CharacterVector as_character() const;
        
        Rcpp::LogicalVector query(Rcpp::CharacterVector word) const;
        
        void insertR (Rcpp::CharacterVector word_list);
        void insert_cover(Rcpp::CharacterVector text, double target);
        void insert_n(Rcpp::CharacterVector text, size_t n);
        void insert_above(Rcpp::CharacterVector text, size_t thresh);
};

#endif
