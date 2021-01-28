#include "kgramFreqs.h"

/**
 * @brief store k-gram counts from a list of sentences.
 * @param sentences Vector of strings. A list of sentences from which to 
 * extract sentences
 * @param fixed_dictionary true or false. If true, any new word not appearing in 
 * the dictionary encountered during processing is replaced by an Unknown-Word 
 * token. Otherwise, new words are added to the dictionary.
 * @details Each entry of 'sentences' is considered a single sentence. 
 * For each sentence, anything separated by one or more space characters is 
 * considered a word.
 */
void kgramFreqs::process_sentences(const std::vector<std::string> & sentences,
                                   bool fixed_dictionary) 
{
        CircularBuffer<std::string> paddings(N_, "");
        // Define BOS paddings for 1-grams, 2-grams, ..., N-grams 
        for (int k = 0; k < N_; ++k) {
                std::string padding = "";
                for (size_t j = 0; j < k; ++j) {
                        padding += BOS_IND + " ";
                }
                paddings.write(padding);
                paddings.lshift();
                
                // Add counts for the various <BOS> <BOS> ... <BOS> padding
                if (k > 0)
                        padding.pop_back();
                freqs_[k][padding] += sentences.size();
        }
        for (const std::string & sentence : sentences) 
                process_sentence(sentence, paddings, fixed_dictionary);
}

// Note: the 'prefixes' buffer is supposed to be passed by value from
// process_sentences(), in order to reinitialize it to <BOS> <BOS> ... <BOS> 
// at the start of each iteration (sentence).

void kgramFreqs::process_sentence(const std::string & sentence,
                                  CircularBuffer<std::string> prefixes,
                                  bool fixed_dictionary)
{
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

/**
 * @brief Retrieve counts for a given k-gram.
 * @param kgram string. The k-gram to be queried.
 * @return A positive integer. Number of occurrences of 'kgram' in the text data
 * processed so far.
 * @details query() considers anything delimited by one or more characters as a
 * word. Thus, for instance, the calls
 * \verbatim query("i love you") \endverbatim 
 * or
 * \verbatim query(" i love you ") \endverbatim 
 * or 
 * \verbatim query("  i    love  you   ") \endverbatim 
 * would all produce the same result.
 */

double kgramFreqs::query (std::string kgram) const {
        auto p = dict_.kgram_code(kgram);
        if (p.first > N_) return 0;
        auto it = freqs_[p.first].find(p.second);
        return it != freqs_[p.first].end() ? it->second : 0;
}
