#include <vector>
#include <string>
#include <Rcpp.h>

void tokenize_sentences(std::string line, 
                        Rcpp::CharacterVector& res, 
                        std::string EOS,
                        std::string SOS)
{
         
        size_t start = 0, end; char eos_tok;
        while((end = line.find_first_of(EOS, start)) != std::string::npos) {
                eos_tok = line[end];
                res.push_back(line.substr(start, end - start) + " " + eos_tok);
                start = line.find_first_not_of(SOS, end);
        }
        if (start != std::string::npos)
                res.push_back(line.substr(start, end - start));
}

//' Sentence tokenizer
//'
//' Extract sentences from a batch of text lines.
//'
//' @author Valerio Gherardi
//' @md
//'
//' @param input a character vector.
//' @param EOS a length one character vector listing all (single character)
//' end-of-sentence tokens.
//' @param append_EOS_tokens \code{TRUE} or \code{FALSE}. Should EOS tokens be
//' appended at the end of the returned sentences?
//' @return a character vector, each entry of which corresponds to a single
//' sentence.
//' @details
//' \code{tokenize_sentences()} splits text into sentences using a list of 
//' single character delimiters, specified by the parameter \code{EOS}. 
//' Specifically, when an EOS token is found, the next sentence begins at the
//' first position in the input string not containing any of the EOS tokens 
//' \emph{or white space} (so that entries like \code{"Hi there!!!"} or 
//' \code{"Hello . . ."} are both recognized as a single sentence).
//' 
//' If \code{append_EOS_tokens} is \code{TRUE}, the corresponding punctuation
//' is appended (separated by a space) at the end of the returned sentences.
//' This can be useful if one wants to consider punctuation characters as 
//' separate tokens in a dictionary. Notice that it is still possible to have
//' unterminated sentences: for instance, the string \code{"Hi! Anybody here"}
//' would be tokenized as \code{c("Hi !", "Anybody here")} with the default
//' parameters.
//' 
//' In the absence of any \code{EOS} delimiter, \code{tokenize_sentences()} 
//' returns the input as is, since parts of text corresponding to different 
//' entries of the \code{input} vector are understood as parts of separate 
//' sentences.
//' 
//' @examples
//' tokenize_sentences("Hi there! This is an example.")
//' tokenize_sentences("Hi there! This is an example.", append_EOS_tokens = F)
//' @export
// [[Rcpp::export]]
Rcpp::CharacterVector tokenize_sentences(Rcpp::CharacterVector input,
                                         std::string EOS = ".?!:;",
                                         bool append_EOS_tokens = true)
{
        std::string SOS = " " + EOS;
        if(EOS == "") 
                return input;
        Rcpp::CharacterVector res;
        for (Rcpp::String line : input) {
                tokenize_sentences(line, res, EOS, SOS);
        }
        return res;
}
