## Resubmission (v3)

This resubmission addresses two issues pointed out in previous submission:

1. Unnecessary use of dontrun{} in examples.
2. Always make sure to reset to user's options().

My response:

1. There are four examples marked with `\dontrun{}`, in `?sample_sentences`, `?perplexity` and `?kgram_freqs`. The examples in `?sample_sentences` and `?perplexity` require >5s on some machines, thus I have replaced `\dontrun{}` with `\donttest{}`. The two examples marked with `\dontrun{}` in `kgram_freqs` require (i) a mock file which does not exist and (ii) internet connection. Following the CRAN guide to Writing R Extensions, I left the `\dontrun{}` directive for these examples:

«Thus, example code not included in \dontrun must be executable! In addition, it should not use any system-specific features or require special facilities (such as Internet access or write permission to specific directories).»

2. In the vignette (c.f. inst/doc/kgrams.R) I was setting plot margins with `par()` without resetting them to the original user's value. Fixed this.

## Resubmission (v2)

Changes from previous version:

* Removed 'in R' from Title 'Classical k-gram Language Models in R'.
* Removed file LICENSE, and reference to it in the DESCRIPTION field.
* Fixed URL detected as possibly invalid.

**Note 1.**
The package implements several classical algorithms and next versions
will likely include more. I'm not referencing any of these in the DESCRIPTION field 'Description', as this would require to add a large list of references (at present about fifteen, many of which do not have an associated DOI), and bog down the essence of the description. All algorithms are properly and fully referenced in the package documentation pages, whenever these are mentioned explicitly. 

**Note 2.**
The version of `kgrams` as been kept to the original 0.1.0 of the first submission.

## Test environments
I have tested `kgrams` on the following platforms. NOTEs are commented in the next section.

* local: 

        - Ubuntu 20.04 LTS, R 4.0.3 (OK)
* winbuilder:

        - release (1 NOTE)
        - oldrelease (1 NOTE)
        - devel (1 NOTE)
* rhub: 

        - Windows Server 2008 R2 SP1, R-devel, 32/64 bit (1 NOTE)
        - Fedora Linux, R-devel, clang, gfortran (1 NOTE)
        - Ubuntu Linux 20.04.1 LTS, R-release, GCC (1 NOTE)
        - Debian Linux, R-devel, GCC ASAN/UBSAN (OK)
* GitHub Workflows:

        - macOS Catalina 10.15.7, R 4.0.3 (OK)
        - Windows Server x64, 4.0.3 (OK)
        - Windows Server x64, 3.6.3 (OK)
        - Ubuntu 16.04.7 LTS, R Under development (unstable) (2021-01-25 r79883) (OK)
        - Ubuntu 16.04.7 LTS, R 4.0.3 (OK)
        - Ubuntu 16.04.7 LTS, R 3.6.3 (OK)
        - Ubuntu 16.04.7 LTS, R 3.5.3 (OK)
* AppVeyor:

        - Windows Server x64, R 4.0.3 Patched (OK)

        

## R CMD check results

NOTE (same from rhub and win-builder):
* New submission

This is correct.


Attached to this NOTE, there was also a message (not flagged as a separate NOTE) that the package Title is: 
        'Classical k-gram Language Models in R'
whereas in Title case it should be:
        'Classical k-Gram Language Models in R'
I think the suggested version is horrible, and would like to keep the original if possible.