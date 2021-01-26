#include <Rcpp.h>
#include <vector>
#include <string>
#include <regex>

void tokenize_sentences(std::string & line, 
                        std::vector<std::string> & res,
                        const std::regex& _EOS, 
                        bool keep_first){
        auto itstart = std::sregex_iterator(line.begin(), line.end(), _EOS);
        auto itend = std::sregex_iterator();
        
        size_t start = 0, end;
        std::string tmp;
        for (std::sregex_iterator it = itstart; it != itend; ++it) {
                std::smatch m = *it;
                end = m.position();
                res.push_back(
                        keep_first ? 
                        line.substr(start, end - start) + " " + line[end] :
                        line.substr(start, end - start)
                );
                start = end + m.length();
        }
        
        if (start != std::string::npos)
                res.push_back(line.substr(start));
}

//' Sentence tokenizer
//'
//' Extract sentences from a batch of text lines.
//'
//' @export
//'
//' @author Valerio Gherardi
//' @md
//'
//' @param input a character vector.
//' @param EOS a regular expression matching an End-Of-Sentence delimiter.
//' @param keep_first TRUE or FALSE? Should the first character of the matches
//' be appended to the returned sentences (with a space)?
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
//' If \code{keep_first} is \code{FALSE}, the delimiters are stripped off from 
//' the returned sequences, which means that all delimiters are treated 
//' symmetrically.
//' 
//' In the absence of any \code{EOS} delimiter, \code{tokenize_sentences()} 
//' returns the input as is, since parts of text corresponding to different 
//' entries of the \code{input} vector are understood as parts of separate 
//' sentences.
//' @examples
//' tokenize_sentences("Hi there! I'm using `sbo`.")
// [[Rcpp::export]]
std::vector<std::string> tokenize_sentences(std::vector<std::string> input,
                                            std::string EOS = "[.?!:;]+",
                                            bool keep_first = false)
{
        if (EOS == "") return input;
        std::vector<std::string> res;
        std::regex _EOS(EOS);
        std::string tmp;
        for(Rcpp::String str : input) {
                tmp = str;
                tokenize_sentences(tmp, res, _EOS, keep_first);
        }
                
        return res;
}
