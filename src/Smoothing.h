/// @file   Dictionary.h 
/// @brief  Definition of Smoother classes 
/// @author Valerio Gherardi

#ifndef SMOOTHING_H
#define SMOOTHING_H

#include "kgramFreqs.h"
#include <cmath>
#include <limits>

/// @class Smoother
/// @brief Backbone structure for other smoothers object considered below. 
class Smoother {
protected:
        const kgramFreqs & f_; ///< @brief Underlying kgramFreqs object
        size_t N_; ///< @brief order of k-gram model
        size_t V_; ///< @brief Size of dictionary
        
        /// @brief truncate 'context' to last N - 1 words.
        std::string truncate (std::string context) const; // Smoothing.cpp
public:
        /// @brief constructor
        Smoother (const kgramFreqs & f) 
                : f_(f), N_(f.N()), V_(f.V()) {}
        
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
};

/// @class SBOSmoother
/// @brief Stupid Backoff continuation probability smoother
class SBOSmoother : public Smoother {
        //--------Private variables--------//
        double lambda_; ///< @brief Backoff penalization
        // ToDo: define getter and setter and export as property!
        
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
        
        
        //--------Probabilities--------//
        
        // Compute SBO continuation scores. Defined in Smoothing.cpp
        double operator() (const std::string & word, std::string context) const;
}; // class SBOSmoother

/// @class AddkSmoother
/// @brief Add-k continuation probability smoother
class AddkSmoother : public Smoother {
        //--------Private variables--------//
        double k_; ///< @brief constant weight added to k-gram counts
        // ToDo: define getter and setter and export as property!
public:
        //--------Constructor--------//
        
        /// @brief Initialize an AddkSmoother from a kgramFreqs object with a 
        /// fixed constant 'k'.
        /// @param f a kgramFreqs class object. k-gram frequency table from which
        /// "bare" k-gram counts are read off.
        /// @param k positive number. Constant weight added to k-gram counts.
        AddkSmoother (const kgramFreqs & f, const double k) : Smoother(f), k_(k) 
        {}
        
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
        // ToDo: define getter and setter and export as property!
        
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
        
        double continuation_probability (const std::string & word, 
                                         std::string context,
                                         size_t order) const;
public:
        //--------Constructors--------//
        KNSmoother (const kgramFreqs & f, const double D); // Smoothing.cpp

        //--------Probabilities--------//
        // KN probabilities. Defined in Smoothing.cpp
        double operator() (const std::string & word, std::string context) const;
}; // class KneserNeySmoother

#endif //SMOOTHING_H