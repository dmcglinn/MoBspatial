% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Sim_Community.R
\name{sim_poisson_community}
\alias{sim_poisson_community}
\title{Simulate community with random spatial positions.}
\usage{
sim_poisson_community(s_pool, n_sim, cv_abund = 1, fix_s_sim = F,
  xrange = c(0, 1), yrange = c(0, 1))
}
\arguments{
\item{s_pool}{integer - number of species in the pool}

\item{n_sim}{integer - number of individuals in the simulate local community}

\item{cv_abund}{numeric - coefficient of variation ( = sd/mean) of relative
abundances. The higher \code{cv_abund}, the lower the evenness of the
simulated community. This means with increasing \code{cv_abund} there are more
rare and more dominant species.}

\item{fix_s_sim}{logical - should the simulation constrain the number of
species in the local community? This can result in deviations from mean and
sd of local abundances from the theoretical distributions}

\item{xrange}{numeric vector of length 2 - extent of the community in x-direction}

\item{yrange}{numeric vector of length 2 - extent of the community in y-direction}
}
\value{
A community object as defined by \code{\link{community}}.
}
\description{
This function simulates a community with a certain abundance distribution and
and random spatial coordinates. This function consecutively calls
\code{\link{sim_sad}} and \code{\link{sim_poisson_coords}}
}
\examples{
com1 <- sim_poisson_community(S = 20, N = 500, cv = 1)
plot(com1)

}
\author{
Felix May
}
