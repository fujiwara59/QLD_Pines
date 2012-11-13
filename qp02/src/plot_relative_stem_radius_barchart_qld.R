# plot growth (relative stem radius) means. 

# input: 
# wide dataframe, ie Sap.All, den.qld

# outputs: 
# 'growth' for each tree over the period, along with which tree it came from. 
# plots to compare growth at different sites

# changelog:
# 2012-09-17 version 0.9
# 2012-09-18 version 1.0
# 2012-11-13 forked from Dropbox/phd/r_scripts/plot_relative_stem_radius_barchart_qld.R

#############################################################
# REQUIRED USER INPUT
# choose input dataframe                                    #
DFx <- den.qld                                              #
# choose method 1 or method 2, and time period to examine   #
spec.method <- 1                                            #
#spec.method <- 2                                            #
spec.s <- as.POSIXct('2012-05-01')                          #
#############################################################


# subset the user specified time period above
DFx <- DFx[DFx$TIMESTAMP > spec.s, ]

# method 1: using a loop
#######################################################################################
# initialising output df
require(zoo)
if(spec.method ==1) {
  print('Method 1 chosen')
outputDF <- data.frame("Tree" = NA, 'Growth' = NA)
# loop over target columns
wide <- DFx
wide <- na.trim(DFx) # need to do this because it is always unbalanced at the end.. 
  x <- c()
#trees.vec <- unlist(trees)
for (i in trees) {
  print(i)
  n <- nrow(wide)
  # x[['Max']] <- max(wide[ ,i], na.rm = TRUE) # using max and min is extremely prone to outliers 
  # x[['Min']] <- min(wide[ ,i], na.rm = TRUE)
  x[['Max']] <- wide[n, i]
  x[['Min']] <- wide[1, i]
  
  y <- x[['Max']] - x[['Min']]
  outputDF[i, 1] <- colnames(wide)[i]
  outputDF[i, 2] <- y
}
outputDF
}

detach(package:zoo)

#######################################################################################

# method 2 - using apply, 'first' & 'last', vectors subtraction
#######################################################################################
if(spec.method ==2) {
  print('Method 2 chosen')

wide <- na.trim(DFx) 
first.vals <- apply(wide, MARGIN = 2, FUN = first, na.rm = TRUE)
last.vals <- apply(wide, MARGIN = 2, FUN = last, na.rm = TRUE)
  
namesvec <- names(first.vals)  
first.vals <- as.character(first.vals)
names(first.vals) <- namesvec

namesvec <- names(last.vals)  
last.vals <- as.character(last.vals)
names(last.vals) <- namesvec
  
smry.df <- data.frame(first.vals, last.vals, stringsAsFactors = FALSE)
str(smry.df)
  
# getting rid of junk rows
smry.df <- smry.df [-c(1,2,3,8,9,14,15), ]

# converting to numeric
smry.df[,1]<- as.numeric(smry.df[,1])
smry.df[,2]<- as.numeric(smry.df[,2])  
smry.df
  
smry.df[ ,3] <- smry.df[ ,2] - smry.df[ ,1]
t <- rownames(smry.df)  

# creating extra columns which identify the tree and site
smry.df$Tree <- substr(x=t, start=12, stop=12)
smry.df$Site <- substr(x=t, start=17, stop=19)
# converting 'site' to depth
smry.df$Depth <- as.factor(smry.df$Site)
levels(smry.df$Depth) <- list("9" = "03A", "3" = "03F", "39" = "10A")
smry.df$Depth <- as.character(smry.df$Depth)
smry.df$Depth <- as.integer(smry.df$Depth)
smry.df <- smry.df[with(smry.df, order(Depth)), ]

colnames(smry.df)[3] <- 'Growth'
tall.gr <- smry.df
gr1 <- smry.df  
}
#######################################################################################


# dividing by stem radius
################################################################################
  # DF1 <- tall.gr
  # DF2 <- tree.info
  # 
  # DF3 <- merge(
  #   x = DF1 , # [c('TIMESTAMP', 'Mean','Site','Tree')]
  #   y = DF2, # [c('Site', 'Tree', 'DBH_cm')]
  #   by.x = c('Tree', 'Site'),
  #   by.y = c('Port', 'Site'))
  # 
  # head(DF3)
  # 
  # # divide (tree growth) by (radius @ breast height)
  # # convert radiusto mm
  # DF3$DBH_mm <- DF3$DBH_cm * 10 
  # DF3$rad_mm <- DF3$DBH_mm / 2 
  # # divide Growth by radius
  # DF3$Growth_per_mm <- DF3$Growth / DF3$rad_mm
  # 
  # # divide (tree growth) by (radius in m)
  # DF3$rad_m <- DF3$rad_mm / 1000
  # DF3$Growth_per_m <- DF3$Growth / DF3$rad_m
  # 
  # # selecting only columns of interest for plotting
  # DF4 <- data.frame(
  #   Growth = DF3[, 'Growth_per_m'],
  #   Tree = DF3[ , 'Tree'],
  #   Site = DF3[ , 'Site'])  
  # 
  # # changing site label to depth label
  # DF4$Site_numeric <- DF4$Site
  # levels(DF4$Site_numeric) <- list("9" = "03A", "3" = "03F", "39" = "10A")
  # DF4; class(DF4$Site_numeric)
  # DF4$Depth <- as.character(DF4$Site_numeric)
  # DF4$Depth <- as.integer(DF4$Depth)
  # ## sorting by depth
  # DF4 <- DF4[with(DF4, order(Depth)), ]
  # gr2<- DF4
################################################################################

# removing globoideas
################################################################
  # dropping out dendro 4 at 3F and 10A
  # tall.gr <- DF4
  # temp <- tall.gr
  # temp <- temp[ -c(which(temp$Site =='10A' & temp$Tree == 4)) , ]
  # temp <- temp[ -c(which(temp$Site =='03F' & temp$Tree == 4)) , ]
  # gr3 <- temp
################################################################


#  using ggplot
############################################################################################
# to compare sites
d <- ggplot(aes(y = Growth, x = Site), data = tall.gr)
d <- d + stat_summary(fun.data = 'mean_cl_normal', colour = 'red') #, geom = 'errorbar'
d

# to compare sites - with original points underneath
d <- qplot(Site, Growth, data = tall.gr)
d <- d + stat_summary(fun.data = 'mean_cl_normal', colour = 'red' , geom = 'pointrange')
d
############################################################################################

# using sciplot
###################################################################################

# plot 1 - not adjusted for stem radius. 
require(sciplot)
# default is error bars = standard error. 
bargraph.CI(
  as.factor(gr1$Depth), # categorical factor for x-axis
  gr1$Growth, # numerical variable for y-axis
  #Site, # grouping factor
  legend = T,
  x.leg = 19,
  ylab = 'Radial growth (mm)',
  xlab = 'Site depth-to-water (m)',
  col=c("firebrick2", "forestgreen", "cornflowerblue"))

# plot 2 - adjusted for stem radius, including all trees. 
require(sciplot)
bargraph.CI(
  as.factor(gr2$Depth), # For some reason, using this produces the right result. 
  # Using Depth as an integer, produces entirely the wrong result for some reason. 
  gr2$Growth, # numerical variable for y-axis
  #Site, # grouping factor
  legend = T,
  x.leg = 19,
  xlab = "Site depth-to-water (m)",
  ylab = "Growth (mm/m)",
  main = "Incl glob, growth per unit rad",
  cex.main = 1.0,
  col=c("firebrick2", "forestgreen", "cornflowerblue"))

# plot 3 - adjusted for stem radius, with no globoidieas
require(sciplot)
bargraph.CI(
  as.factor(gr3$Depth), # x-axis
  gr3$Growth, # y
  legend = T,
  x.leg = 19,
  xlab = "Site depth-to-water (m)",
  ylab = "Growth (mm/m)",
  main = "Excl glob, growth per m rad",
  cex.main = 1.0,
  col=c("firebrick2", "forestgreen", "cornflowerblue"))