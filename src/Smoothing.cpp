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

/// @brief truncate 'context' to last k - 1 words.
std::string Smoother::truncate (std::string context, size_t k) const {
        if (k == 1) return "";
        size_t n_words = 0;
        size_t start = std::string::npos;
        while (n_words < k - 1) {
                start = context.find_last_not_of(" ", start);
                if (start == std::string::npos or start == 0) 
                        return context;
                start = context.find_last_of(" ", start);
                if (start == std::string::npos or start == 0) 
                        return context;
                ++n_words;
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
                ++n_words;
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
void Smoother::backoff (std::string & context) const 
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
        context = truncate(context, N_);
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
        context = truncate(context, N_);
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
        context = truncate(context, N_);
        double den = f_.query(context);
        return den > 0 ? f_.query(context + " " + word) / den : -1;
}

//--------//----------------KNSmoother----------------//--------//



/// @brief update satellite values of KNSmoother
void KNFreqs::update () 
{
        // Reinitialize l_, r_, and lr_... is it possible to do something more
        // clever?
        l_ = FreqTablesVec(f_.N());
        r_ = FreqTablesVec(f_.N());
        lr_ = FreqTablesVec(f_.N() - 1);
        
        // Retrieve continuation counts from k-gram counts up to the maximum 
        // order allowed (f.N())
        std::string kgram_code;
        size_t l_pos, r_pos;
        for (size_t k = 1; k <= f_.N(); ++k) {
                const std::unordered_map<std::string, size_t> & 
                        kgram_codes(f_[k]);
                auto itend = kgram_codes.end();
                for (auto it = kgram_codes.begin(); it != itend; ++it) {
                        // kgram_code is always of the form "n_1 n_2 ... n_k"
                        // with exactly one space between word codes
                        kgram_code = it->first;
                        if (k > 1) {
                                r_pos = kgram_code.find_last_of(" ");
                                l_pos = kgram_code.find_first_of(" ") + 1;
                        } else {
                                r_pos = 0;
                                l_pos = kgram_code.length();
                        }
                        // Reject kgrams ending in BOS
                        // In this way sum(prob(w|...)) = 1, where w != BOS
                        if (kgram_code.substr(r_pos + (k > 1)) == BOS_IND)
                                continue;
                        // Add right continuation counts
                        ++r_[k - 1][kgram_code.substr(0, r_pos)];
                        // Add left continuation counts
                        ++l_[k - 1][kgram_code.substr(l_pos)];
                        // Add left right continuation counts if k >= 2
                        if (k == 1) continue;
                        else if (k == 2) { ++lr_[0][""]; continue; }
                        ++lr_[k - 2][ 
                                kgram_code.substr(l_pos, r_pos - l_pos)
                                ];
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
        context = truncate(context, N_); // keep at most N - 1 words
        double den = f_.query(context);
        double num = f_.query(context + " " + word) - D_;
        num = num > 0 ? num : 0;
        
        // Compute ProbDisc(w|c)
        double prob_disc = den > 0 ? num / den : 0;
        
        // Handle separately the 1-gram probability case
        if (context == "") {
                num = f_[1].size() - 1; // N1+(.) without considering <BOS>
                // Compute BackoffFac(c)
                double backoff_fac = den > 0 ? D_ * num / den : 1; 
                // Compute ProbCont(c) (this is potentially > than num!)
                double prob_cont = 1 / (double)(V() + 2);
                return prob_disc + backoff_fac * prob_cont;
        }
        
        // Compute BackoffFac(c)
        // overwrite num which is no longer necessary
        auto p = f_.kgram_code(context); // this is a pair {order, code}
        double backoff_fac = den != 0 ? 
                D_ * knf_.r().query(p.first, p.second) / den : 1;
        
        // Backoff directly on the k-gram code (stored in p.second)
        // overwrite 'context' with backed off context CODE
        size_t pos = p.second.find_first_of(" ");
        context = (pos != std::string::npos) ? p.second.substr(pos + 1) : "";
        
        // Compute continuation probability
        std::string index_word = f_.index(word);
        double prob_cont = this->prob_cont(index_word, context, p.first);
        return prob_disc + backoff_fac * prob_cont;
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
        double den = knf_.lr().query(order - 1, context);
        
        // Compute numerator of ProbContDisc(w|c)
        double num = knf_.l().query(
                order, context != "" ? context + " " + word : word
                ) - D_;
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
        double backoff_fac = den != 0 ? 
                D_ * knf_.r().query(order - 1, context) / den : 1;
        
        // Backoff the k-gram code
        size_t pos = context.find_first_of(" ");
        context = (pos != std::string::npos) ? context.substr(pos + 1) : "";
        
        // Compute ProbCont(w|c--)
        double prob_cont_backoff = prob_cont(word, context, order - 1);
        
        return prob_cont_disc + backoff_fac * prob_cont_backoff;
}

//--------//----------------mKNSmoother----------------//--------//

/// @brief update satellite values of KNSmoother
void mKNFreqs::update () 
{
        size_t N = f_.N();
        // Reinitialize l_, r_, and lr_... is it possible to do something more
        // clever?
        l_ = FreqTablesVec(N);
        r1_ = FreqTablesVec(N);
        r2_ = FreqTablesVec(N);
        r3p_ = FreqTablesVec(N);
        r1low_ = FreqTablesVec(N - 1);
        r2low_ = FreqTablesVec(N - 1);
        r3plow_ = FreqTablesVec(N - 1);
        lr_ = FreqTablesVec(N - 1);
        
        // Compute left and left-right continuation counts
        std::string kgram_code;
        size_t l_pos, r_pos;
        for (size_t k = 1; k <= N; ++k) {
                const std::unordered_map<std::string, size_t> & 
                        freqs(f_[k]);
                auto itend = freqs.end();
                for (auto it = freqs.begin(); it != itend; it++) {
                        // kgram_code is always of the form "n_1 n_2 ... n_k"
                        // with exactly one space between word codes
                        kgram_code = it->first;
                        if (k > 1) {
                                r_pos = kgram_code.find_last_of(" ");
                                l_pos = kgram_code.find_first_of(" ") + 1;
                        } else {
                                r_pos = 0;
                                l_pos = kgram_code.length();
                        }
                        // Reject kgrams ending in BOS
                        // In this way sum(prob(w|...)) = 1, where w != BOS
                        if (kgram_code.substr(r_pos + (k > 1)) == BOS_IND)
                                continue;
                        // Add right continuation counts
                        switch(it->second) {
                        case 1: 
                                ++r1_[k - 1][kgram_code.substr(0, r_pos)]; 
                                break;
                        case 2: 
                                ++r2_[k - 1][kgram_code.substr(0, r_pos)]; 
                                break;
                        default: 
                                ++r3p_[k - 1][kgram_code.substr(0, r_pos)]; 
                                break;
                        }
                        // Add left continuation counts
                        ++l_[k - 1][kgram_code.substr(l_pos)];
                        // Add left right continuation counts if k >= 2
                        if (k == 1) continue;
                        else if (k == 2) { ++lr_[0][""]; continue; }
                        ++lr_[k - 2][ 
                                kgram_code.substr(l_pos, r_pos - l_pos)
                                ];
                }
        }
        
        // Compute right continuation counts for when predicting at low order 
        for (size_t k = 1; k < N; ++k) {
                const std::unordered_map<std::string, size_t> &  
                        freqs(l_[k]);
                auto itend = freqs.end();
                for (auto it = freqs.begin(); it != itend; ++it) {
                        // kgram_code is always of the form "n_1 n_2 ... n_k"
                        // with exactly one space between word codes
                        kgram_code = it->first;
                        r_pos = k > 1 ? kgram_code.find_last_of(" ") : 0;
                        
                        // Reject kgrams ending in BOS
                        // In this way sum(prob(w|...)) = 1, where w != BOS
                        if (kgram_code.substr(r_pos + (k > 1)) == BOS_IND)
                                continue;
                        
                        // Eliminate last word's code from kgram_code
                        kgram_code = kgram_code.substr(0, r_pos);
                                
                        switch(it->second) {
                        case 1: ++r1low_[k - 1][kgram_code]; break;
                        case 2: ++r2low_[k - 1][kgram_code]; break;
                        default: ++r3plow_[k - 1][kgram_code]; break;
                        }
                }
        }
}

/// @brief Return Modified Kneser-Ney continuation probability of a word
/// given a context.
/// @param word A string. Word for which the continuation probability
/// is to be computed.
/// @param context A string. Context conditioning the probability of
/// 'word'.
/// @return a positive number. Modified Kneser-Ney continuation
/// probability of 'word' given 'context'.
double mKNSmoother::operator() (const std::string & word, std::string context) 
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
        
        // Handle n.d. cases
        if (word == BOS_TOK or word.find_first_not_of(" ") == std::string::npos) 
                return -1;
        // keep at most N - 1 words
        context = truncate(context, N_); 
        
        // Temporary variable needed below; this is a pair {order, code} 
        auto p = f_.kgram_code(context);
        
        // Compute ProbDisc(w|c)
        double prob_disc;
        double den = f_.query(context);
        if (den > 0) {
                double num = f_.query(context + " " + word);
                discount(num);
                prob_disc = num / den;
        }
        else 
                prob_disc = 0.;
        
        // Compute BackoffFac(c)
        double backoff_fac;
        if (den > 0) {
                double N1 = mknf_.r1().query(p.first, p.second);
                double N2 = mknf_.r2().query(p.first, p.second);
                double N3p = mknf_.r3p().query(p.first, p.second);
                backoff_fac = (D1_ * N1 + D2_ * N2 + D3_ * N3p) / den;
        } else 
                backoff_fac = 1.;
        
        // Compute ProbCont(w|c--)
        double prob_cont;
        std::string word_index = f_.index(word);
        size_t pos = p.second.find_first_of(" ");
        p.second = (pos != std::string::npos) ? p.second.substr(pos + 1) : "";
        prob_cont = this->prob_cont(word_index, p.second, p.first);  
        
        // Final result
        return prob_disc + backoff_fac * prob_cont;
}


// Compute continuation probability of word in a given context. 'order' is the
// k-gram order of context, passed for efficiency.
double mKNSmoother::prob_cont (
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
        if (order == 0)
                return 1 / (double)(V() + 2);
        
        // Compute ProbContDisc(w|c)
        double prob_cont_disc;
        double den = mknf_.lr().query(order - 1, context);
        if (den > 0){
                double num = mknf_.l().query(
                        order, context != "" ? context + " " + word : word
                );
                discount(num);
                prob_cont_disc = num / den;
        } else
                prob_cont_disc = 0;
        
        // Compute BackoffFac(c)
        double backoff_fac;
        if (den > 0) {
                double N1 = mknf_.r1low().query(order - 1, context);
                double N2 = mknf_.r2low().query(order - 1, context);
                double N3p = mknf_.r3plow().query(order - 1, context);
                backoff_fac = (D1_ * N1 + D2_ * N2 + D3_ * N3p) / den;
        } else backoff_fac = 1.;
                   
        
        // Compute ProbCont(w|c--)
        double prob_cont_backoff;
        size_t pos = context.find_first_of(" ");
        context = (pos != std::string::npos) ? context.substr(pos + 1) : "";
        prob_cont_backoff = this->prob_cont(word, context, order - 1);  
        
        // Final result
        return prob_cont_disc + backoff_fac * prob_cont_backoff;
}



//--------//----------------AbsSmoother----------------//--------//


void RFreqs::update () 
{
        // Reinitialize l_, r_, and lr_... is it possible to do something more
        // clever?
        r_ = std::vector<FrequencyTable>(f_.N());
        
        // Retrieve continuation counts from k-gram counts up to the maximum 
        // order allowed (f.N())
        std::string kgram_code;
        size_t r_pos;
        for (size_t k = 1; k <= f_.N(); ++k) {
                const FrequencyTable & kgram_codes(f_[k]);
                auto itend = kgram_codes.end();
                for (auto it = kgram_codes.begin(); it != itend; ++it) {
                        // kgram_code is always of the form "n_1 n_2 ... n_k"
                        // with exactly one space between word codes
                        kgram_code = it->first;
                        if (k > 1) {
                                r_pos = kgram_code.find_last_of(" ");
                        } else {
                                r_pos = 0;
                        }
                        // Reject kgrams ending in BOS
                        // In this way sum(prob(w|...)) = 1, where w != BOS
                        if (kgram_code.substr(r_pos + (k > 1)) == BOS_IND)
                                continue;
                        // Add right continuation counts
                        ++r_[k - 1][kgram_code.substr(0, r_pos)];
                }
        }
}

/// @brief Return Absolute Discount continuation probability of a word
/// given a context.
/// @param word A string. Word for which the continuation probability
/// is to be computed.
/// @param context A string. Context conditioning the probability of
/// 'word'.
/// @return a positive number. Absolute Discount continuation
/// probability of 'word' given 'context'.
double AbsSmoother::operator() (const std::string & word, std::string context) 
        const {
        // The probability of word 'w' in context 'c' is given by:
        //
        //      Prob(w|c) = ProbDisc(w|c) + BackoffFac(c) * Prob(w|c--)
        //
        // where c-- is the backed-off context (remove first word from 'c') and:
        //
        //      ProbDisc(w|c) = [Count(c,w)-D]+ / Count(c)
        //      BackoffFac(c) = 1 - sum_w(ProbDisc(w|c))
        //                    = D * N1+(c,*) / Count(c)
        //      Prob(w|c--) = Lowest order probability of 'w|c--' 
        //
        // Here N1+(c,*) = (# different words following context 'c') is the
        // continuation count; []+ denotes positive part; the continuation 
        // probability is defined below. For the base case, we replace
        //      Prob(w|) = 1 / V,
        // where V is the number of words in the dictionary (without <BOS>)
        
        if (word == BOS_TOK or word.find_first_not_of(" ") == std::string::npos) 
                return -1;
        context = truncate(context, N_); // keep at most N - 1 words
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
        double backoff_fac = den != 0 ? D_ * absf_.query(context) / den : 1;
        
        // Compute lower order probability
        backoff(context);
        double prob_backoff = this->operator()(word, context);
        return prob_disc + backoff_fac * prob_backoff;
}

//--------//----------------WBSmoother----------------//--------//

/// @brief Return Witten-Bell continuation probability of a word
/// given a context.
/// @param word A string. Word for which the continuation probability
/// is to be computed.
/// @param context A string. Context conditioning the probability of
/// 'word'.
/// @return a positive number. Witten-Bell continuation
/// probability of 'word' given 'context'.
double WBSmoother::operator() (const std::string & word, std::string context) 
        const {
        // The probability of word 'w' in context 'c' is given by:
        //
        //      Prob(w|c) = ProbHigh(w|c) + BackoffFac(c) * Prob(w|c--)
        //
        // where c-- is the backed-off context (remove first word from 'c') and:
        //
        //      ProbHigh(w|c) = Count(c,w) / (Count(c) + N1+(c,*))
        //      BackoffFac(c) = 1 - sum_w(ProbDisc(w|c))
        //                    = N1+(c,*) / (Count(c) + N1+(c,*))
        //      Prob(w|c--) = Lowest order probability of 'w|c--' 
        //
        // Here N1+(c,*) = (# different words following context 'c') is the
        // continuation count; []+ denotes positive part; the continuation 
        // probability is defined below. For the base case, we replace
        //      Prob(w|) = 1 / V,
        // where V is the number of words in the dictionary (without <BOS>)
        
        if (word == BOS_TOK or word.find_first_not_of(" ") == std::string::npos) 
                return -1;
        context = truncate(context, N_); // keep at most N - 1 words
        double c_context = f_.query(context);
        double N1p_context = wbf_.query(context);
        double c_kgram = f_.query(context + " " + word);
        double den = c_context + N1p_context;
        double prob_backoff;
        if (context == "")
                prob_backoff = 1 / (double)(V() + 2);
        else {
                backoff(context);
                prob_backoff = this->operator()(word, context);
        }
        
        double res = den == 0 ? prob_backoff :
                (c_kgram + N1p_context * prob_backoff) 
                / (c_context + N1p_context);
                
        return res;
}


int main () {
        std::vector<std::string> text = {"a a b a b a"};
        kgramFreqs f(2);
        f.process_sentences(text);
        mKNSmoother m(f, 2, 0.25, 0.5, 0.75);
        double prob_a = m("a", "b");
        double prob_b = m("b", "b");
        double prob_eos = m(EOS_TOK, "b");
        double prob_unk = m(UNK_TOK, "b");
        double sum = prob_a + prob_b + prob_eos + prob_unk;
        return 0;
}