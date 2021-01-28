/** 
 *  @file   Dictionary.h 
 *  @brief  Definition of Dictionary class 
 *  @author Valerio Gherardi
 ***********************************************/

#ifndef DICTIONARY_H
#define DICTIONARY_H

#include <string>
#include <vector>
#include <unordered_map>
#include "special_tokens.h"
#include "WordStream.h"

/**
 *  @class Dictionary
 *  @brief Word dictionary for language models.
 *  @details This class has two main purposes: (i) store a list of "known"
 *  words to be used within a language model and (ii) provide conversions 
 *  between word and k-gram tokens and word and k-gram codes (strings of 
 *  integers), where the latters are employed in the internal implementation
 *  of kgramFreqs class.
 */
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
        
        bool contains (std::string word) const { 
                return word_to_ind_.find(word) != word_to_ind_.end();
        }
        
        void insert (std::string word) {
                if (contains(word)) return;
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
        
        /**
         * @brief Extract k-gram code from a string.
         * @param kgram a string. 
         * @details Automatically takes care of leading, trailing and multiple
         * spaces, recognizes the EOS token. 
         */
        std::pair<size_t, std::string> kgram_code (std::string kgram) const
        {
                std::pair<size_t, std::string> res{0, ""};
                WordStream stream(kgram);
                std::string word, ind;
                for (; ; res.first++) {
                        word = stream.pop_word();
                        if (stream.eos()) break;
                        ind = index(word);
                        
                        res.second += ind + " ";
                }
                if (res.first > 0) 
                        res.second.pop_back();
                return res;
        }
}; // class Dictionary

#endif // DICTIONARY_H
