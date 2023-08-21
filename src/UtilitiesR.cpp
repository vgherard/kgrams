#include <vector>
#include <string>
#include <regex>
#include <Rcpp.h>

using namespace Rcpp;

// [[Rcpp::export]]
CharacterVector preprocess_cpp(
        CharacterVector input, 
        std::string erase = "[^.?!:;'[:alnum:][:space:]]",
        bool lower_case = true
        )
{
        std::regex erase_(erase);
        std::string temp;
        auto itend = input.end();
        for(auto it = input.begin(); it != itend; ++it) {
                if (*it == Rcpp::NA)
                        continue;
                temp = *it;
                if (erase != "") temp = std::regex_replace(temp, erase_, "");
                if (lower_case) for (char& c : temp) c = tolower(c);
                *it = temp;
        }
        return input;
}

size_t tknz_sent(
                std::string &, std::vector<std::string> &, const std::regex &, bool
);

// [[Rcpp::export]]
Rcpp::CharacterVector tknz_sent_cpp(Rcpp::CharacterVector input,
                                    std::string EOS = "[.?!:;]+",
                                    bool keep_first = false)
{
        if (EOS == "") 
                return input;
        size_t len = input.size();
        std::vector<std::vector<std::string> > tmp(len);
        std::regex _EOS(EOS);
        
        size_t tokenized = 0;
        std::string line;
        for (size_t i = 0; i < len; ++i) {
                if (input[i] == Rcpp::NA)
                        stop("tknz_sent() cannot handle NA input.");
                line = input[i];
                tokenized += tknz_sent(line, tmp[i], _EOS, keep_first);
        }
        
        Rcpp::CharacterVector res(tokenized);
        size_t j = 0;
        for (size_t i = 0; i < len; ++i) {
                for (const std::string & sentence : tmp[i]) {
                        res[j] = sentence;
                        j++;
                }
        }
        
        return res;
}

size_t tknz_sent(std::string & line, 
                 std::vector<std::string> & line_res,
                 const std::regex& _EOS,
                 bool keep_first
                 )
{
        auto itstart = std::sregex_iterator(line.begin(), line.end(), _EOS);
        auto itend = std::sregex_iterator();
        
        size_t start = line.find_first_not_of(" "), end;
        if (start == std::string::npos)
                return 0;
        
        std::string tmp;
        for (std::sregex_iterator it = itstart; it != itend; ++it) {
                std::smatch m = *it;
                end = m.position();
                line_res.push_back(
                        keep_first ?
                line.substr(start, end - start) + " " + line[end] :
                        line.substr(start, end - start)
                );
                start = line.find_first_not_of(" ", end + m.length());
        }
        
        if (start != std::string::npos)
                line_res.push_back(line.substr(start));
        
        return line_res.size();
}
