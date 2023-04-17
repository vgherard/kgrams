## kgrams v0.1.5

`kgrams` v0.1.2 got archived because the former vignette used an online data 
source which became unavailable. This online source has been replaced by local 
example data installed with the package.

R CMD CHECK produces a Note:

* Namespace in Imports field not imported from: 'RcppProgress'
    All declared Imports should be used.

This note is spurious, as the imported package is used. It is only called from
C++ source code, which may be the reason behind this false positive.

---

### Follow-up to CRAN review

#### Comment 1

 The Title field should be in title case. Current version is:
 'Classical k-gram Language Models'
 In title case that is:
 'Classical k-Gram Language Models'
 
"k-gram" is a mathematical term, as such it should be considered as a 
single word. In particular, "gram" does not need to be capitalized.

#### Comment 2

Please omit the redundant "Tools for" at the beginning of your description.

Done.

#### Comment 3

If there are references describing the methods in your package, please add these in the description field of your DESCRIPTION file in the form
authors (year) <doi:...>
authors (year) <arXiv:...>
authors (year, ISBN:...)
or if those are not available: <https:...>
with no space after 'doi:', 'arXiv:', 'https:' and angle brackets for auto-linking.
(If you want to add a title as well please put it in quotes: "Title")

The package implements a manifold of mathematical methods for language models 
(that can, to some extent, be considered "classical" literature). These are 
properly referenced throughout the package documentation. 
Documenting them in the DESCRIPTION would require citing tens of articles (some
of them published in the beginning of XX-th century), which I think is beside 
the point.

#### Comment 4

\dontrun{} should only be used if the example really cannot be executed (e.g. because of missing additional software, missing API keys, ...) by the user. That's why wrapping examples in \dontrun{} adds the comment ("# Not run:") as a warning for the user.
Does not seem necessary.
Please unwrap the examples if they are executable in < 5 sec, or replace \dontrun{} with \donttest{}.

The only two examples that are left wrapped in the \dontrun{} command
cannot be run with 100% confidence - because they reference a dummy 
"my_text_file.txt" local or online resource, which does not exist. I believe
this is the most transparent way to document (abstractly) the relevant features
here.
