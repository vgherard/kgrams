/// @file   Dictionary.h 
/// @brief  Definition of Dictionary class 
/// @author Valerio Gherardi

#ifndef DICTIONARY_H
#define DICTIONARY_H

#include "special_tokens.h"
#include "WordStream.h"
#include <string>
#include <vector>
#include <unordered_map>


/// @class Dictionary
/// @brief Word dictionary for language models.
/// @details This class has two main purposes: (i) store a list of "known"
/// words to be used within a language model and (ii) provide conversions 
/// between word and k-gram tokens and word and k-gram codes (strings of 
/// integers), where the latters are employed in the internal implementation
/// of kgramFreqs class.
class Dictionary {
        //--------Private elements--------//
        /// @brief Word-to-index map
        std::unordered_map<std::string, std::string> word_to_ind_;
        /// @brief Index-to-word map
        std::unordered_map<std::string, std::string> ind_to_word_;
        /// @brief Size of dictionary (without BOS, EOS and UNK tokens)
        size_t V_;
        
        //--------Private elements--------//
        void insert_special_tokens() {
                word_to_ind_[BOS_TOK] = BOS_IND;
                ind_to_word_[BOS_IND] = BOS_TOK;
                word_to_ind_[EOS_TOK] = EOS_IND;
                ind_to_word_[EOS_IND] = EOS_TOK;
                // UNK_TOK is not added as a key in Word-to-Index map, see 
                // contains() method below
                ind_to_word_[UNK_IND] = UNK_TOK;
        }
        
public:
        //--------Constructors--------//

        /// @brief Default constructor.
        /// @details Only special tokens (BOS, EOS, UNK) are included in the 
        /// dictionary.
        Dictionary () : V_(0) { insert_special_tokens(); }

        /// @brief Initialize Dictionary from list of words.
        /// @param dict A vector of strings. List of words to be included in the
        /// dictionary.
        /// @details In addition to the words explicitly included, the 
        /// constructor also adds the special tokens (BOS, EOS, UNK) to the 
        /// dictionary.
        Dictionary (const std::vector<std::string> & dict) 
                : Dictionary() { for (std::string word : dict) insert(word); }
        
        /// @brief Check if a word is contained in the Dictionary
        /// @param word A string.
        /// @return true if the word is contained in the Dictionary, false 
        /// otherwise.
        bool contains (std::string word) const { 
                return word_to_ind_.find(word) != word_to_ind_.end();
        }
        
        /// @brief Insert a word in the Dictionary
        /// @param word A string.
        void insert (std::string word) {
                if (contains(word)) return;
                std::string index = std::to_string(++V_);
                word_to_ind_[word] = index;
                ind_to_word_[index] = word;
        }
        
        /// @brief Return the word corresponding to a given word index.
        /// @param index A string.
        /// @return A string, word corresponding to 'index'.
        std::string word (std::string index) const { 
                auto it = ind_to_word_.find(index);
                if (it != ind_to_word_.end()) return it->second;
                return UNK_TOK; 
        }
        
        /// @brief Return the index corresponding to a given word.
        /// @param word A string.
        /// @return A string, index corresponding to 'word'.
        std::string index (std::string word) const {
                auto it = word_to_ind_.find(word);
                if (it != word_to_ind_.end()) return it->second;
                return UNK_IND;
        }
        
        /// @brief Return size of the dictionary, excluding the special tokens
        /// (BOS, EOS, UNK).
        /// @return A positive integer. Size of the dictionary.
        size_t length () const { return ind_to_word_.size() - 3; }

        /// @brief Return size of the dictionary, excluding the special tokens
        /// (BOS, EOS, UNK).
        /// @return A positive integer. Size of the dictionary.
        size_t size () const { return length(); }
        
        /// @brief Extract k-gram code from a string.
        /// @param kgram a string. 
        /// @return A pair of a positive integer and a string. 
        /// The integer is the order of the input k-gram (i.e. 'k'), while the
        /// string is its code, obtained by pasting the individual word codes 
        /// separated by a space.
        /// @details Automatically takes care of leading, trailing and multiple
        /// spaces, recognizes the EOS token. 
        std::pair<size_t, std::string> kgram_code (std::string kgram) const
        {
                std::pair<size_t, std::string> res{0, ""};
                WordStream stream(kgram);
                std::string word, ind;
                for (; ; res.first++) {
                        word = stream.pop_word();
                        if (stream.eos()) 
                                break;
                        ind = index(word);
                        res.second += ind + " ";
                }
                if (res.first > 0) 
                        res.second.pop_back();
                return res;
        }
}; // class Dictionary

#endif // DICTIONARY_H
