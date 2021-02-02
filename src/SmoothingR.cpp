#include "SmoothingR.h"

//---------------- Models ----------------//

// TODO: Is it possible to avoid the abomination below using either templates 
// or virtual methods? 

class SBOSmootherR : public SBOSmoother {
public:
        SBOSmootherR (const kgramFreqsR & f, const double lambda) 
                : SBOSmoother(f, lambda) {}
        NumericVector probability (CharacterVector word, std::string context) 
        { return probability_generic(this, word, context); }
        NumericVector probability_sentence (CharacterVector sentence) 
        { return probability_generic(this, sentence); }
        List log_probability_sentence (CharacterVector sentence) 
        { return log_prob_generic(this, sentence); }
        CharacterVector sample (size_t n, size_t max_length, double T = 1.0) 
        { return sample_generic(this, n, max_length, T); }
}; // class SBOSmootherR

class AddkSmootherR : public AddkSmoother {
public:
        AddkSmootherR (const kgramFreqsR & f, const double k) 
                : AddkSmoother(f, k) {}
        NumericVector probability (CharacterVector word, std::string context) 
        { return probability_generic(this, word, context); }
        NumericVector probability_sentence (CharacterVector sentence) 
        { return probability_generic(this, sentence); }
        List log_probability_sentence (CharacterVector sentence) 
        { return log_prob_generic(this, sentence); }
        CharacterVector sample (size_t n, size_t max_length, double T = 1.0) 
        { return sample_generic(this, n, max_length, T); }
}; // class AddkSmootherR

class MLSmootherR : public MLSmoother {
public:
        MLSmootherR (const kgramFreqsR & f) 
                : MLSmoother(f) {}
        NumericVector probability (CharacterVector word, std::string context) 
        { return probability_generic(this, word, context); }
        NumericVector probability_sentence (CharacterVector sentence) 
        { return probability_generic(this, sentence); }
        List log_probability_sentence (CharacterVector sentence) 
        { return log_prob_generic(this, sentence); }
        CharacterVector sample (size_t n, size_t max_length, double T = 1.0) 
        { return sample_generic(this, n, max_length, T); }
}; // class AddkSmootherR

class KNSmootherR : public KNSmoother {
public:
        KNSmootherR (const kgramFreqsR & f, const double D) 
                : KNSmoother(f, D) {}
        NumericVector probability (CharacterVector word, std::string context) 
        { return probability_generic(this, word, context); }
        NumericVector probability_sentence (CharacterVector sentence) 
        { return probability_generic(this, sentence); }
        List log_probability_sentence (CharacterVector sentence) 
        { return log_prob_generic(this, sentence); }
        CharacterVector sample (size_t n, size_t max_length, double T = 1.0) 
        { return sample_generic(this, n, max_length, T); }
}; // class KNSmootherR

RCPP_EXPOSED_CLASS(kgramFreqsR)
RCPP_MODULE (Smoothing) {
        class_<Smoother>("___Smoother")
                .property("N", &Smoother::N)
                .property("V", &Smoother::V)
        ;
        class_<SBOSmoother>("___SBOSmoother")
                .derives<Smoother>("___Smoother")
                .property("lambda", &SBOSmoother::lambda, &SBOSmoother::set_lambda)
        ;
        class_<AddkSmoother>("___AddkSmoother")
                .derives<Smoother>("___Smoother")
                .property("k", &AddkSmoother::k, &AddkSmoother::set_k)
        ;
        class_<MLSmoother>("___MLSmoother")
                .derives<Smoother>("___Smoother")
        ;
        class_<KNSmoother>("___KNSmoother")
                .derives<Smoother>("___Smoother")
                .property("D", &KNSmoother::D, &KNSmoother::set_D)
        ;
        class_<SBOSmootherR>("SBOSmoother")
                .derives<SBOSmoother>("___SBOSmoother")
                .constructor<const kgramFreqsR&, const double>()
                .method("probability", &SBOSmootherR::probability)
                .method("probability_sentence", &SBOSmootherR::probability_sentence)
                .method("log_probability_sentence", &SBOSmootherR::log_probability_sentence)
                .method("sample", &SBOSmootherR::sample)
        ;
        class_<MLSmootherR>("MLSmoother")
                .derives<MLSmoother>("___MLSmoother")
                .constructor<const kgramFreqsR&>()
                .method("probability", &MLSmootherR::probability)
                .method("probability_sentence", &MLSmootherR::probability_sentence)
                .method("log_probability_sentence", &MLSmootherR::log_probability_sentence)
                .method("sample", &MLSmootherR::sample)
        ;
        class_<AddkSmootherR>("AddkSmoother")
                .derives<AddkSmoother>("___AddkSmoother")
                .constructor<const kgramFreqsR&, const double>()
                .method("probability", &AddkSmootherR::probability)
                .method("probability_sentence", &AddkSmootherR::probability_sentence)
                .method("log_probability_sentence", &AddkSmootherR::log_probability_sentence)
                .method("sample", &AddkSmootherR::sample)
        ;
        class_<KNSmootherR>("KNSmoother")
                .derives<KNSmoother>("___KNSmoother")
                .constructor<const kgramFreqsR&, const double>()
                .method("probability", &KNSmootherR::probability)
                .method("probability_sentence", &KNSmootherR::probability_sentence)
                .method("log_probability_sentence", &KNSmootherR::log_probability_sentence)
                .method("sample", &KNSmootherR::sample)
        ;
}