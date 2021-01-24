#if !defined(KGRAM_FREQS_H)
#define KGRAM_FREQS_H

// [[Rcpp::plugins(cpp11)]]

#include <string>
#include <vector>
#include <unordered_set>
#include <unordered_map>
#include "WordStream.h"
#include "CircularBuffer.h"
#include "special_tokens.h"

class kgramFreqs {
        using FrequencyTable = std::unordered_map<std::string, double>;
        
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
                
                Dictionary (const std::unordered_set<std::string> & dict) 
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
        
        };
        
        size_t N_; // Order of N-grams
        Dictionary dict_;
        std::vector<FrequencyTable> freqs_;
public:
        // Constructors
        kgramFreqs(size_t N)
                : N_(N), freqs_(N + 1) {}
        kgramFreqs(size_t N, const std::unordered_set<std::string> & dict)
                : N_(N), dict_(dict), freqs_(N + 1) {}
        
        // Store k-gram counts from sentences
        void process_sentences (const std::vector<std::string> &,
                                bool fixed_dictionary = false); 
        
        // Store k-gram counts from sentence
        void process_sentence (const std::string&, CircularBuffer<std::string>,
                               bool fixed_dictionary = false);
        
        // Member access        
        size_t N() const { return N_; }

        FrequencyTable & operator[] (size_t k) { return freqs_[k]; }
        const FrequencyTable & operator[] (size_t k) const { return freqs_[k]; }
        size_t query (std::string) const;

}; // kgramFreqs

#endif