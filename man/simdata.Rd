% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simdata.R
\docType{data}
\name{simdata}
\alias{simdata}
\title{Randomly generated dataset for linear regression modeling}
\format{
A matrix with 10000 rows and 6 variables :
\describe{
  \item{y}{a 1-D numeric vector generated by multiplying x with randomly generated betas from the normal distribution with mean = 1 and sd = 10, then adding errors randomly generated from the normal distribution with mean = 0 and sd = 0.5}
  \item{x1-5}{randomly generated variables from the normal distribution with mean = 0 and sd = 1}
  ...
}
}
\usage{
simdata
}
\description{
A dataset containing the randomly generated variables.
}
\keyword{datasets}
