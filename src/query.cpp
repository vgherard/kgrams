#include "kgramFreqs.h"

double kgramFreqs::query (std::string kgram) const {
        WordStream stream(kgram);
        std::string kgram_code = "", word, index;
        size_t k = 0;
        for (; ; k++) {
                word = stream.pop_word();
                if (stream.eos())
                        break;
                index = dict_.index(word);
                kgram_code += index + " ";
        }
        
        if (k > 0) 
                kgram_code.pop_back();
        if (k > N_)
                return -1; // NA
        auto it = freqs_[k].find(kgram_code);
        return it != freqs_[k].end() ? it->second : 0;
}