# script to plot dendrometer traces using ggplot

# if i was going to make this into a script, it would need:
# inputs: dataframe, start date, end date

# creating backup of the object.  
# den.qld.bak <- den.qld
# restoring backup of the object.
den.qld <- den.qld.bak

TrimStackQLD <- function(target.df, start.date, end.date, tare) {
  
  ## test block
  # target.df <- den.qld 
  # start.date <- '2012-10-01'
  # end.date <- '2012-10-07'
  # tare <- 'TRUE'
  
  # checking that timestamps are in the right format
  classes <- sapply(target.df, class)
  stopifnot (classes$TIMESTAMP[[1]] == 'POSIXct')
  rm(classes)
  
  # excluding observations at the start and the end
  spec.s <- as.POSIXct(start.date)
  spec.e <- as.POSIXct(end.date)
  
  target.df <- target.df[target.df$TIMESTAMP > spec.s, ]
  target.df <- target.df[target.df$TIMESTAMP < spec.e, ]
  
  # reset the first point to zero, if tare = TRUE
  if (tare == TRUE) {
    source(file='~/Dropbox/phd/r_scripts/fn_ZeroOrigin.R'); 
    target.df <- ZeroOrigin(target.df)
    }
  
  # stacking the data 
    # pulling out only those columns to do with stem radius  
    target.df.rad <- target.df[, c(1,5,6,7,8,9,10,14,15,16,17,18,19)]
    # using melt to stack 
    require(reshape2)
    target.df.tall <- melt(data = target.df.rad, id = c('TIMESTAMP'))
    detach(package:reshape2)
  
  #Rplot20
  qplot(data= target.df.tall, x = TIMESTAMP, y = value)
  
  # adding columns for 'Site' and 'Tree, derived from prev colum labels
  target.df.tall$Tree <- substr(x=target.df.tall$variable, 12, 12)
  target.df.tall$Site <- substr(x=target.df.tall$variable, 14,17)
  
  # In the newly created 'Site' column, changing site codes to full names
  target.df.tall$Site <- gsub(pattern='Brib', replacement='Bribie Island', target.df.tall$Site)
  target.df.tall$Site <- gsub(pattern='Beer', replacement='Beerburrum', target.df.tall$Site)
  
  return(target.df.tall)
  }

# trimming the data
# stacking the data
# adding columns to identify site and tree (to suit ggplot)
# trying to plot 1 wk to show diel signal. Need to reset to zero. 
s.d <- '2012-10-01'
e.d <- '2012-10-07'
d.f <- den.qld
ta <- 'TRUE'
out.df <- TrimStackQLD(d.f, s.d, e.d, ta)

###############################################################################
# written 2012-11-15 by SF
# two plots - 1) sites identified by colour, 2) sites identified by facet.
plot1 <- ggplot(data=out.df, aes(x = TIMESTAMP, y = value))+
  geom_point(aes(colour = Site), alpha = 1/3)+
  scale_y_continuous("Dendrometer displacement (mm)")
fn <- paste('den.qld', s.d, e.d, 'colour', '.pdf', sep = "_" )
ggsave(file.path('graphs', fn))
plot2 <- ggplot(data=out.df, aes(x = TIMESTAMP, y = value))+ 
  facet_wrap(~Site) +
  geom_point(aes(colour=Tree), alpha = 1/3) +
  scale_y_continuous("Dendrometer displacement (mm)")
fn <- paste('den.qld', s.d, e.d, 'facet', '.pdf', sep = "_" )
ggsave(file.path('graphs', fn))
###############################################################################

###############################################################################
# written 2012-11-14
# ggplot
#
# this plot was performed with the following dates:
qplot(data=target.df.tall, x = TIMESTAMP, y = value)
# qplot provided to show how ggplot relates to base plot
plot1 <- ggplot(data=target.df.tall, aes(x = TIMESTAMP, y = value))+
  geom_point(aes(colour = Site))+
  scale_y_continuous("Dendrometer displacement (mm)")
ggsave(file.path('graphs', 'Rplot21.pdf'))
#
# this plot was performed with the following dates: 
plot2 <- ggplot(data=target.df.tall, aes(x = TIMESTAMP, y = value))+ 
    facet_wrap(~Site) +
    geom_point(aes(colour=Tree)) +
    scale_y_continuous("Dendrometer displacement (mm)")
  ggsave(file.path('graphs', 'Rplot22.pdf'))
###############################################################################