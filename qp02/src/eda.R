library('ProjectTemplate')
load.project()

Sys.setenv(TZ='Etc/GMT-10')

for (dataset in project.info$data)
{
  message(paste('Showing top 5 rows of', dataset))
  print(head(get(dataset)))
}

# loading data from inside a given date folder
hh <- getwd()
target.dir <- './data/2012-11-05/'
output.list <- CSVsToDF_Batch(target.dir)
setwd(hh)

# merging the multiple dataframe objects
# (combine multiple sites into one dataframe)
if (length(output.list) == 2) {
  den.qld <- merge(output.list[[1]],
                 output.list[[2]],
                 by='TIMESTAMP', 
                 all = TRUE
                 )
  } else stop()

# changing TIMESTAMP to POSIX
# changing mV to microns                        
source('~/Dropbox/phd/r_scripts/functions00.R')
den.qld <- millivolts_to_mm(den.qld)
den.qld[,1] <- as.POSIXct(den.qld[,1])

# Filling missing times
source('~/Dropbox/phd/r_scripts/function_synth_00.R')
den.qld <- MergeSynth(den.qld,10*60)


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