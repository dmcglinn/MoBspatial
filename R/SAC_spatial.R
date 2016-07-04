#####################################################################
# Functions for non-spatial and spatial species accumulation curves
#               SAC             sSAC
#
# All functions work on point-mapped data, not on plot based surveys!
#
# Felix May, 16. 02. 2016
# 
# 
#####################################################################

# Command to compile the C++ code into a dynamic link library (Windows)
# or shared object file (Linux

# R --arch x64 CMD SHLIB -o sSAC1.dll SAC_spatial1.cpp

# or alternatively with Rcpp
#library(Rcpp)
#sourceCpp("SourceCode/Cplusplus/SAC_spatial2.cpp")

# -----------------------------------------------------------
# Function for the non-spatial SAC after Coleman 1982 Ecology
S.single.scale <- function(n1,abund.vec1)
{
  S <- length(abund.vec1)
  N <- sum(abund.vec1)
  S.n <- S - sum((1-n1/N)^abund.vec1)
  return(S.n)
}  

SAC.coleman <- function(abund.vec)
{
  N <- sum(abund.vec)
  n.vec <- 1:N
  sac <- sapply(n.vec,S.single.scale,abund.vec1=abund.vec)
  return(sac)
}

# -----------------------------------------------------------
# Function for the spatial SAC written by Xiao Xiao, Dan McGlinn and Nick Gotelli
# This function computes the sSAC from one random individual in the community

near_neigh_ind = function(data){
  # The input data has three columns: x, y, and species ID for each individual.
  data = data[sample(1:dim(data)[1]), ]
  focal_row = sample(dim(data)[1], 1)
  # Compute Euclidean distances
  x_diff = data[, 1] - as.numeric(data[focal_row, 1])
  y_diff = data[, 2] - as.numeric(data[focal_row, 2])
  dist_row = sqrt(x_diff^2 + y_diff^2)
  data_order = data[order(dist_row), ]
  S = c()
  #vec_list = lapply(1:dim(data_order)[1], seq)
  #lapply(vec_list, length(unique(data_order[vec_list, 3])))
  for (i in 1:dim(data_order)[1]){
    sp_id_list = data_order[1:i, 3]
    i_rich = length(unique(sp_id_list))
    S = c(S, i_rich)
  }
  N = 1:dim(data_order)[1]
  return(list(S = S, N = N))
}

# -----------------------------------------------------------
# Average sSAC starting from n (=nsamples) random individuals in the local community
sSAC.avg <- function(data,nsamples=20)
{
  N <- nrow(data)
  
  sac.mat <- matrix(NA,nrow=nsamples,ncol=N)
  for (i in 1:nsamples)
    sac.mat[i,] <- near_neigh_ind(data)$S
  return(colMeans(sac.mat))
}

# # -----------------------------------------------------------
# # Average sSAC starting from all individuals in the local community
# sSAC.all <- function(data)
# {
#    dyn.load("Cplusplus_Code/sSAC1.dll")
#    
#    out <- .C("sSAC1",
#              x = as.double(data[,1]),
#              y = as.double(data[,2]),
#              id_spec = as.integer(data[,3]),
#              n.ind = as.integer(nrow(data)),
#              sSAC = as.double(rep(0,times=nrow(data)))
#    )
#    
#    dyn.unload("Cplusplus_Code/sSAC1.dll")
#    return(out$sSAC)
# }

# -----------------------------------------------------------
# Average sSAC starting from all individuals in the local community
sSAC.all.rcpp <- function(data)
{
   #sSAC <- sSAC1_C(data[,1],data[,2],as.character(data[,3]))
   sSAC <- sSAC1_C(data[,1],data[,2],as.integer(data[,3]))
   return(sSAC)
}


# -----------------------------------------------------------
# calculates PIE in sub-samples of a community
PIE.sample <- function(abund.count,sample.size,nsample)
{
   require(vegan)
   pie <- numeric(nsample)
   spec.id <- 1:length(abund.count)
   rel.abund <- abund.count/sum(abund.count)
   for (i in 1:nsample){
      abund.sample <- table(sample(spec.id,size=sample.size,replace=T,prob=rel.abund))
      pie[i] <- diversity(abund.sample,index="simpson")
   }
   return(mean(pie))   
}

# -----------------------------------------------------------
# calculates PIE of a species ID vector in a point pattern
PIE.ppp <- function(pp1)
{
   require(vegan)
   abund <- table(marks(pp1))
   return(diversity(abund,index="simpson"))
}

# -----------------------------------------------------------
# calculates spatially-explicit PIE in non-noverlapping squares
PIE.spatial <- function(community,square.size=0.1)
{
   require(vegan)
   require(spatstat)
   
   x <- community[,1]
   y <- community[,2]
   
   xmin <- floor(min(x)); xmax <- ceiling(max(x))
   ymin <- floor(min(y)); ymax <- ceiling(max(y))
   
   pp1 <- ppp(x,y,marks=community[,3],window=owin(c(xmin,xmax),c(ymin,ymax)))
   grid1 <- tess(xgrid=seq(xmin,xmax,by=(xmax-xmin)*square.size),
                 ygrid=seq(ymin,ymax,by=(ymax-ymin)*square.size))
   pp.grid <- split(pp1,grid1)
   
   pie.local <- sapply(pp.grid,PIE.ppp)
   
   return(mean(pie.local))   
}   

# -----------------------------------------------------------
# calculates number of species and PIE in subsquares of a plot
diversity.square <- function(community,square.size=0.1)
{
   require(vegan)
   require(spatstat)
   
   x <- community[,1]
   y <- community[,2]
   
   xmin <- floor(min(x)); xmax <- ceiling(max(x))
   ymin <- floor(min(y)); ymax <- ceiling(max(y))
   
   pp1 <- ppp(x,y,marks=community[,3],window=owin(c(xmin,xmax),c(ymin,ymax)))
   grid1 <- tess(xgrid=seq(xmin,xmax,by=(xmax-xmin)*square.size),
                 ygrid=seq(ymin,ymax,by=(ymax-ymin)*square.size))
   pp.grid <- split(pp1,grid1)
   
   abund.local <- lapply(pp.grid,function(pp){table(marks(pp))})
   
   pie.local <- sapply(abund.local,diversity,index="simpson")
   sr.local <- sapply(abund.local,specnumber)
   
   return(c(PIE=mean(pie.local),SR.local=mean(sr.local)))   
}   

#--------------------------------------------------------------------------------------------
# #example data set all trees >= 10 cm dbh in BCI 2010
# 
# 
# bci1 <- read.table("bci2010_10cm_20140212.txt",header=T)
# head(bci1)
# dim(bci1)
# 
# bci2 <- subset(bci1,select=c(gx,gy,sp))
# rm(bci1)

# SAC1 <- SAC.coleman(table(bci2$sp))
# 
# #system.time(sSAC1 <- near_neigh_ind(bci2)) # ca. 10 seconds
# 
# system.time(sSAC2 <- sSAC.avg(bci2,nsamples=20)) # ca. 200 seconds
# #system.time(sSAC3 <- sSAC.all(bci2)) # ca.  ca. 46 seconds
# 
# system.time(sSAC4 <- sSAC.all.rcpp(bci2)) # ca. 44 seconds
# 
# plot(SAC1,type="l",col=1,xlab="# Individuals",ylab="# Species")
# lines(sSAC1$N,sSAC1$S,col=2)
# lines(1:length(sSAC2),sSAC2,col=3)
# lines(1:length(sSAC3),sSAC3,col=4)
# lines(1:length(sSAC4),sSAC4,col=5,lty=2)







