#include "SmoothingR.h"

RCPP_EXPOSED_CLASS(kgramFreqsR)
RCPP_MODULE (Smoothing) {
        class_<Smoother>("___Smoother")
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
                .property("discount", &KNSmoother::discount, &KNSmoother::set_discount)
        ;
        class_<SBOSmootherR>("SBOSmoother")
                .derives<SBOSmoother>("___SBOSmoother")
                .constructor<const kgramFreqsR&, const double>()
                .method("probability", &SBOSmootherR::probability)
                .method("probability_sentence", &SBOSmootherR::probability_sentence)
                .method("sample", &SBOSmootherR::sample)
        ;
        class_<MLSmootherR>("MLSmoother")
                .derives<MLSmoother>("___MLSmoother")
                .constructor<const kgramFreqsR&>()
                .method("probability", &MLSmootherR::probability)
                .method("probability_sentence", &MLSmootherR::probability_sentence)
                .method("sample", &MLSmootherR::sample)
        ;
        class_<AddkSmootherR>("AddkSmoother")
                .derives<AddkSmoother>("___AddkSmoother")
                .constructor<const kgramFreqsR&, const double>()
                .method("probability", &AddkSmootherR::probability)
                .method("probability_sentence", &AddkSmootherR::probability_sentence)
                .method("sample", &AddkSmootherR::sample)
        ;
        class_<KNSmootherR>("KNSmoother")
                .derives<KNSmoother>("___KNSmoother")
                .constructor<const kgramFreqsR&, const double>()
                .method("probability", &KNSmootherR::probability)
                .method("probability_sentence", &KNSmootherR::probability_sentence)
                .method("sample", &KNSmootherR::sample)
        ;
}