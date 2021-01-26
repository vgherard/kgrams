#include "kgramFreqs.h"
#include <utility>

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