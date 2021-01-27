#include "Dictionary.h"
#include "kgramFreqs.h"
#include <queue>
#include <algorithm>
#include <Rcpp.h>
using namespace Rcpp;

RCPP_EXPOSED_CLASS(Dictionary);

size_t length_kgrams_dictionary(XPtr<Dictionary> xptr) {return xptr->length();}

LogicalVector query_word(XPtr<Dictionary> xptr, CharacterVector word) 
{
        size_t len = word.length();
        LogicalVector res(len);
        for (size_t i = 0; i < len; ++i) {
                res[i] = xptr->contains_word(as<std::string>(word[i]));
        }
        return res;
}

struct WordCount {
        std::string word;
        size_t count;
        
        WordCount (std::string w, size_t c) : word(w), count(c) {}
        
        WordCount & operator++() {
                count++;
                return *this;
        }
        
        friend bool operator< (const WordCount & l, const WordCount & r) 
        {
                if (l.count != r.count) return l.count < r.count; 
                else return l.word > r.word;         
        }
        
};

double make_word_heap(Rcpp::CharacterVector text, std::vector<WordCount> & res) 
{
        std::string line, word;
        std::unordered_map<std::string, size_t> word_index;
        double tot_words = 0; auto itend = text.end();
        for (auto it = text.begin(); it != itend; ++it) {
                line = Rcpp::as<std::string>(*it);
                WordStream ws(line);
                while ((word = ws.pop_word()) != EOS_TOK) {
                        tot_words++;
                        auto it = word_index.find(word);
                        if (it != word_index.end()) {
                                ++res[it->second];
                        } else {
                                res.push_back(WordCount(word, 1));
                                word_index[word] = res.size() - 1;
                        }
                }
        }
        std::make_heap(res.begin(), res.end());
        return tot_words;
}

XPtr<Dictionary> dict_coverage(Rcpp::CharacterVector text, double coverage) 
{
        XPtr<Dictionary> res(new Dictionary, true);
        std::vector<WordCount> word_count;
        double tot_words = make_word_heap(text, word_count);
        double covered = 0.;
        while (covered < coverage and not word_count.empty()) {
                res->insert(word_count.front().word);
                covered += word_count.front().count / tot_words;
                std::pop_heap(word_count.begin(), word_count.end()); 
                word_count.pop_back();
        }
        return res;
}

XPtr<Dictionary> dict_top_n(Rcpp::CharacterVector text, size_t n)
{
        XPtr<Dictionary> res(new Dictionary, true);
        std::vector<WordCount> word_count;
        make_word_heap(text, word_count);
        for (size_t i = 0; i < n and not word_count.empty(); ++i) {
                res->insert(word_count.front().word);
                std::pop_heap(word_count.begin(), word_count.end()); 
                word_count.pop_back();
        }
        return res;
}

XPtr<Dictionary> dict_thresh(Rcpp::CharacterVector text, size_t thresh) 
{
        XPtr<Dictionary> res(new Dictionary, true);
        std::unordered_map<std::string, size_t> counts;
        std::string line, word; auto itend = text.end();
        for (auto it = text.begin(); it != itend; ++it) {
                line = *it;
                WordStream ws(line);
                while ((word = ws.pop_word()) != EOS_TOK) {
                        if (res->contains_word(word))
                                continue;
                        counts[word]++;
                        if (counts[word] > thresh) 
                                res->insert(word);
                }
        }
        return res;
}


RCPP_MODULE(Dictionary) {
        function("query_word", &query_word);
        function("length_kgrams_dictionary", &length_kgrams_dictionary);
        function("dict_thresh", &dict_thresh);
        function("dict_coverage", &dict_coverage);
        function("dict_top_n", &dict_top_n);
}