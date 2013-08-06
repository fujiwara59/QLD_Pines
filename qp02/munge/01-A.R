# Example preprocessing script.


# function to merge raw data files from a given site
# 

CSVsToDF <- function(target.dir){
  
  # defining target directory
  setwd(target.dir)
  
  # initialising output list
  output.list <- list()
  
  for (f in dir() ) { 
    print(paste("reading csv file:",f))
  
    # defining target file
    target.file <- f
    
    # reading in the first data file, with some column names
      # The commented section is good when the files have long headers. 
        # col.names.obj <- read.csv(file = target.file, skip = 1, header = TRUE)
        # DF1028 <- read.csv(file = target.file, 
        #                    skip = 4,
        #                    header = FALSE,
        #                    col.names=names(col.names.obj))#, 
        #                    #as.is = TRUE)
     # For short (one-line) headers
      DF1028 <- read.csv(file = target.file, 
                         skip = 0,
                         header = TRUE,
                         as.is = TRUE)
                       
    
    # add site name to column names
    s <- regexpr("_Dendro", target.file)[[1]]
    string.Site <- substr(x = target.file, start = s-4, stop = s-1)
    n <- ncol(DF1028)
    target.cols <- colnames(DF1028)[4:n]
    target.cols <-paste(target.cols, string.Site, sep =  "")  
    old.cols <- colnames(DF1028)
    old.cols[4:n] <- target.cols
    target.cols <- colnames(DF1028)[2:3]
    target.cols <-paste(target.cols, string.Site, sep =  ".")
    old.cols[2:3] <- target.cols
    new.cols <- old.cols 
    colnames(DF1028) <- new.cols 
  
    # creating list of dataframes 
    output.list[[f]] <- DF1028
  }
  
  # rbind all files in dir
  output.df <- do.call("rbind", output.list)
  
  # drop non-unique rows
  output.df <- unique(output.df)
  
  # clearing out the junk rownames
  rownames(output.df) <- NULL
  
  return(output.df)
}


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

# usage example

# target.dir <- '/Users/fuji/Documents/2012-10-28\ R\ scripting\ with\ JM/Kangaloon_Data_20121023/Kanga_Data_per_site'
# output.list <- CSVsToDF_Batch(target.dir)



# loading data from inside a given date folder
hh <- getwd()

output.list <- CSVsToDF_Batch(target.dir)
setwd(hh)


# changing TIMESTAMP to POSIX
for(i in 1:length(output.list)){
  if(class(output.list[[i]][ ,'TIMESTAMP']) == c("POSIXct", "POSIXt")) print ('Already POSIX, skipping conversion')
  if(class(output.list[[i]][ ,'TIMESTAMP']) == "character") {
    print('Timestamp is still only character at this point, converting to POSIX now')
    output.list[[i]][ , 'TIMESTAMP'] <- as.POSIXct(output.list[[i]][ , 'TIMESTAMP'], format = "%Y-%m-%d %H:%M:%S")
  }
}

cache('output.list')

# merging the multiple dataframe objects
# (combine multiple sites into one dataframe)
# TODO, add check to see that class of timestamp is the same for both frames to merge. 
if (length(output.list) == 2) {
  den.qld <- merge(output.list[[1]],
                   output.list[[2]],
                   by='TIMESTAMP', 
                   all = TRUE
  )
} else stop()


# converting mV to mm