## kgrams v0.1.4

`kgrams` v0.1.2 got archived because the former vignette used an online data 
source which became unavailable. This online source has been replaced by local 
example data installed with the package.

R CMD CHECK produces a Note:

* Namespace in Imports field not imported from: 'RcppProgress'
    All declared Imports should be used.

This note is spurious, as the imported package is used. It is only called from
C++ source code, which may be the reason behind this false positive.