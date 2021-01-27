#ifndef KGRAM_FREQS_H
#define KGRAM_FREQS_H

#include <string>
#include <vector>
#include <unordered_map>
#include <utility>
#include "Dictionary.h"
#include "WordStream.h"
#include "CircularBuffer.h"
#include "special_tokens.h"

class kgramFreqs {
        // Aliases
        using FrequencyTable = std::unordered_map<std::string, double>;
        
        // Private variables
        size_t N_; // Order of N-grams
        std::vector<FrequencyTable> freqs_;
        Dictionary dict_;
        
        // Private methods
        std::pair<size_t, std::string> kgram_code (std::string) const;
public:
        // Constructors
        kgramFreqs(size_t N)
                : N_(N), freqs_(N + 1) {}
        kgramFreqs(size_t N, const std::vector<std::string> & dict)
                : N_(N), freqs_(N + 1), dict_(dict) {}
        
        // Store k-gram counts from sentences
        void process_sentences (const std::vector<std::string> &,
                                bool fixed_dictionary = false); 
        
        // Store k-gram counts from sentence
        void process_sentence (const std::string&, CircularBuffer<std::string>,
                               bool fixed_dictionary = false);
        
        // Member access        
        size_t N() const { return N_; }
        size_t V() const { return dict_.length(); }
        
        double query (std::string) const;
        bool dict_contains (std::string word) const 
                { return dict_.contains_word(word); }
        
        Dictionary * dictionary() { return &dict_; };
}; // kgramFreqs

#endif