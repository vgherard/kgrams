/// @file   Dictionary.h 
/// @brief  Definition of Sampler template class 
/// @author Valerio Gherardi

#ifndef SAMPLER_H
#define SAMPLER_H

#include "special_tokens.h"

/// @class Sampler
/// @brief Sample sequences from a k-gram language model
/// @tparam Smoother Smoother object for sampling probabilities of k-grams.

template<class Smoother>
class Sampler {
        //--------Private variables--------//
        
        /// @brief Smoother object for sampling probabilities
        Smoother prob_;
        
        //--------Private methods--------//
        
        /// @brief Sample a word from the probability distribution specified
        /// by the context ((N-1)-gram prefix), with an optional temperature. 
        std::string sample_word(std::string context, double T = 1.0) {
                std::string res;
                double best = 0, tmp;
                std::string word;
                // Sample word from P(word|context) using Gumbel-Max trick
                for (size_t i = 1; i <= prob_.V_; ++i) {
                        word = prob_.f_.dictionary().word(std::to_string(i));
                        tmp = std::pow(prob_(word, context), 1 / T); 
                        tmp /= R::rexp(1.);
                        if (tmp > best) {
                                best = tmp;
                                res = word;
                        }
                }
                // Separate iteration for EOS token
                tmp = std::pow(prob_(EOS_TOK, context), 1 / T) / R::rexp(1.);
                if (tmp > best)
                        res = EOS_TOK;
                // N.B.: we forbid sampling the UNK token
                return res;
        }
        
        // Not yet implemented. Sampling using simple rejection method.
        // N.B.: requires normalized probabilities.
        //
        // std::string sample_word_rej(std::string context) {
        //         std::string res;
        //         double best = 0, tmp;
        //         std::string word;
        //         while (true) {
        //                 size_t n = R::runif(0, prob_.V_);
        //                 word = prob_.f_.dictionary()->word(std::to_string(n));
        //                 if (prob_(word, context) / R::runif(0, 1) > 1)
        //                         return word;
        //         }
        // }
public:
        //--------Constructor--------//
        
        /// @brief Initialize a Sampler from a given smoother object.
        /// @param prob the smoother to be used for generating sampling 
        /// probabilities.
        Sampler (Smoother prob) : prob_(prob) {}
        
        /// @brief Sample a sentence from the probability distribution specified
        /// by the smoother.
        /// @param max_length Maximum length of sampled sequences (truncation
        /// occurs if max_length is reached).
        /// @param T optional temperature parameter. Defaults to 1.0.
        /// @return A string. Sampled sentence.
        std::string sample_sentence(size_t max_length, double T = 1.0) {
                std::string res = "", context = "";
                for (size_t i = 1; i < prob_.f_.N(); ++i) {
                        context += BOS_TOK + " ";
                }
                size_t n_words = 0;
                std::string new_word; size_t start = 0;
                while (n_words < max_length) {
                        n_words++;
                        new_word = sample_word(context, T);
                        if (new_word == EOS_TOK) 
                                return res + "<eos>";
                        res += new_word + " ";
                        context += " " + new_word;
                        start = context.find_first_not_of(" ");
                        start = context.find_first_of(" ", start);
                        context = context.substr(start + 1);
                }
                return res + "[...] (truncated output)";     
        }
}; // class Sampler<Smoother>

#endif // SAMPLER_H
