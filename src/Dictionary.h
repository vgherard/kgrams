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
        void insert_special_tokens() {
                word_to_ind_[BOS_TOK] = BOS_IND;
                ind_to_word_[BOS_IND] = BOS_TOK;
                word_to_ind_[EOS_TOK] = EOS_IND;
                ind_to_word_[EOS_IND] = EOS_TOK;
                
                ind_to_word_[UNK_IND] = UNK_TOK;
        }
public:
        Dictionary () : V_(0) { insert_special_tokens(); }
        Dictionary (const std::vector<std::string> & dict) 
                : Dictionary() { for (std::string word : dict) insert(word); }
        
        bool contains_word (std::string word) const { 
                return word_to_ind_.find(word) != word_to_ind_.end();
        }
        
        void insert (std::string word) {
                if (contains_word(word)) return;
                std::string index = std::to_string(++V_);
                word_to_ind_[word] = index;
                ind_to_word_[index] = word;
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
        
        size_t length () const { return ind_to_word_.size() - 3; }
        
}; // class Dictionary

#endif // DICTIONARY_H