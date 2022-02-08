% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{fit_bbinom}
\alias{fit_bbinom}
\title{fit a Beta-Binomial model by maximum likelihood}
\usage{
fit_bbinom(AD, DP)
}
\arguments{
\item{AD}{variant allele depth}

\item{DP}{total allele depth}
}
\value{
MLE of alpha and beta
}
\description{
fit a Beta-Binomial model by maximum likelihood
}
\keyword{internal}