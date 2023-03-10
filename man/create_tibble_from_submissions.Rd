% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_tibble_from_submissions.R
\name{create_tibble_from_submissions}
\alias{create_tibble_from_submissions}
\title{Create Ordered Tibble from Submissions}
\usage{
create_tibble_from_submissions(objs, tutorial_id, label_list = NULL)
}
\arguments{
\item{objs}{learnr session submissions}

\item{tutorial_id}{id of tutorial}

\item{label_list}{order of code chunks (Optional with learnr version 0.10.1.9012)}
}
\value{
tibble with ordered answers based on label_list
}
\description{
Create Ordered Tibble from Submissions
}
