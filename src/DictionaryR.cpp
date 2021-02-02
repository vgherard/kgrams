#include "DictionaryR.h"
#include <queue>
#include <algorithm>
#include <Rcpp.h>
using namespace Rcpp;

double DictionaryR::make_word_heap(
                Rcpp::CharacterVector text, std::vector<WordCount> & res
        ) 
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

CharacterVector DictionaryR::as_character() const {
        size_t V = length();
        CharacterVector res(V);
        for(size_t i = 1; i <= V; ++i)
                res[i - 1] = word(std::to_string(i));
        return res;
}

LogicalVector DictionaryR::query(CharacterVector word) const
{
        size_t len = word.length();
        LogicalVector res(len);
        for (size_t i = 0; i < len; ++i) {
                res[i] = contains(as<std::string>(word[i]));
        }
        return res;
}

void DictionaryR::insertR(CharacterVector word_list)
{
        std::string str;
        for (String word : word_list) {
                str = word;
                insert(str);       
        } 
}

void DictionaryR::insert_cover(CharacterVector text, double target) 
{
        std::vector<WordCount> word_count;
        double tot_words = make_word_heap(text, word_count);
        double covered = 0.;
        while (covered < target and not word_count.empty()) {
                insert(word_count.front().word);
                covered += word_count.front().count / tot_words;
                std::pop_heap(word_count.begin(), word_count.end()); 
                word_count.pop_back();
        }
}

void DictionaryR::insert_n(Rcpp::CharacterVector text, size_t n)
{
        std::vector<WordCount> word_count;
        make_word_heap(text, word_count);
        for (size_t i = 0; i < n and not word_count.empty(); ++i) {
                insert(word_count.front().word);
                std::pop_heap(word_count.begin(), word_count.end()); 
                word_count.pop_back();
        }
}

void DictionaryR::insert_above(Rcpp::CharacterVector text, size_t thresh) 
{
        std::unordered_map<std::string, size_t> counts;
        std::string line, word; auto itend = text.end();
        for (auto it = text.begin(); it != itend; ++it) {
                line = *it;
                WordStream ws(line);
                while ((word = ws.pop_word()) != EOS_TOK) {
                        if (contains(word)) continue;
                        counts[word]++;
                        if (counts[word] > thresh) insert(word);
                }
        }
}

RCPP_EXPOSED_CLASS(Dictionary);
RCPP_EXPOSED_CLASS(DictionaryR);

RCPP_MODULE(Dictionary) {
        class_<Dictionary>("___Dictionary")
                .constructor()
                .const_method("length", &Dictionary::length)
        ;
        
        class_<DictionaryR>("Dictionary")
                .derives<Dictionary>("___Dictionary")
                .constructor()
                .constructor<CharacterVector>()
                .const_method("as_character", &DictionaryR::as_character)
                .const_method("query", &DictionaryR::query)
                .method("insert", &DictionaryR::insertR)
                .method("insert_cover", &DictionaryR::insert_cover)
                .method("insert_above", &DictionaryR::insert_above)
                .method("insert_n", &DictionaryR::insert_n)
        ;
}
