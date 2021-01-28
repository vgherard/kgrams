/// @file   Dictionary.h 
/// @brief  Definition of Smoother classes 
/// @author Valerio Gherardi

#ifndef SMOOTHERS_H
#define SMOOTHERS_H

#include "kgramFreqs.h"
#include "Sampler.h"
#include <Rmath.h>
#include <cmath>
#include <limits>

/// @class SBOSmoother
/// @brief Stupid Backoff continuation probability smoother
class SBOSmoother {
        //--------Private variables--------//
        
        kgramFreqs & f_; ///< @brief Underlying kgramFreqs object
        size_t V_; ///< @brief Size of dictionary
        const double & lambda_; ///< @brief Backoff penalization
        
        //--------Private methods--------//
        
        /// @brief Remove first word from context
        void backoff (std::string & context) {
                size_t pos = context.find_first_not_of(" ");
                pos = context.find_first_of(" ", pos);
                if (pos == std::string::npos) 
                        context.erase();
                else
                        context = context.substr(pos);
        }
public:
        //--------Constructor--------//

        /// @brief Initialize a SBOSmoother from a kgramFreqs object with a 
        /// fixed backoff penalization.
        /// @param f a kgramFreqs class object. k-gram frequency table from which
        /// "bare" k-gram counts are read off.
        /// @param lambda positive number. Penalization in Stupid Backoff 
        /// recursion.
        SBOSmoother (kgramFreqs & f, const double & lambda) 
                : f_(f), V_(f.V()), lambda_(lambda) {}
        
        //--------Probabilities--------//
        
        /// @brief Return Stupid Backoff continuation score of a word given a 
        /// context.
        /// @param word A string. Word for which the continuation score 
        /// is to be computed.
        /// @param context A string. Context conditioning the score of 
        /// 'word'.
        /// @return a positive number. Stupid Backoff continuation score of
        /// 'word' given 'context'.
        double operator() (const std::string & word, std::string context)
        {
                double kgram_count, penalization = 1.;
                size_t n_backoffs = 0;
                while ((kgram_count = f_.query(context + " " + word)) == 0) {
                        backoff(context);
                        penalization *= lambda_;
                        n_backoffs++;
                        if (n_backoffs > f_.N() - 1)
                                return 0;
                }
                return penalization * kgram_count / f_.query(context);
        }
        
        friend class Sampler<SBOSmoother>;
}; // class SBOSmoother

/// @class AddkSmoother
/// @brief Add-k continuation probability smoother
class AddkSmoother {
        //--------Private variables--------//
        
        kgramFreqs & f_; ///< @brief Underlying kgramFreqs object
        size_t V_; ///< @brief Size of dictionary
        const double & k_; ///< @brief constant weight added to k-gram counts
public:
        //--------Constructor--------//
        
        /// @brief Initialize an AddkSmoother from a kgramFreqs object with a 
        /// fixed constant 'k'.
        /// @param f a kgramFreqs class object. k-gram frequency table from which
        /// "bare" k-gram counts are read off.
        /// @param k positive number. Constant weight added to k-gram counts.
        AddkSmoother (kgramFreqs & f, const double & k) 
                : f_(f), V_(f.V()), k_(k) {}
        
        //--------Probabilities--------//

        /// @brief Return Add-k continuation probability of a word 
        /// given a context.
        /// @param word A string. Word for which the continuation probability 
        /// is to be computed.
        /// @param context A string. Context conditioning the probability of 
        /// 'word'.
        /// @return a positive number. Add-k continuation probability of
        /// 'word' given 'context'.
        double operator() (const std::string & word, std::string context)
        {
                double num = f_.query(context + " " + word) + k_;
                double den = f_.query(context) + k_ * (V_ + 2);
                return num / den;
        }
        
        friend class Sampler<AddkSmoother>;
}; // class AddkSmoother

/// @class MLSmoother
/// @brief Maximum-Likelihood continuation probability smoother
class MLSmoother {
        //--------Private variables--------//
        kgramFreqs & f_; ///< @brief Underlying kgramFreqs object
        size_t V_; ///< @brief Size of dictionary
public:
        //--------Constructors--------//
        
        /// @brief Initialize an AddkSmoother from a kgramFreqs object with a 
        /// fixed constant 'k'.
        /// @param f a kgramFreqs class object. k-gram frequency table from which
        /// "bare" k-gram counts are read off.
        MLSmoother (kgramFreqs & f) : f_(f), V_(f.V()) {}
        
        
        //--------Probabilities--------//
        
        /// @brief Return Maximum-Likelihood continuation probability of a word 
        /// given a context.
        /// @param word A string. Word for which the continuation probability 
        /// is to be computed.
        /// @param context A string. Context conditioning the probability of 
        /// 'word'.
        /// @return a positive number. Maximum-Likelihood continuation 
        /// probability of 'word' given 'context'.
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