#ifndef UTILS_H
#define UTILS_H

template<class T>
class CircularBuffer {
        size_t size_;
        size_t pos_;
        std::vector<T> stream_;
public:
        // Constructor, initializing first size_ - 1 positions to 'init'. 
        CircularBuffer (size_t size, T init) 
                : size_(size), pos_(0), stream_(size, init) {}
        void lshift () { pos_ = (pos_ + 1) % size_; }
        void rshift () { pos_ = pos_ > 0 ? pos_ - 1 : size_ - 1; }
        const T & read ()  { return stream_[pos_]; }
        void write (const T & t)  { stream_[pos_] = t; }
};

#endif // UTILS_H