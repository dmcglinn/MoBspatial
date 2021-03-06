% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Plot_Community.R
\name{interactive.plot}
\alias{interactive.plot}
\title{Interactive plot of biodiversity patterns at multiple spatial scales}
\usage{
interactive.plot()
}
\description{
Visualize multiple biodiversity patterns at multiple spatial scales. The tool
\enumerate{
   \item simulates locations of individuals of different species in a location (plot, area)
   \item plots biodiversity patterns such as species-abundance distributions (SAD), species accummulation curves (SAC), species-area relationships (SAR) and alike for a selected grid cell and for the entire region.
The function sim.Thomas.Community is used to simulate point pattern distributions of individual species.
The interactive interface relies on package `manipulate`.
}
Key parameters to vary using the sliders are:
\enumerate{
   \item S - total number of species,
   \item N - total number of individuals,
   \item eveness - evenness of the abundances,
   \item spat.agg - spatial aggregation of species,
   \item resolution - the number of rows or columns used to dissect the 'global' community (total number of cells = resolution²),
   \item cell - cell number for which 'local' relationship should be visualized. Counts start in the upper left corner rowwise.
}
}
\examples{
interactive.plot()

}
