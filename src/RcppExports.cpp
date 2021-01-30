// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include "../inst/include/kgrams.h"
#include <Rcpp.h>

using namespace Rcpp;

// preprocess
Rcpp::CharacterVector preprocess(Rcpp::CharacterVector input, std::string erase, bool lower_case);
RcppExport SEXP _kgrams_preprocess(SEXP inputSEXP, SEXP eraseSEXP, SEXP lower_caseSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::CharacterVector >::type input(inputSEXP);
    Rcpp::traits::input_parameter< std::string >::type erase(eraseSEXP);
    Rcpp::traits::input_parameter< bool >::type lower_case(lower_caseSEXP);
    rcpp_result_gen = Rcpp::wrap(preprocess(input, erase, lower_case));
    return rcpp_result_gen;
END_RCPP
}
// tokenize_sentences
Rcpp::CharacterVector tokenize_sentences(Rcpp::CharacterVector input, std::string EOS, bool keep_first);
RcppExport SEXP _kgrams_tokenize_sentences(SEXP inputSEXP, SEXP EOSSEXP, SEXP keep_firstSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::CharacterVector >::type input(inputSEXP);
    Rcpp::traits::input_parameter< std::string >::type EOS(EOSSEXP);
    Rcpp::traits::input_parameter< bool >::type keep_first(keep_firstSEXP);
    rcpp_result_gen = Rcpp::wrap(tokenize_sentences(input, EOS, keep_first));
    return rcpp_result_gen;
END_RCPP
}
// EOS
std::string EOS();
RcppExport SEXP _kgrams_EOS() {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    rcpp_result_gen = Rcpp::wrap(EOS());
    return rcpp_result_gen;
END_RCPP
}
// BOS
std::string BOS();
RcppExport SEXP _kgrams_BOS() {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    rcpp_result_gen = Rcpp::wrap(BOS());
    return rcpp_result_gen;
END_RCPP
}
// UNK
std::string UNK();
RcppExport SEXP _kgrams_UNK() {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    rcpp_result_gen = Rcpp::wrap(UNK());
    return rcpp_result_gen;
END_RCPP
}

RcppExport SEXP _rcpp_module_boot_Dictionary();
RcppExport SEXP _rcpp_module_boot_Probability();
RcppExport SEXP _rcpp_module_boot_kgramFreqs();

static const R_CallMethodDef CallEntries[] = {
    {"_kgrams_preprocess", (DL_FUNC) &_kgrams_preprocess, 3},
    {"_kgrams_tokenize_sentences", (DL_FUNC) &_kgrams_tokenize_sentences, 3},
    {"_kgrams_EOS", (DL_FUNC) &_kgrams_EOS, 0},
    {"_kgrams_BOS", (DL_FUNC) &_kgrams_BOS, 0},
    {"_kgrams_UNK", (DL_FUNC) &_kgrams_UNK, 0},
    {"_rcpp_module_boot_Dictionary", (DL_FUNC) &_rcpp_module_boot_Dictionary, 0},
    {"_rcpp_module_boot_Probability", (DL_FUNC) &_rcpp_module_boot_Probability, 0},
    {"_rcpp_module_boot_kgramFreqs", (DL_FUNC) &_rcpp_module_boot_kgramFreqs, 0},
    {NULL, NULL, 0}
};

RcppExport void R_init_kgrams(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
