#include "special_tokens.h"
#include <Rcpp.h>
using namespace Rcpp;

//' @export
// [[Rcpp::export]]
std::string EOS () { return EOS_TOK; }
//' @export
// [[Rcpp::export]]
std::string BOS () { return BOS_TOK; }
//' @export
// [[Rcpp::export]]
std::string UNK () { return UNK_TOK; }