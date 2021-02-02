#ifndef WORD_STREAM_H
#define WORD_STREAM_H
#include <string>
#include "special_tokens.h"

class WordStream {
        const std::string & str_;
        size_t len_;
        size_t start_; // start position of current word
        bool eos_;
        size_t end_; // end position of current word
        size_t first (std::string start, size_t pos = 0) 
                { return str_.find_first_of(start, pos); }
        size_t first_not (std::string start, size_t pos = 0) 
                { return str_.find_first_not_of(start, pos); } 
public:
        WordStream (const std::string & str)
                : str_(str),
                  len_(str.length()),
                  start_(first_not(" ")),
                  //eos_(start_ >= len_),
                  eos_(false),
                  end_(start_ >= len_ ? len_ : 0)
        {}
        // Disallow initialization by rvalue reference!
        WordStream(const std::string &&) = delete;
        bool eos () { return eos_; }
        
        std::string pop_word() {
                if ((end_ >= len_) or ((start_ = first_not(" ", end_)) >= len_)) 
                        { eos_ = true; return EOS_TOK; }
                
                if ((end_ = first(" ", start_)) >= len_)
                        return str_.substr(start_);
                return str_.substr(start_, end_ - start_);
        }
}; // class WordStream

#endif // WORD_STREAM_H