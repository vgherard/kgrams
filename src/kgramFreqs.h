/// @file   kgramFreqs.h 
/// @brief  Definition of kgramFreqs class 
/// @author Valerio Gherardi

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
        const CircularBuffer<std::string> padding_;
        //--------Private methods--------//

        /// @brief Get k-gram counts from sentence.
        /// The 'prefixes' buffer is supposed to be passed by value from the
        /// public method process_sentences(), in order to reinitialize it to 
        // <BOS> <BOS> ... <BOS> at the start of each iteration (sentence)
        void process_sentence (const std::string &, 
                               bool fixed_dictionary = false
                                       ); // kgramFreqs.cpp
        CircularBuffer<std::string> generate_padding(size_t N) {
                CircularBuffer<std::string> res(N, "");
                for (int k = 0; k < N; ++k) {
                        std::string padding = "";
                        for (size_t j = 0; j < k; ++j) {
                                padding += BOS_IND + " ";
                        }
                        res.write(padding);
                        res.lshift();
                }
                return res;
        }
public:
        //--------Constructors--------//
        
        /// @brief Constructor with empty dictionary
        /// @param N Positive integer. Maximum order of k-grams to be considered.
        /// @details Constructs a kgramFreqs object of order N with an empty 
        /// dictionary.
        kgramFreqs(size_t N)
                : N_(N), freqs_(N + 1), padding_(generate_padding(N)) {}
        
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
        
        //--------Process k-gram counts--------//
        void process_sentences (const std::vector<std::string> &,
                                bool fixed_dictionary = false
        ); // kgramFreqs.cpp 
        
        //--------Query k-grams and words--------//
        // Get k-gram counts
        double query (std::string) const; // kgramFreqs.cpp
        
        
        /// @brief Check if a word is found in the dictionary.
        /// @param word  a string. Word to be queried.
        /// @return true or false.
        bool dict_contains (std::string word) const
                { return dict_.contains(word); }
        
        /// @brief Maximum order of k-grams.
        /// @return A positive integer N, the maximum order of k-grams for which
        /// frequency counts can be stored.
        size_t N() const { return N_; }

        /// @brief Dictionary size.
        /// @return A positive integer V. Size of the dictionary,
        /// excluding the Begin-Of-Sentence, End-Of-Sentence and Unknown word
        /// tokens.
        size_t V() const { return dict_.length(); }
        
        /// @brief Return Dictionary.
        Dictionary dictionary() { return dict_; };
}; // kgramFreqs

#endif // KGRAM_FREQS_H
