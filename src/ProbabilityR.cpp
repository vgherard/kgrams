#include <Rcpp.h>
#include "kgramFreqs.h"
#include "Smoothers.h"
using namespace Rcpp;

RCPP_EXPOSED_CLASS(kgramFreqs);

template<class Smoother>
NumericVector probability(CharacterVector word, 
                          std::string context, 
                          Smoother smoother) 
{
        size_t len = word.length();
        NumericVector res(len);
        
        std::string tmp_word; double tmp_res;
        for (size_t i = 0; i < len; ++i) {
                res[i] = smoother(as<std::string>(word[i]), context);
                if (res[i] == -1) 
                        res[i] = NA_REAL;
        }
        
        return res;
}


NumericVector probability_sbo(kgramFreqs & f,
                              CharacterVector word,
                              std::string context,
                              double lambda)
{
        SBOSmoother smoother(f, lambda);
        return probability<SBOSmoother>(word, context, smoother);
};

NumericVector probability_addk(kgramFreqs & f,
                               CharacterVector word,
                               std::string context,
                               double k)
{
        AddkSmoother smoother(f, k);
        return probability<AddkSmoother>(word, context, smoother);
}

NumericVector probability_ml(kgramFreqs & f,
                             CharacterVector word,
                             std::string context)
{
        MLSmoother smoother(f);
        return probability<MLSmoother>(word, context, smoother);
}

template<class Sampler>
CharacterVector sample_sentences(size_t n, 
                                 size_t max_length, 
                                 Sampler smp, 
                                 double T = 1.0) {
        CharacterVector res(n);
        for (size_t i = 0; i < n; ++i)
                res[i] = smp.sample_sentence(max_length, T);
        return res;
}
        
CharacterVector sample_sentences_sbo(kgramFreqs & f,
                                     size_t n, 
                                     size_t max_length, 
                                     double lambda, 
                                     double T = 1.0)
{
        Sampler<SBOSmoother> smp(SBOSmoother(f, lambda));
        return sample_sentences<Sampler<SBOSmoother> >(n, max_length, smp, T);
}

CharacterVector sample_sentences_addk(kgramFreqs & f,
                                      size_t n, 
                                      size_t max_length,
                                      double k,
                                      double T = 1.0)
{
        Sampler<AddkSmoother> smp(AddkSmoother(f, k));
        return sample_sentences<Sampler<AddkSmoother> >(n, max_length, smp, T);
}

CharacterVector sample_sentences_ml(kgramFreqs & f,
                                    size_t n,
                                    size_t max_length,
                                    double T = 1.0)
{
        Sampler<MLSmoother> smp((MLSmoother(f)));
        return sample_sentences<Sampler<MLSmoother> >(n, max_length, smp, T);
}

RCPP_MODULE(Probability) {
        function("probability_sbo", &probability_sbo);
        function("probability_addk", &probability_addk);
        function("probability_ml", &probability_ml);
        function("sample_sentences_sbo", &sample_sentences_sbo);
        function("sample_sentences_addk", &sample_sentences_addk);
        function("sample_sentences_ml", &sample_sentences_ml);
}
