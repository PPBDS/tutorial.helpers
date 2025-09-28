# For now, we will do all our tutorial testing in this one script.

tutorial_paths <- tutorial.helpers::return_tutorial_paths(package = "tutorial.helpers")

# First, we make sure that all the tutorials can be knitted.

tutorial.helpers::knit_tutorials(tutorial_paths)

# Second, ensure that all the tutorials have the default components.

tutorial.helpers::check_tutorial_defaults(tutorial_paths)
