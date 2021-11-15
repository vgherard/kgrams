## kgrams v0.1.2
### Comments for resubmission (v2).** 

```
URL: https://codecov.io/gh/vgherard/kgrams?branch=main (moved to https://app.codecov.io/gh/vgherard/kgrams?branch=main)
     From: README.md
     Status: 301
     Message: Moved Permanently
```

Fixed (version number not bumped).

### Comments

This is a minor patch addressing the following reported issue:

```
The CRAN policy contains

- Packages should not attempt to disable compiler diagnostics, nor to remove other diagnostic information such as symbols in shared objects.

yet packages

... kgrams ...

attempt to do so.
```

The custom Makefile causing the issue was removed. 

Alongside, few minor improvements on the package API were added.

## Test environments

* local: 

        - macOS 12.0.1
* winbuilder:

        - release
        - oldrelease
        - devel
* rhub (CRAN standards)
        

## R CMD check results

I got the following NOTEs:

```
New maintainer:
  Valerio Gherardi <vgherard840@gmail.com>
Old maintainer(s):
  Valerio Gherardi <vgherard@sissa.it>
```
Correct.

```
checking installed package size ... NOTE
  installed size is 17.3Mb
  sub-directories of 1Mb or more:
    libs  16.8Mb
```
This is due to the reintroduction of compiler diagnostics, as mentioned above.

```
* checking dependencies in R code ... NOTE
Namespace in Imports field not imported from: ‘RcppProgress’
  All declared Imports should be used.
```

I believe this NOTE to be spurious, as RcppProgress is correctly listed in the
DESCRIPTION file of this package.
