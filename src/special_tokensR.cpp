#include "special_tokens.h"
#include <Rcpp.h>
using namespace Rcpp;

//' @rdname special_tokens
//' @export
// [[Rcpp::export]]
std::string EOS () { return EOS_TOK; }

//' @rdname special_tokens
//' @export
// [[Rcpp::export]]
std::string BOS () { return BOS_TOK; }

//' @rdname special_tokens
//' @export
// [[Rcpp::export]]
std::string UNK () { return UNK_TOK; }