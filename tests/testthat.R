# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/tests.html
# * https://testthat.r-lib.org/reference/test_package.html#special-files

# Need to think harder about how we are doing testing. In particular, there are
# a lot of functions here which test all the tutorials in a package. But how
# should we test them here? And how do we use those functions in other tutorial
# packages? This was all easier when everything was bundled together.

# For now, I include a simple tutorial so that there is something which the
# functions here to test. This works, but it is annoying since it means that
# there will be a nonsense tutorial in the Tutorial tab, which will confuse
# students, especially since it is at the bottom, which is where we want
# r4ds.tutorials to appear.

# I am also unsure if the tests really work. For example, does test-addins even
# run?

# For now, I am just commenting this test out and worrying about them later.

library(testthat)
library(tutorial.helpers)

# test_check("tutorial.helpers")
