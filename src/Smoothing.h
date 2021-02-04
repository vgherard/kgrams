/// @file   Dictionary.h 
/// @brief  Definition of Smoother classes 
/// @author Valerio Gherardi

#ifndef SMOOTHING_H
#define SMOOTHING_H

#include "kgramFreqs.h"
#include "Satellite.h"
#include <cmath>
#include <limits>
#include <stdexcept>

/// @class Smoother
/// @brief Backbone structure for other smoothers object considered below. 
class Smoother {
protected:
        const kgramFreqs & f_; ///< @brief Underlying kgramFreqs object
        size_t N_; ///< @brief order of k-gram model
        std::string padding_; /// @brief Begin-Of-Sentence padding
        //--------Private methods--------//
        
        
        /// @brief truncate 'context' to last N - 1 words.
        std::string truncate (std::string context, size_t k) const; // Smoothing.cpp
        
        /// @brief Remove first word from context
        void backoff (std::string & context) const; // Smoothing.cpp
public:
        /// @brief constructor
        Smoother (const kgramFreqs & f, size_t N) : f_(f) { set_N(N); }
        
        /// @brief model order getter
        size_t N () const { return N_; }
        
        /// @brief model order setter
        void set_N (size_t); // Smoothing.cpp
        
        /// @brief dict size getter
        size_t V () const { return f_.V(); }
        
        /// @brief check if word is in model's dictionary
        bool dict_contains (std::string word) const 
                { return f_.dict_contains(word); }
        
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
public:
        //--------Constructor--------//

        /// @brief Initialize a SBOSmoother from a kgramFreqs object with a 
        /// fixed backoff penalization.
        /// @param f a kgramFreqs class object. k-gram frequency table from which
        /// "bare" k-gram counts are read off.
        /// @param lambda positive number. Penalization in Stupid Backoff 
        /// recursion.
        SBOSmoother (const kgramFreqs & f, size_t N, const double lambda) 
                : Smoother(f, N), lambda_(lambda) {}
        
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
        AddkSmoother (const kgramFreqs & f, size_t N, const double k) 
                : Smoother(f, N), k_(k) 
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
        MLSmoother (const kgramFreqs & f, size_t N) : Smoother(f, N) {}
        
        //--------Probabilities--------//
        
        // ML continuation probabilities. Defined in Smoothing.cpp
        double operator() (const std::string & word, std::string context) const;
}; // class MLSmoother

class FreqTablesVec {
        using FrequencyTable = std::unordered_map<std::string, size_t>;
        std::vector<FrequencyTable> f_;
public:
        FreqTablesVec(size_t N) : f_(N) {}
        double query(size_t order, std::string kgram) const {
                auto it = f_[order].find(kgram);
                return it != f_[order].end() ? it->second : 0; 
        }
        FrequencyTable& operator[] (size_t k) { return f_[k]; }
};

class KNFreqs : public Satellite {
        const kgramFreqs & f_;
        /// @brief Left continuation counts for Kneser-Ney smoothing
        FreqTablesVec l_;
        /// @brief Right continuation counts for Kneser-Ney smoothing
        FreqTablesVec r_;
        /// @brief Two-sided continuation counts for Kneser-Ney smoothing
        FreqTablesVec lr_;
public:
        KNFreqs (const kgramFreqs & f) 
                : f_(f), l_(f_.N()), r_(f_.N()), lr_(f_.N() - 1) { update(); } 
        void update ();
        const FreqTablesVec & r() const { return r_; }
        const FreqTablesVec & l() const { return l_; }
        const FreqTablesVec & lr() const { return lr_; }
};

/// @class KneserNeySmoother
/// @brief Kneser-Ney continuation probability smoother
class KNSmoother : public Smoother {
        //--------Private variables--------//
        double D_; ///< @brief Discount
        KNFreqs knf_; ///< @brief Kneser-Ney continuation counts
        
        // Compute continuation probability of word in given context
        // k-gram order is passed 
        double prob_cont (const std::string &, std::string, size_t) const;
public:
        //--------Constructors--------//
        KNSmoother (kgramFreqs & f, size_t N, const double D) 
                : Smoother(f, N), D_(D), knf_(f) { f.add_satellite(&knf_); }
        
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

class mKNFreqs : public Satellite {
        using FrequencyTable = std::unordered_map<std::string, size_t>;
        const kgramFreqs & f_;
        
        /// @brief Left continuation counts for Kneser-Ney smoothing
        FreqTablesVec l_;
        /// @brief Right continuation counts for Kneser-Ney smoothing
        FreqTablesVec r1_;
        FreqTablesVec r2_;
        FreqTablesVec r3p_;
        /// @brief Two-sided continuation counts for Kneser-Ney smoothing
        FreqTablesVec lr_;
public:
        mKNFreqs (const kgramFreqs & f) 
                : f_(f), 
                  l_(f_.N()), 
                  r1_(f_.N()), r2_(f_.N()), r3p_(f_.N()),
                  lr_(f_.N() - 1) 
                { update(); }
        void update ();
        const FreqTablesVec & r1() const { return r1_; }
        const FreqTablesVec & r2() const { return r2_; }
        const FreqTablesVec & r3p() const { return r3p_; }
        const FreqTablesVec & l() const { return l_; }
        const FreqTablesVec & lr() const { return lr_; }
};

/// @class mKNSmoother
/// @brief Modified Kneser-Ney continuation probability smoother
class mKNSmoother : public Smoother {
        //--------Private variables--------//
        double D1_, D2_, D3_; ///< @brief Discount
        mKNFreqs mknf_; ///< @brief Kneser-Ney continuation counts
        
        double D_(size_t k) const
        { 
                switch(k) 
                {
                case 1: return D1_;
                case 2: return D2_;
                default: return D3_;
                }
                
        }
        
        // Compute continuation probability of word in given context
        // k-gram order is passed 
        double prob_cont (const std::string &, std::string, size_t) const;
public:
        //--------Constructors--------//
        mKNSmoother (kgramFreqs & f, size_t N, double D1, double D2, double D3) 
                : Smoother(f, N), D1_(D1), D2_(D2), D3_(D3), mknf_(f) 
                { f.add_satellite(&mknf_); }
        
        //--------Parameters getters/setters--------//
        double D1() const { return D1_; }
        double D2() const { return D2_; }
        double D3() const { return D3_; }
        void set_D1 (double D1) {
                if (D1 < 0 or D1 > 1)
                        throw std::domain_error(
                                "Discount parameters must be between 0 and 1."
                        );
                D1_ = D1;
        }
        void set_D2 (double D2) {
                if (D2 < 0 or D2 > 1)
                        throw std::domain_error(
                                        "Discount parameters must be between 0 and 1."
                        );
                D2_ = D2;
        }
        void set_D3 (double D3) {
                if (D3 < 0 or D3 > 1)
                        throw std::domain_error(
                                        "Discount parameters must be between 0 and 1."
                        );
                D3_ = D3;
        }
        
        //--------Probabilities--------//
        // KN probabilities. Defined in Smoothing.cpp
        double operator() (const std::string & word, std::string context) const;
}; // class KneserNeySmoother


class RFreqs : public Satellite {
        using FrequencyTable = std::unordered_map<std::string, size_t>;
        const kgramFreqs & f_;
        /// @brief Right continuation counts for Kneser-Ney smoothing
        std::vector<FrequencyTable> r_;
public:
        RFreqs (const kgramFreqs & f) 
                : f_(f), r_(f_.N())
        { update(); }
        void update ();
        
        const double r(size_t order, std::string kgram) const {
                auto it = r_[order].find(kgram);
                return it != r_[order].end() ? it->second : 0; 
        }
        
        double query (std::string kgram) const {
                auto p = f_.kgram_code(kgram);
                if (p.first > f_.N()) return -1;
                auto it = r_[p.first].find(p.second);
                return it != r_[p.first].end() ? it->second : 0;
        }
}; // class RFreqs

/// @class AbsSmoother
/// @brief Absolute Discount continuation probability smoother
class AbsSmoother : public Smoother {
        //--------Local aliases--------//
        using FrequencyTable = std::unordered_map<std::string, size_t>;
        
        //--------Private variables--------//
        double D_; ///< @brief Discount
        RFreqs absf_; ///< @brief Right continuation counts

public:
        //--------Constructors--------//
        AbsSmoother (kgramFreqs & f, size_t N, const double D) 
                : Smoother(f, N), D_(D), absf_(f) { f.add_satellite(&absf_); }
        
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
}; // class AbsSmoother

/// @class WBSmoother
/// @brief Witten-Bell continuation probability smoother
class WBSmoother : public Smoother {
        //--------Local aliases--------//
        using FrequencyTable = std::unordered_map<std::string, size_t>;
        
        //--------Private variables--------//
        RFreqs wbf_; ///< @brief Right continuation counts
        
public:
        //--------Constructors--------//
        WBSmoother (kgramFreqs & f, size_t N) 
                : Smoother(f, N), wbf_(f) { f.add_satellite(&wbf_); }
        
        //--------Probabilities--------//
        // KN probabilities. Defined in Smoothing.cpp
        double operator() (const std::string & word, std::string context) const;
}; // class WBSmoother

#endif //SMOOTHING_H