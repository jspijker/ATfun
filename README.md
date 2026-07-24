# ATfun

ATFun is an R package with functions underlying the Analyse Together
tool. The goal of this package is twofold. Provide a package for
general use for people who wants to work with Samen Meten Sensor data
and, for example, want to create their own application or dashboard.
Secondly, the code must be made more robust against all the glitches
of the API's used, this is done by writing tests and refactoring.

For running the tests, seperate datasets are needed. These datasets
are not yet part of the repository because in this stage they change
often. To create the datasets, you must the
`./data-raw/create_internal_datasets` script. 

## Current Status

This package is in development and functions are partially
implemented. To use this package one must have the `samanapir` and the
development version of `ATdatabase` installed. The `logger` package is
used for providing log messages.

The functions in R/proto_fun are functions extracted from the Analyse
Together tool. These functions have to be refactored in seperate
functions and tests.


