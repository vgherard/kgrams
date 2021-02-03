/// @file   kgramFreqs.h 
/// @brief  Definition of kgramFreqs class 
/// @author Valerio Gherardi

#ifndef KGRAM_FREQS_H
#define KGRAM_FREQS_H

#include <string>
#include <vector>
#include <unordered_map>
#include <utility>
#include <stdexcept>
#include "Dictionary.h"
#include "WordStream.h"
#include "CircularBuffer.h"
#include "special_tokens.h"
#include "Satellite.h"

/// @class kgramFreqs
/// @brief Store k-gram frequency counts in hash tables 

class kgramFreqs {
        //--------Aliases--------//
        /// k-gram frequency table type
        using FrequencyTable = std::unordered_map<std::string, size_t>;
        
        //--------Private variables--------//
        size_t N_; ///< Maximum order of k-grams to be considered
        
        /// @brief k-gram frequency tables.
        /// @details For 1 <= k <= N_, freqs_[k] is an hash-table containing 
        /// k-gram counts. Keys of hash tables are strings of the form 
        /// "$X1 $X2 ... $Xk", where "$Xi" is an integer corresponding to the
        /// position of word 'i' in the model's Dictionary. freqs_[0] has a 
        /// single key: "", whose value corresponds to the sum of all single word
        /// counts. The word->index and index->word conversions are provided by 
        /// the Dictionary member dict_, see below.
        std::vector<FrequencyTable> freqs_;
        
        /// @brief Dictionary of the k-gram model.
        /// @details The dictionary has two basic purposes: 
        /// identify unknown word (to be replaced with an "UNK" token), 
        /// and provide integer codes for known words. 
        Dictionary dict_;
        
        /// @brief Begin-Of-Sentence padding
        const CircularBuffer<std::string> padding_;
        //--------Private methods--------//
        
        /// @brief k-gram frequency satellites
        /// @details Objects which should be updated after new sentences are
        /// processed (e.g. continuation counts of Kneser-Ney smoother)
        std::vector<Satellite *> satellites_;
        
        /// @brief Initialize a buffer of prefixes for processing sentences
        CircularBuffer<std::string> generate_padding();
        
protected:
        /// @brief Increase counts for <BOS>, <BOS> <BOS>, etc. by n
        void add_BOS_counts(size_t);
        
        /// @brief Get k-gram counts from sentence.
        /// The 'prefixes' buffer is supposed to be passed by value from the
        /// public method process_sentences(), in order to reinitialize it to 
        // <BOS> <BOS> ... <BOS> at the start of each iteration (sentence)
        void process_sentence (const std::string &, 
                               bool fixed_dictionary = false
        ); // kgramFreqs.cpp
        
        void update_satellites() 
        { for (auto satellite : satellites_) satellite->update();}
        
public:
        //--------Constructors--------//
        
        /// @brief Constructor with empty dictionary
        /// @param N Positive integer. Maximum order of k-grams to be considered.
        /// @details Constructs a kgramFreqs object of order N with an empty 
        /// dictionary.
        kgramFreqs(size_t N)
                : N_(N), freqs_(N + 1), padding_(generate_padding()) 
                { freqs_[0][""] = 0; }
        
        /// @brief Constructor with predefined dictionary
        /// @param N     Positive integer. Maximum order of k-grams to be 
        ///              considered.
        /// @param dict  a list of strings (words) to be included in the 
        ///              dictionary.
        kgramFreqs(size_t N, const std::vector<std::string> & dict)
                : kgramFreqs(N) { dict_ = Dictionary(dict); }
        
        /// @brief Constructor with predefined dictionary
        /// @param N     Positive integer. Maximum order of k-grams to be 
        ///              considered.
        /// @param dict  a Dictionary.
        kgramFreqs(size_t N, const Dictionary & dict)
                : kgramFreqs(N) { dict_ = Dictionary(dict); }
        
        /// @brief Copy constructor dropping satellites
        /// @param other a kgramFreqs object
        kgramFreqs(const kgramFreqs & other)
                : N_(other.N_), 
                  freqs_(other.freqs_), 
                  dict_(other.dict_),
                  padding_(other.padding_), 
                  satellites_(0)
        {}
        
        //--------Process k-gram counts--------//
        /// @brief store k-gram counts from a list of sentences.
        /// @param sentences Vector of strings. A list of sentences from 
        /// which to store k-gram counts
        /// @param fixed_dictionary true or false. If true, any new word 
        /// not appearing in the dictionary encountered during processing is 
        /// replaced by an Unknown-Word  token. Otherwise, new words are 
        /// added to the dictionary.
        /// @details Each entry of 'sentences' is considered a single sentence. 
        /// For each sentence, anything separated by one or more space 
        /// characters is considered a word.
        void process_sentences(const std::vector<std::string> & sentences,
                               bool fixed_dictionary = false);
        
        //--------Query k-grams and words--------//
        // Get k-gram counts
        double query (std::string) const; // kgramFreqs.cpp
        
        /// @brief Check if a word is found in the dictionary.
        /// @param word a string. Word to be queried.
        /// @return true or false.
        bool dict_contains (std::string word) const
                { return dict_.contains(word); }
        
        /// @brief Return word from dictionary.
        /// @param index a string.
        /// @return a string.
        std::string word (std::string index) const { return dict_.word(index); }
        
        /// @brief Return index of word from dictionary.
        /// @param word a string.
        /// @return a string.
        std::string index (std::string word) const { return dict_.index(word); }
        
        /// @brief Return k-gram code from dictionary.
        /// @param kgram a string.
        /// @return a string.
        std::pair<size_t, std::string> kgram_code (std::string kgram) const 
                { return dict_.kgram_code(kgram); }
        
        /// @brief Maximum order of k-grams.
        /// @return A positive integer N, the maximum order of k-grams for which
        /// frequency counts can be stored.
        size_t N() const { return N_; }

        /// @brief Dictionary size.
        /// @return A positive integer V. Size of the dictionary,
        /// excluding the Begin-Of-Sentence, End-Of-Sentence and Unknown word
        /// tokens.
        size_t V() const { return dict_.length(); }
        
        /// @brief total words seen in training
        size_t tot_words() const { return freqs_[0].at(""); }
        
        /// @brief return number of unique k-grams
        /// @param k a positive integer
        size_t unique(size_t k) const  { 
                if (k > N_) {
                        throw std::domain_error(
                                "'k' must be less than or equal to the maximum "
                                "order of k-grams considered.");               
                }
                return freqs_[k].size(); 
        }
        
        const FrequencyTable & operator[] (size_t k) const { return freqs_[k]; }
        
        void add_satellite(Satellite * s) { satellites_.push_back(s); }
        
        /// @brief Return Dictionary.
        Dictionary dictionary() const { return dict_; };
}; // kgramFreqs

#endif // KGRAM_FREQS_H
