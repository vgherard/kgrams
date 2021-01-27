#ifndef SMOOTHERS_H
#define SMOOTHERS_H

#include "kgramFreqs.h"
#include <Rmath.h>
#include <cmath>
#include <limits>


template<class Smoother>
class Sampler {
        Smoother prob_;
public:
        Sampler (Smoother prob) : prob_(prob) {} 
        std::string sample_word(std::string context, double T) {
                std::string res;
                double best = 0, tmp;
                std::string word;
                for (size_t i = 1; i <= prob_.V_; ++i) {
                        word = prob_.f_.dictionary()->word(std::to_string(i));
                        tmp = std::pow(prob_(word, context), 1 / T); 
                        tmp /= R::rexp(1.);
                        if (tmp > best) {
                                best = tmp;
                                res = word;
                        }
                }
                tmp = std::pow(prob_(EOS_TOK, context), 1 / T) / R::rexp(1.);
                if (tmp > best)
                        res = EOS_TOK;
                return res;
        }
        
        std::string sample_word_rej(std::string context) {
                std::string res;
                double best = 0, tmp;
                std::string word;
                while (true) {
                        size_t n = R::runif(0, prob_.V_);
                        word = prob_.f_.dictionary()->word(std::to_string(n));
                        if (prob_(word, context) / R::runif(0, 1) > 1)
                                return word;
                }
        }
        
        
        std::string sample_sentence(size_t max_length, double T) {
                std::string res = "", prefix = "";
                for (size_t i = 1; i < prob_.f_.N(); ++i) {
                        prefix += BOS_TOK + " ";
                }
                
                size_t n_words = 0;
                std::string new_word; size_t start = 0;
                while (n_words < max_length and new_word != EOS_TOK) {
                        n_words++;
                        new_word = sample_word(prefix, T);
                        res += new_word + " ";
                        prefix += " " + new_word;
                        start = prefix.find_first_not_of(" ");
                        start = prefix.find_first_of(" ", start);
                        prefix = prefix.substr(start + 1);
                }

                return res;     
        }
        
        
}; // template class Sampler

class SBOSmoother {
        kgramFreqs & f_;
        size_t V_;
        const double & lambda_;
        void backoff (std::string & context) {
                size_t pos = context.find_first_not_of(" ");
                pos = context.find_first_of(" ", pos);
                if (pos == std::string::npos) 
                        context.erase();
                else
                        context = context.substr(pos);
        }
public:
        SBOSmoother (kgramFreqs & f, const double & lambda) 
                : f_(f), V_(f.V()), lambda_(lambda) {}
        double operator() (const std::string & word, std::string context)
        {
                double kgram_count, penalization = 1.;
                while ((kgram_count = f_.query(context + " " + word)) == 0) {
                        backoff(context);
                        penalization *= lambda_;
                        if (context == "")
                                return 0;
                }
                return penalization * kgram_count / f_.query(context);
        }
        
        friend class Sampler<SBOSmoother>;
}; // class SBOSmoother

class AddkSmoother {
        kgramFreqs & f_;
        size_t V_;
        const double & k_;
public:
        AddkSmoother (kgramFreqs & f, const double & k) 
                : f_(f), V_(f.V()), k_(k) {}
        double operator() (const std::string & word, std::string context)
        {
                double num = f_.query(context + " " + word) + k_;
                double den = f_.query(context) + k_ * (V_ + 2);
                return num / den;
        }
        
        friend class Sampler<AddkSmoother>;
}; // class AddkSmoother

class MLSmoother {
        kgramFreqs & f_;
        size_t V_; 
public:
        MLSmoother (kgramFreqs & f) : f_(f), V_(f.V()) {}
        double operator() (const std::string & word, std::string context)
        {
                double den = f_.query(context);
                if (den == 0)
                        return -1;
                else
                        return f_.query(context + " " + word) / den;
        }
        
        friend class Sampler<MLSmoother>;
}; // class MLSmoother




#endif //SMOOTHERS_H