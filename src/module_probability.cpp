#include <Rcpp.h>
#include "kgramFreqs.h"
using namespace Rcpp;

std::string backoff (std::string context) {
        size_t pos = context.find_first_not_of(" ");
        pos = context.find_first_of(" ", pos);
        if (pos == std::string::npos) 
                return "";
        return context.substr(pos);
}

RCPP_EXPOSED_CLASS(kgramFreqs);
Rcpp::NumericVector probability_sbo(kgramFreqs & f,
                                    Rcpp::CharacterVector word,
                                    std::string context,
                                    double lambda)
{
        size_t len = word.length();
        Rcpp::NumericVector res(len);

        std::string tmp_word, tmp_context, tmp_kgram;
        double kgram_count, penalization;
        for (size_t i = 0; i < len; ++i) {
                penalization = 1.;
                tmp_word = word[i];
                tmp_context = context;
                tmp_kgram = tmp_context + " " + word[i];
                while ((kgram_count = f.query(tmp_kgram)) == 0) {
                        tmp_context = backoff(tmp_context);
                        tmp_kgram = tmp_context + " " + tmp_word;
                        penalization *= lambda;
                }
                res[i] = penalization * kgram_count / f.query(tmp_context);
        }

        return res;
}

RCPP_MODULE(probability) {
        function("probability_sbo", &probability_sbo)
        ;
}
