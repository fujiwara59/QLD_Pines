#target.dir <- '/Users/fuji/Documents/2012-10-28\ R\ scripting\ with\ JM/Kangaloon_Data_20121023/Kanga_Data_per_site'

CSVsToDF_Batch <- function( target.dir ) {
  
  # set parent directory
  setwd(target.dir)
  
  # finding subfolders with dendrometer data
  hits <- grep ('Den', dir())
  target.folders <- dir()[hits]
  
  # constructing paths to those subfolders
  target.folders <- paste(getwd(), target.folders, sep = "/")
  target.folders
  
  # run for loop over the paths 
  output.list <- list()
  for (f in target.folders) {
    DF <- CSVsToDF(f)
    output.list[[f]] <- DF
    }
  
  return(output.list)
}
