#include "kgramFreqs.h"

size_t kgramFreqs::query (std::string kgram) const {
        WordStream stream(kgram);
        std::string kgram_code = "", word, index;
        size_t k = 0;
        while ((word = stream.pop_word()) != EOS_TOK) {
                index = dict_.index(word);
                kgram_code += index + " ";
                k++;
        }
        
        if (k > 0) 
                kgram_code.pop_back();
        if (k > N_)
                return 0;
        auto it = freqs_[k].find(kgram_code);
        return it != freqs_[k].end() ? it->second : 0;
}