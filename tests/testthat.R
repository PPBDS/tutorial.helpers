# This file is part of the standard setup for testthat. It is recommended that
# you do not modify it.
#
# Where should you do additional test configuration? Learn more about the roles
# of various files in:
# * https://r-pkgs.org/tests.html
# * https://testthat.r-lib.org/reference/test_package.html#special-files

# Need to think harder about how we are doing testing. In particular, there are
# a lot of functions here which test all the tutorials in a package. But how
# should we test them here? And how do we use those functions in other tutorial
# packages? This was all easier when everything was bundled together.

library(testthat)
library(tutorial.helpers)

test_check("tutorial.helpers")
