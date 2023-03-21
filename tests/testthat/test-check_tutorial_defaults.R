# Would like to figure out a way to add tutorials to this package for testing,
# ones which would not show up in the Tutorial pane, thereby confusing students.
# In the meantime, we can load some learnr tutorials and confirm that they don't
# have the required defaults.

x <- return_tutorial_paths(package = "learnr")

expect_error(check_tutorial_defaults(x[1]))
expect_error(check_tutorial_defaults(x[2]))

