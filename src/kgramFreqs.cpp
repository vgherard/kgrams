#include "kgramFreqs.h"

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
                
                // Add BOS counts
                if (k > 0)
                        padding.pop_back();
                freqs_[k][padding] += sentences.size();
        }
        for (const std::string & sentence : sentences) 
                process_sentence(sentence, paddings, fixed_dictionary);
}

void kgramFreqs::process_sentence(const std::string & sentence,
                                  CircularBuffer<std::string> prefixes,
                                  bool fixed_dictionary)
{
        WordStream stream(sentence);
        std::string current, prefix;
        while (not stream.eos()) {
                freqs_[0][""]++;
                // Read next word
                current = stream.pop_word();
                // Substitute with ___UNK___ index if current is OOV
                if ((not dict_.contains_word(current)) & (not fixed_dictionary))
                        dict_.insert(current);
                
                current = dict_.index(current); 
                
                // Increase k-gram counts for (k>1)-grams ending at 'current'
                for (size_t k = 1; k <= N_; ++k) {
                        prefix = prefixes.read();
                        freqs_[k][prefix + current]++;
                        // Update prefix buffer for next word
                        prefixes.write(prefix + current + " ");
                        prefixes.lshift();
                }
                // Overwrite the last spurious N-gram prefix ending at 'current'
                prefixes.rshift();
                prefixes.write("");
        }
}

std::pair<size_t, std::string> kgramFreqs::kgram_code (std::string kgram) const
{
        std::pair<size_t, std::string> res{0, ""};
        WordStream stream(kgram);
        std::string word, index;
        for (; ; res.first++) {
                word = stream.pop_word();
                if (stream.eos()) break;
                index = dict_.index(word);
                res.second += index + " ";
        }
        if (res.first > 0) 
                res.second.pop_back();
        return res;
}

double kgramFreqs::query (std::string kgram) const {
        auto p = kgram_code(kgram);
        if (p.first > N_) return 0;
        auto it = freqs_[p.first].find(p.second);
        return it != freqs_[p.first].end() ? it->second : 0;
}