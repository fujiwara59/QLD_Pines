# script to plot dendrometer traces using ggplot

# checking that timestamps are in the right format
classes <- sapply(den.qld, class)
stopifnot (classes$TIMESTAMP[[1]] == 'POSIXct')
rm(classes)

# excluding observations before the start of the experiment
den.qld <- den.qld.bak
spec.s <- as.POSIXct('2012-06-11')
spec.e <- as.POSIXct('2012-10-09')

den.qld <- den.qld[den.qld$TIMESTAMP > spec.s, ]
den.qld <- den.qld[den.qld$TIMESTAMP < spec.e, ]

# stacking the data 
  # pulling out only those columns to do with stem radius  
  den.qld.rad <- den.qld[, c(1,5,6,7,8,9,10,14,15,16,17,18,19)]
  # using melt to stack 
  require(reshape2)
  den.qld.tall <- melt(data = den.qld.rad, id = c('TIMESTAMP'))
  detach(package:reshape2)

#Rplot20
qplot(data= den.qld.tall, x = TIMESTAMP, y = value)

# adding columns for 'Site' and 'Tree, derived from prev colum labels
den.qld.tall$Tree <- substr(x=den.qld.tall$variable, 12, 12)
den.qld.tall$Site <- substr(x=den.qld.tall$variable, 14,17)

# In the newly created 'Site' column, changing site codes to full names
den.qld.tall$Site <- gsub(pattern='Brib', replacement='Bribie Island', den.qld.tall$Site)
den.qld.tall$Site <- gsub(pattern='Beer', replacement='Beerburrum', den.qld.tall$Site)

# ggplot
  # qplot provided to show how ggplot relates to base plot
            qplot(data=den.qld.tall, x = TIMESTAMP, y = value)
  plot1 <- ggplot(data=den.qld.tall, aes(x = TIMESTAMP, y = value))+
    geom_point(aes(colour = Site))+
    scale_y_continuous("Dendrometer displacement (mm)")
  ggsave(file.path('graphs', 'Rplot21.pdf'))

  plot2 <- ggplot(data=den.qld.tall, aes(x = TIMESTAMP, y = value))+ 
    facet_wrap(~Site) +
    geom_point(aes(colour=Tree)) +
    scale_y_continuous("Dendrometer displacement (mm)")
  ggsave(file.path('graphs', 'Rplot22.pdf'))