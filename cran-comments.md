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