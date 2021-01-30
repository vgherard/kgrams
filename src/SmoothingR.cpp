#include "SmoothingR.h"

RCPP_EXPOSED_CLASS(kgramFreqsR)
RCPP_MODULE (Smoothing) {
        class_<Smoother>("___Smoother")
        ;
        class_<SBOSmoother>("___SBOSmoother")
                .derives<Smoother>("___Smoother")
        ;
        class_<AddkSmoother>("___AddkSmoother")
                .derives<Smoother>("___Smoother")
        ;
        class_<MLSmoother>("___MLSmoother")
                .derives<Smoother>("___Smoother")
        ;
        class_<SBOSmootherR>("SBOSmoother")
                .derives<SBOSmoother>("___SBOSmoother")
                .constructor<const kgramFreqsR&, const double>()
                .method("probability", &SBOSmootherR::probability)
                .method("sample", &SBOSmootherR::sample)
        ;
        class_<MLSmootherR>("MLSmoother")
                .derives<MLSmoother>("___MLSmoother")
                .constructor<const kgramFreqsR&>()
                .method("probability", &MLSmootherR::probability)
                .method("sample", &MLSmootherR::sample)
        ;
        class_<AddkSmootherR>("AddkSmoother")
                .derives<AddkSmoother>("___AddkSmoother")
                .constructor<const kgramFreqsR&, const double>()
                .method("probability", &AddkSmootherR::probability)
                .method("sample", &AddkSmootherR::sample)
        ;
        class_<KNSmootherR>("KNSmoother")
                .derives<AddkSmoother>("___AddkSmoother")
                .constructor<const kgramFreqsR&, const double>()
                .method("probability", &KNSmootherR::probability)
                .method("sample", &KNSmootherR::sample)
        ;
}