library('ProjectTemplate')
setwd('qp02/')
load.project()

Sys.setenv(TZ='Etc/GMT-10')

for (dataset in project.info$data)
{
  message(paste('Showing top 5 rows of', dataset))
  print(head(get(dataset)))
}


# changing mV to mm                        
source('~/Dropbox/phd/r_scripts/functions00.R')
den.qld <- millivolts_to_mm(den.qld)

# Filling missing times
# TODO: fix this (iss002)
plot(x = row.names(den.qld),
     y = den.qld$TIMESTAMP)
mtext('If there is a break in this plot, it means that there is a gap in the data')
source('~/Dropbox/phd/r_scripts/function_synth_00.R')
den.qld <- MergeSynth(den.qld,10*60)

# Creating an XTS obj
den.qld.xts <- xts(den.qld, order.by = den.qld$'TIMESTAMP')

# Calculating the monthly growth, using the XTS object
ep <- endpoints(den.qld.xts, on = 'months')
ep <- den.qld.xts[ep, c(5:10,14:19)]
ep.lag1 <- lag(ep, 1)
ep <- data.matrix(as.data.frame(ep, 
                 stringsAsFactors=FALSE))
ep.lag1 <- data.matrix(as.data.frame(ep.lag1,
                      stringsAsFactors=FALSE))
diff1 <- ep - ep.lag1


# do some plots. 
  # relevant scripts:
  # ggplot_dendro_trace - duplicated functionality of:ggplot_Sap.All.R
  # plot_relative_stem_radius_barchart_qld.R - dupe func of plot_relative_stem_radius_barchart.R

# building metadata dataframes as per loading_00
tree.names <- TreeInfo(den.qld)
trees <- GetTrees(den.qld)
  # the following line cut&paste from loading_00, will need translation for use in this project
  # trees.short <- c("t1s1","t2s1","t3s1","t4s1","t1s2","t2s2","t3s2","t4s2","t1s3","t2s3","t3s3","t4s4")

# work around - do I need this???
  # Sap.All <- unique(Sap.All)