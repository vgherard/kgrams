## kgrams v0.2.1

This is a patch release fixing the failure in CRAN tests following the recent 
updates to the waldo package - cf. #32.

The package has been checked through the Win-builder and Mac-builder,
as well as with the RHub service.

R CMD CHECK consistently produce a NOTE:

* Namespace in Imports field not imported from: 'RcppProgress'
    All declared Imports should be used.

This note is spurious, as the imported package is used. It is only called from
C++ source code, which may be the reason behind this false positive.

RHub checks produced some additional notes, that I have not been able to 
reproduce, and I don't believe to represent serious issues:

* checking for non-standard things in the check directory ... NOTE
Found the following files/directories:
  ''NULL''
* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'

---

### Additional remarks for CRAN reviewers

#### Remark 1

Checks will likely raise the following NOTE:

 The Title field should be in title case. Current version is:
 'Classical k-gram Language Models'
 In title case that is:
 'Classical k-Gram Language Models'
 
"k-gram" is a mathematical term, as such it should be considered as a 
single word. In particular, "gram" does not need to be capitalized.



#### Remark 2

In the review of a previous version of this package, I was suggested:

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



#### Remark 3

In the review of a previous version of this package, I was suggested:

\dontrun{} should only be used if the example really cannot be executed (e.g. because of missing additional software, missing API keys, ...) by the user. That's why wrapping examples in \dontrun{} adds the comment ("# Not run:") as a warning for the user.
Does not seem necessary.
Please unwrap the examples if they are executable in < 5 sec, or replace \dontrun{} with \donttest{}.

The only two examples that are currently wrapped in the \dontrun{} command
cannot be run with 100% confidence - because they reference a dummy 
"my_text_file.txt" local or online resource, which does not exist. I believe
this is the most transparent way to document (abstractly) the relevant features
here.
