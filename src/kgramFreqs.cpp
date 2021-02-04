#include "kgramFreqs.h"

// Note: the 'prefixes' buffer is supposed to be passed by value from
// process_sentences(), in order to reinitialize it to <BOS> <BOS> ... <BOS> 
// at the start of each iteration (sentence).

void kgramFreqs::process_sentence(const std::string & sentence,
                                  bool fixed_dictionary)
{
        CircularBuffer<std::string> prefixes = padding_;
        WordStream stream(sentence);
        std::string word, prefix;
        while (not stream.eos()) {
                freqs_[0][""]++; // Increase total words count
                word = stream.pop_word();
                
                if ((not dict_.contains(word)) & (not fixed_dictionary))
                        dict_.insert(word);
                
                word = dict_.index(word); // UNK_TOK if 'word' not in dictionary
                
                // Increase k-gram counts for (k>1)-grams ending at 'word'
                for (size_t k = 1; k <= N_; ++k) {
                        prefix = prefixes.read();
                        freqs_[k][prefix + word]++;
                        // Update prefix buffer for next word
                        prefixes.write(prefix + word + " ");
                        prefixes.lshift();
                }
                // Overwrite the last spurious N-gram prefix ending at 'word'
                // With an empty prefix and realign prefix buffer
                prefixes.rshift();
                prefixes.write("");
        }
}

/// @brief Retrieve counts for a given k-gram.
/// @param kgram string. The k-gram to be queried.
/// @return A positive integer. Number of occurrences of 'kgram' in the text data
/// processed so far.
/// @details query() considers anything delimited by one or more characters as a
/// word. Thus, for instance, the calls
/// \verbatim query("i love you") \endverbatim 
/// or
/// \verbatim query(" i love you ") \endverbatim 
/// or 
/// \verbatim query("  i    love  you   ") \endverbatim 
/// would all produce the same result.

double kgramFreqs::query (std::string kgram) const {
        auto p = kgram_code(kgram);
        if (p.first > N_) return -1;
        auto it = freqs_[p.first].find(p.second);
        return it != freqs_[p.first].end() ? it->second : 0;
}

/// @brief Initialize a buffer of prefixes for processing sentences
CircularBuffer<std::string> kgramFreqs::generate_padding() {
        CircularBuffer<std::string> res(N_, "");
        for (int k = 0; k < N_; ++k) {
                std::string padding = "";
                for (size_t j = 0; j < k; ++j) {
                        padding += BOS_IND + " ";
                }
                res.write(padding);
                res.lshift();
        }
        return res;
}
/// @brief Increase counts for <BOS>, <BOS> <BOS>, etc. by n
void kgramFreqs::add_BOS_counts(size_t n) {
        std::string padding = "";
        for (int k = 1; k < N_; ++k) {
                padding += BOS_TOK + " ";
                freqs_[k][dict_.kgram_code(padding).second] += n;
        }
}

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
void kgramFreqs::process_sentences(
        const std::vector<std::string> & sentences, bool fixed_dictionary
        ) 
{
        // Add counts for the various <BOS> <BOS> ... <BOS> paddings
        add_BOS_counts(sentences.size());
        for (const std::string & sentence : sentences) 
                process_sentence(sentence, fixed_dictionary);
        update_satellites();
}