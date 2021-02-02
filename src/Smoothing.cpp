#include "Smoothing.h"
#include <cmath>

using std::pair;

//--------//----------------Smoother----------------//----------//


/// @brief model order setter
void Smoother::set_N (size_t N) 
{ 
        if (N > f_.N()) throw std::domain_error(
                "'N' cannot be larger than the order of the underlying" 
                " k-gram frequency table."
        );
        N_ = N;
        // Initialize prefix for begin of sentences
        padding_ = "";
        for (size_t k = 0; k < N_ - 1; ++k) {
                padding_ += BOS_TOK + " ";
        }
}

/// @brief truncate 'context' to last N - 1 words.
std::string Smoother::truncate (std::string context) const {
        if (N() == 1) return "";
        size_t n_words = 0;
        size_t start = std::string::npos;
        while (n_words < N() - 1) {
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

/// @brief Return sentence probability and number of words in sentence 
/// (useful for computing cross-entropies and perplexities)
/// @param sentence A string. Sentence of which the probability is to be
/// computed.
/// @param log true or false. If true, returns log-probability, otherwise 
/// probability.
/// @return a positive number. Continuation probability of a word.
/// @details Sentences are automatically padded (i.e. no need to include BOS and
/// EOS tokens). In any case, any additional BOS and EOS tokens appearing in the
/// word are automatically ignored.
std::pair<double, size_t> Smoother::operator() (
                const std::string & sentence, bool log
        ) 
const {
        std::string context = padding_, word;
        WordStream ws(sentence);
        
        // Use log-prob for safety (avoid numerical underflow)
        double log_prob = 0.; size_t n_words = 1; // EOS; 
        size_t pos; 
        while((word = ws.pop_word()) != EOS_TOK) {
                // Ignore eventual BOS tokens explicitly included in the user's
                // input.
                if (word == BOS_TOK) continue;
                n_words++;
                // This will call the correct method when implemented by
                // actual smoothers
                log_prob += std::log(this->operator()(word, context));
                // Update context: remove first word and append last
                if (N() > 2) {
                        pos = context.find_first_not_of(" ");
                        pos = context.find_first_of(" ", pos);
                        context = context.substr(pos) + " " + word;
                } else if (N() == 2) {
                        context = word;
                }
        }
        
        // Add final EOS token. This is not automatically in the loop to handle
        // the case where the user explicitly includes a final EOS token,
        // in which case the iteration breaks.
        log_prob += std::log(this->operator()(EOS_TOK, context));
        
        return pair<double, size_t>
                {log ? log_prob : std::exp(log_prob), n_words};
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
        if (word == BOS_TOK or word.find_first_not_of(" ") == std::string::npos) 
                return -1;
        context = truncate(context);
        double kgram_count, penalization = 1.;
        while ((kgram_count = f_.query(context + " " + word)) == 0) {
                backoff(context);
                penalization *= lambda_;
                if (context == "" and f_.query(word) == 0)
                        return 1 / (double)(V() + 2);
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
        if (word == BOS_TOK or word.find_first_not_of(" ") == std::string::npos) 
                return -1;
        context = truncate(context);
        double num = f_.query(context + " " + word) + k_;
        double den = f_.query(context) + k_ * (V() + 2);
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
        if (word == BOS_TOK or word.find_first_not_of(" ") == std::string::npos) 
                return -1;
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
KNSmoother::KNSmoother (const kgramFreqs & f, size_t N, const double D) 
        : Smoother(f, N), D_(D), 
          l_continuations_(std::vector<FrequencyTable>(f.N())),
          r_continuations_(std::vector<FrequencyTable>(f.N())),
          lr_continuations_(std::vector<FrequencyTable>(f.N() - 1))
{
        // Retrieve continuation counts from k-gram counts up to the maximum 
        // order allowed (f.N())
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
                        // Reject kgrams ending in BOS
                        // In this way sum(prob(w|...)) = 1, where w != BOS
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

/// @brief Return Kneser-Ney continuation probability of a word
/// given a context.
/// @param word A string. Word for which the continuation probability
/// is to be computed.
/// @param context A string. Context conditioning the probability of
/// 'word'.
/// @return a positive number. Kneser-Ney continuation
/// probability of 'word' given 'context'.
double KNSmoother::operator() (const std::string & word, std::string context) 
        const {
        // The probability of word 'w' in context 'c' is given by:
        //
        //      Prob(w|c) = ProbDisc(w|c) + BackoffFac(c) * ProbCont(w|c--)
        //
        // where c-- is the backed-off context (remove first word from 'c') and:
        //
        //      ProbDisc(w|c) = [Count(c,w)-D]+ / Count(c)
        //      BackoffFac(c) = 1 - sum_w(ProbDisc(w|c))
        //                    = D * N1+(c,*) / Count(c)
        //      ProbCont(w|c--) = Continuation probability of 'w|c--' 
        //
        // Here N1+(c,*) = (# different words following context 'c') is the
        // continuation count; []+ denotes positive part; the continuation 
        // probability is defined below. For the base case, we replace
        //      ProbCont(w|) = 1 / V,
        // where V is the number of words in the dictionary (without <BOS>)
        
        if (word == BOS_TOK or word.find_first_not_of(" ") == std::string::npos) 
                return -1;
        context = truncate(context); // keep at most N - 1 words
        double den = f_.query(context);
        double num = f_.query(context + " " + word) - D_;
        num = num > 0 ? num : 0;
        
        // Compute ProbDisc(w|c)
        double prob_disc = den != 0 ? num / den : 0;
        
        // Handle separately the 1-gram probability case
        if (context == "") {
                num = f_[1].size() - 1; // N1+(.) without considering <BOS>
                // Compute BackoffFac(c)
                double backoff_fac = den != 0 ? D_ * num / den : 1; 
                // Compute ProbCont(c) (this is potentially > than num!)
                double prob_cont = 1 / (double)(V() + 2);
                return prob_disc + backoff_fac * prob_cont;
        }
        
        // Compute BackoffFac(c)
        // overwrite num which is no longer necessary
        auto p = f_.kgram_code(context); // this is a pair {order, code}
        auto it = r_continuations_[p.first].find(p.second);
        num = it != r_continuations_[p.first].end() ? it->second : 0; 
        double backoff = den != 0 ? D_ * num / den : 1;
        
        // Backoff directly on the k-gram code (stored in p.second)
        // overwrite 'context' with backed off context CODE
        size_t pos = p.second.find_first_of(" ");
        context = (pos != std::string::npos) ? p.second.substr(pos + 1) : "";
        
        // Compute continuation probability
        std::string index_word = f_.index(word);
        double prob_cont = this->prob_cont(index_word, context, p.first);
        return prob_disc + backoff * prob_cont;
}


// Compute continuation probability of word in a given context. 'order' is the
// k-gram order of context, passed for efficiency.
double KNSmoother::prob_cont (
                const std::string & word, std::string context, size_t order
) const {
        // The continuation probability of word 'w' in context 'c' is given by:
        //
        //      ProbCont(w|c) = ProbContDisc(w|c) + 
        //                              BackoffFac(c) * ProbCont(w|c--)
        //
        // where c-- is the backed-off context (remove first word from 'c') and:
        //
        //      ProbContDisc(w|c) = [N1+(*,c,w)-D]+ / N1+(*,c,*)
        //      BackoffFac(c) = 1 - sum_w(ProbContDisc(w|c))
        //                    = D * N1+(c,*) / N1+(*,c,*)
        //      ProbCont(w|c--) = Continuation probability of 'w|c--'
        // For the base case, we replace
        //      ProbCont(w|) = 1 / V,
        // where V is the number of words in the dictionary (without <BOS>)
        
        // Compute denominator of ProbContDisc(w|c)
        auto it = lr_continuations_[order - 1].find(context);
        auto itend = lr_continuations_[order - 1].end();
        double den = it != itend ? it->second : 0;
        
        // Compute numerator of ProbContDisc(w|c)
        it = l_continuations_[order].find(
                context != "" ? context + " " + word : word
        );
        itend = l_continuations_[order].end();
        double num = it != itend ? it->second - D_ : 0;
        num = num > 0 ? num : 0;
        
        // Compute ProbContDisc(w|c)
        double prob_cont_disc = den != 0 ? num / den : 0;
        
        // handle directly the 1-gram probability case
        if (context == "") {
                num = f_[1].size() - 1; // Remove BOS from seen words count.
                double backoff_fac = den != 0 ? D_ * num / den : 1;
                double prob_cont_backoff = 1 / (double)(V() + 2);
                // den == 0 is a silly case which should be barred from existing
                return prob_cont_disc + backoff_fac * prob_cont_backoff;
        }
        
        // Compute BackoffFac(c)
        it = r_continuations_[order - 1].find(context);
        itend = r_continuations_[order - 1].end();
        num = it != itend ? it->second : 0; 
        double backoff_fac = den != 0 ? D_ * num / den : 1;
        
        // Backoff the k-gram code
        size_t pos = context.find_first_of(" ");
        context = (pos != std::string::npos) ? context.substr(pos + 1) : "";
        
        // Compute ProbCont(w|c--)
        double prob_cont_backoff = prob_cont(word, context, order - 1);
        
        return prob_cont_disc + backoff_fac * prob_cont_backoff;
}