#include "Smoothing.h"
#include <iostream> // remove

//--------//----------------Smoother----------------//----------//

/// @brief truncate 'context' to last N - 1 words.
std::string Smoother::truncate (std::string context) const {
        size_t n_words = 0;
        size_t start = std::string::npos;
        while (n_words < N_ - 1) {
                start = context.find_last_not_of(" ", start);
                if (start == std::string::npos or start == 0) 
                        return context;
                start = context.find_last_of(" ", start);
                if (start == std::string::npos or start == 0) 
                        return context;
                n_words++;
        }
        return context.substr(start);
}

//--------//----------------SBOSmoother----------------//--------//

/// @brief Remove first word from context
void SBOSmoother::backoff (std::string & context) const 
{
        size_t pos = context.find_first_not_of(" ");
        pos = context.find_first_of(" ", pos);
        if (pos == std::string::npos or 
                    context.find_first_not_of(" ", pos) == std::string::npos) 
                context.erase();
        else
                context = context.substr(pos);
}

/// @brief Return Stupid Backoff continuation score of a word given a 
/// context.
/// @param word A string. Word for which the continuation score 
/// is to be computed.
/// @param context A string. Context conditioning the score of 
/// 'word'. Passed by value.
/// @return a positive number. Stupid Backoff continuation score of
/// 'word' given 'context'.
double SBOSmoother::operator() (const std::string & word, std::string context) 
const {
        context = truncate(context);
        double kgram_count, penalization = 1.;
        while ((kgram_count = f_.query(context + " " + word)) == 0) {
                backoff(context);
                penalization *= lambda_;
                if (context == "" and f_.query(word) == 0)
                        return 0;
        }
        return penalization * kgram_count / f_.query(context);
}

//--------//----------------AddkSmoother----------------//--------//

/// @brief Return Add-k continuation probability of a word 
/// given a context.
/// @param word A string. Word for which the continuation probability 
/// is to be computed.
/// @param context A string. Context conditioning the probability of 
/// 'word'.
/// @return a positive number. Add-k continuation probability of
/// 'word' given 'context'.
double AddkSmoother::operator() (const std::string & word, std::string context)
const {
        context = truncate(context);
        double num = f_.query(context + " " + word) + k_;
        double den = f_.query(context) + k_ * (V_ + 2);
        return num / den;
}

//--------//----------------MLSmoother----------------//--------//

/// @brief Return Maximum-Likelihood continuation probability of a word 
/// given a context.
/// @param word A string. Word for which the continuation probability 
/// is to be computed.
/// @param context A string. Context conditioning the probability of 
/// 'word'.
/// @return a positive number. Maximum-Likelihood continuation 
/// probability of 'word' given 'context'.
double MLSmoother::operator() (const std::string & word, std::string context)
const {
        context = truncate(context);
        double den = f_.query(context);
        if (den == 0)
                return -1;
        else
                return f_.query(context + " " + word) / den;
}

//--------//----------------KNSmoother----------------//--------//



/// @brief Initialize an AddkSmoother from a kgramFreqs object with a
/// fixed constant 'k'.
/// @param f a kgramFreqs class object. k-gram frequency table from which
/// "bare" k-gram counts are read off.
KNSmoother::KNSmoother (const kgramFreqs & f, const double D) 
        : Smoother(f), D_(D), 
          l_continuations_(std::vector<FrequencyTable>(N_)),
          r_continuations_(std::vector<FrequencyTable>(N_)),
          lr_continuations_(std::vector<FrequencyTable>(N_ - 1))
{
        // Retrieve continuation counts from k-gram counts
        std::string kgram_code;
        size_t l_pos, r_pos;
        for (size_t k = 2; k <= f.N(); ++k) {
                const FrequencyTable & kgram_codes(f[k]);
                auto itend = kgram_codes.end();
                for (auto it = kgram_codes.begin(); it != itend; it++) {
                        // kgram_code is always of the form "n_1 n_2 ... n_k"
                        // with exactly one space between word codes
                        kgram_code = it->first;
                        r_pos = kgram_code.find_last_of(" ");
                        if (kgram_code.substr(r_pos + 1) == BOS_IND)
                                continue;
                        l_pos = kgram_code.find_first_of(" ") + 1;
                        l_continuations_[k - 1][kgram_code.substr(l_pos)]++;
                        
                        r_continuations_[k - 1][kgram_code.substr(0, r_pos)]++;
                        if (k == 2) { lr_continuations_[0][""]++; continue; }
                        lr_continuations_[k - 2][ 
                                kgram_code.substr(l_pos, r_pos - l_pos)
                                ]++;
                }
        }
        
}


//--------Probabilities--------//

/// @brief Return Maximum-Likelihood continuation probability of a word
/// given a context.
/// @param word A string. Word for which the continuation probability
/// is to be computed.
/// @param context A string. Context conditioning the probability of
/// 'word'.
/// @return a positive number. Maximum-Likelihood continuation
/// probability of 'word' given 'context'.
double KNSmoother::operator() (const std::string & word, std::string context) 
const {
        context = truncate(context);
        double den = f_.query(context);
        double num = f_.query(context + " " + word) - D_;
        num = num > 0 ? num : 0;
        
        // Compute probability part
        double prob_part = den != 0 ? num / den : 0;
        
        // handle directly the 1-gram probability case
        if (context == "") {
                if (den == 0) return 0;
                num = f_[1].size() - 1; // Remove BOS from seen words count.
                double backoff_fac = den != 0 ? D_ * num / den : 1;
                double cont_prob = 1 / (double)(f_.V() + 2);
                // den == 0 is a silly case which should be barred from existing
                return prob_part + backoff_fac * cont_prob;
                
        }
                
        
        // Compute backoff factor 
        // overwrite num which is no more necessary
        auto p = f_.kgram_code(context);
        auto it = r_continuations_[p.first].find(p.second);
        num = it != r_continuations_[p.first].end() ? it->second : 0; 
        double backoff_fac = den != 0 ? D_ * num / den : 1;
        
        // Backoff directly on the k-gram code (stored in p.second)
        // overwrite 'context' with backed off context code
        size_t pos = p.second.find_first_of(" ");
        context = (pos != std::string::npos) ? p.second.substr(pos + 1) : "";
        
        // Compute continuation probability
        std::string index_word = f_.index(word);
        double cont_prob = continuation_probability(index_word, 
                                                    context,
                                                    p.first);
        
        return prob_part + backoff_fac * cont_prob;
}

double KNSmoother::continuation_probability (const std::string & word, 
                                             std::string context,
                                             size_t order) 
const {
        // Compute den
        auto it = lr_continuations_[order - 1].find(context);
        auto itend = lr_continuations_[order - 1].end();
        double den = it != itend ? it->second : 0;
        
        // Compute num
        it = l_continuations_[order].find(
                context != "" ? context + " " + word : word);
        itend = l_continuations_[order].end();
        double num = it != itend ? it->second - D_ : 0;
        num = num > 0 ? num : 0;
        
        // Compute probability part
        double prob_part = den != 0 ? num / den : 0;
        
        // handle directly the 1-gram probability case
        if (context == "") {
                num = f_[1].size() - 1; // Remove BOS from seen words count.
                double backoff_fac = den != 0 ? D_ * num / den : 1;
                double cont_prob = 1 / (double)(f_.V() + 2);
                // den == 0 is a silly case which should be barred from existing
                return prob_part + backoff_fac * cont_prob;
        }
                
        
        // Compute backoff factor 
        // overwrite num which is no more necessary
        it = r_continuations_[order - 1].find(context);
        itend = r_continuations_[order - 1].end();
        num = it != itend ? it->second : 0; 
        double backoff_fac = den != 0 ? D_ * num / den : 1;
        
        // Backoff the k-gram code
        size_t pos = context.find_first_of(" ");
        context = (pos != std::string::npos) ? context.substr(pos + 1) : "";
        
        // Compute continuation probability
        double cont_prob = continuation_probability(word, 
                                                    context,
                                                    order - 1);
        
        return prob_part + backoff_fac * cont_prob;
}

int main () {
        kgramFreqs f(3);
        std::vector<std::string> sentences{"a b a b a"};
        f.process_sentences(sentences);
        KNSmoother kn(f, 0.75);
        double prob_a = kn.operator()("a", "a b");
        double prob_b = kn.operator()("b", "a b");
        double prob_EOS = kn.operator()(EOS_TOK, "a b");
        double prob_UNK = kn.operator()(UNK_TOK, "a b");
        return 0;
}