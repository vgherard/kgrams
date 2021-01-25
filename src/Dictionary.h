#ifndef DICTIONARY_H
#define DICTIONARY_H

#include <string>
#include <vector>
#include <unordered_map>
#include "special_tokens.h"

class Dictionary {
        std::unordered_map<std::string, std::string> word_to_ind_;
        std::unordered_map<std::string, std::string> ind_to_word_;
        size_t V_;
public:
        Dictionary () : V_(0) {
                word_to_ind_[BOS_TOK] = BOS_IND;
                ind_to_word_[BOS_IND] = BOS_TOK;
                word_to_ind_[EOS_TOK] = EOS_IND;
                ind_to_word_[EOS_IND] = EOS_TOK;
                word_to_ind_[UNK_IND] = UNK_TOK;
        }
        
        void insert (std::string word) {
                std::string index = std::to_string(++V_);
                word_to_ind_[word] = index;
                ind_to_word_[index] = word;
        }
        
        Dictionary (const std::vector<std::string> & dict) 
                : V_(0) {
                Dictionary();
                for (std::string word : dict) {
                        insert(word);
                }
        }
        
        bool contains_word (std::string word) const { 
                return word_to_ind_.find(word) != word_to_ind_.end();
        }
        
        std::string word (std::string index) const { 
                auto it = ind_to_word_.find(index);
                if (it != ind_to_word_.end()) return it->second;
                return UNK_TOK; 
        }
        std::string index (std::string word) const {
                auto it = word_to_ind_.find(word);
                if (it != word_to_ind_.end()) return it->second;
                return UNK_IND;
        }
        
        size_t length () const { return V_; }
        
}; // class Dictionary

#endif // DICTIONARY_H