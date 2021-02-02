/// @file   Dictionary.h 
/// @brief  Definition of Smoother classes 
/// @author Valerio Gherardi

#ifndef SMOOTHING_H
#define SMOOTHING_H

#include "kgramFreqs.h"
#include <cmath>
#include <limits>
#include <stdexcept>

/// @class Smoother
/// @brief Backbone structure for other smoothers object considered below. 
class Smoother {
protected:
        const kgramFreqs & f_; ///< @brief Underlying kgramFreqs object
        size_t N_; ///< @brief order of k-gram model
        size_t V_; ///< @brief Size of dictionary
        
        /// @brief Begin-Of-Sentence padding
        const std::string padding_;
        //--------Private methods--------//
        
        /// @brief Initialize a buffer of prefixes for processing sentences
        /// N.B. this is not the same as for kgramFreqs, as Smoother work in 
        /// decoding (i.e. they use actual word tokens)
        /// Moreover, this includes only the top-level (N-1)-gram prefix
        std::string generate_padding();
        
        /// @brief truncate 'context' to last N - 1 words.
        std::string truncate (std::string context) const; // Smoothing.cpp
public:
        /// @brief constructor
        Smoother (const kgramFreqs & f) 
                : f_(f), N_(f.N()), V_(f.V()), padding_(generate_padding()) {}
        
        /// @brief model order getter
        size_t N () const { return N_; }
        
        /// @brief dict size getter
        size_t V () const { return V_; }
        
        /// @brief check if word is in model's dictionary
        bool dict_contains (std::string word) const 
                { return V_; }
        
        /// @brief Return word-code from dictionary.
        /// @param word a string.
        /// @return a string.
        std::string word (std::string index) const { return f_.word(index); }
        
        /// @brief get smoothed continuation probabilites. 
        // Mock definition overloaded at run-time by the derived class' actual
        // method.
        virtual double operator() (const std::string &, std::string) const
                { return 1. ;}
        
        /// @brief get smoothed sentence probabilites. 
        std::pair<double, size_t> operator() (
                        const std::string &, bool log = false
        ) const; // Smoothing.cpp
};

/// @class SBOSmoother
/// @brief Stupid Backoff continuation probability smoother
class SBOSmoother : public Smoother {
        //--------Private variables--------//
        double lambda_; ///< @brief Backoff penalization
        
        //--------Private methods--------//
        
        /// @brief Remove first word from context
        void backoff (std::string & context) const; // Smoothing.cpp

        
public:
        //--------Constructor--------//

        /// @brief Initialize a SBOSmoother from a kgramFreqs object with a 
        /// fixed backoff penalization.
        /// @param f a kgramFreqs class object. k-gram frequency table from which
        /// "bare" k-gram counts are read off.
        /// @param lambda positive number. Penalization in Stupid Backoff 
        /// recursion.
        SBOSmoother (const kgramFreqs & f, const double lambda) 
                : Smoother(f), lambda_(lambda) {}
        
        //--------Parameters getters/setters--------//
        double lambda() const { return lambda_; }
        void set_lambda(double lambda) {
                if (lambda < 0 or lambda > 1)
                        throw std::domain_error(
                                "'lambda' must be between 0 and 1."
                                );
                lambda_ = lambda;
        }
                
        //--------Probabilities--------//
        
        // Compute SBO continuation scores. Defined in Smoothing.cpp
        double operator() (const std::string & word, std::string context) const;
}; // class SBOSmoother

/// @class AddkSmoother
/// @brief Add-k continuation probability smoother
class AddkSmoother : public Smoother {
        //--------Private variables--------//
        double k_; ///< @brief constant weight added to k-gram counts
public:
        //--------Constructor--------//
        
        /// @brief Initialize an AddkSmoother from a kgramFreqs object with a 
        /// fixed constant 'k'.
        /// @param f a kgramFreqs class object. k-gram frequency table from which
        /// "bare" k-gram counts are read off.
        /// @param k positive number. Constant weight added to k-gram counts.
        AddkSmoother (const kgramFreqs & f, const double k) : Smoother(f), k_(k) 
        {}
        
        //--------Parameters getters/setters--------//
        double k() const { return k_; }
        void set_k(double k) {
                if (k <= 0)
                        throw std::domain_error(
                                        "'k' must be positive."
                        );
                k_ = k;
        }
        
        //--------Probabilities--------//

        // Addk continuation probabilities. Defined in Smoothing.cpp
        double operator() (const std::string & word, std::string context) const;
}; // class AddkSmoother

/// @class MLSmoother
/// @brief Maximum-Likelihood continuation probability smoother
class MLSmoother : public Smoother {
public:
        //--------Constructors--------//
        
        /// @brief Initialize an AddkSmoother from a kgramFreqs object with a 
        /// fixed constant 'k'.
        /// @param f a kgramFreqs class object. k-gram frequency table from which
        /// "bare" k-gram counts are read off.
        MLSmoother (const kgramFreqs & f) : Smoother(f) {}
        
        //--------Probabilities--------//
        
        // ML continuation probabilities. Defined in Smoothing.cpp
        double operator() (const std::string & word, std::string context) const;
}; // class MLSmoother

/// @class KneserNeySmoother
/// @brief Kneser-Ney continuation probability smoother
class KNSmoother : public Smoother {
        //--------Local aliases--------//
        using FrequencyTable = std::unordered_map<std::string, size_t>;

        //--------Private variables--------//
        double D_; ///< @brief Discount 
        
        /// @brief Left continuation counts for Kneser-Ney smoothing
        std::vector<FrequencyTable> l_continuations_;
        /// @brief Right continuation counts for Kneser-Ney smoothing
        std::vector<FrequencyTable> r_continuations_;
        /// @brief Two-sided continuation counts for Kneser-Ney smoothing
        std::vector<FrequencyTable> lr_continuations_;
        
        //--------Private methods--------//
        // Remove one word to the left of kgram_code. Defined in Smoothing.cpp
        std::string pop_l (std::string kgram_code) const;
        // Remove one word to the right of kgram_code. Defined in Smoothing.cpp
        std::string pop_r (std::string kgram_code) const;
        // Remove one word to the left and one to the right of kgram_code. 
        // Defined in Smoothing.cpp
        std::string pop_lr (const std::string & kgram_code) const;
        
        // Compute continuation probability of word in given context
        // k-gram order is passed 
        double prob_cont (const std::string &, std::string, size_t) const;
public:
        //--------Constructors--------//
        KNSmoother (const kgramFreqs & f, const double D); // Smoothing.cpp
        
        //--------Parameters getters/setters--------//
        double D() const { return D_; }
        void set_D (double D) {
                if (D < 0 or D > 1)
                        throw std::domain_error(
                                        "Discount must be between 0 and 1."
                        );
                D_ = D;
        }
        
        //--------Probabilities--------//
        // KN probabilities. Defined in Smoothing.cpp
        double operator() (const std::string & word, std::string context) const;
}; // class KneserNeySmoother

#endif //SMOOTHING_H