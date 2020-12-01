# Objective: Modify inputs for ETSP RSPM
# By: Dongmei Chen (dchen@lcog.org)
# November 23rd, 2020
# Reference: Ref_input.R

################################# Set up ############################################
library(readxl)

inpath <- 'E:/VisionEval/models/model/inputs'
# list CSV files
csvfiles <- list.files(path = inpath, pattern = ".csv")
print(csvfiles)

infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/memo/"
infile <- read_excel(paste0(infolder, "scenarios_City_of_Eugene.xlsx"), sheet = "Updated")
#infile <- read_excel(paste0(infolder, "scenarios_City_of_Eugene.xlsx"), sheet = "Original")
head(infile)

################################# Revise the inputs ############################################
modify_scenario_inputs <- function(folder='01-Base-Year-2010'){
  inpath <- paste0("E:/VisionEval/models/ETSP-scenarios/", folder)
  for(csv in csvfiles){
    if(csv %in% unique(infile$File)){
      dt <- read.csv(paste0(inpath, '/inputs/', csv), stringsAsFactors = FALSE, 
                     header = TRUE, row.names = NULL)
      if('row.names' %in% names(dt)){
        colnames(dt) <- c(colnames(dt)[-1], NULL)
        if(NA %in% names(dt)){
          dt <- dt[,-which(is.na(names(dt)))]
        }
      }
      cat('Before:\n')
      print(dt)
      for(var in names(dt)[!(names(dt) %in% c('Year', 'Geo'))]){
        if(var %in% unique(infile[infile$File == csv,]$Variable)){
          target <- infile$File == csv & infile$Variable == var
          if(var == 'CarSvcLevel'){
            dt[dt$Year == 2010, var] <- unique(infile[target,]$`2010 adopted plans`)
            if(folder == '01-Base-Year-2010'){
              dt[dt$Year == 2040, var] <- unique(infile[target,]$`2040 adopted plans`)
            }else if(folder == '02-Scenario1'){
              dt[dt$Year == 2040, var] <- unique(infile[target,]$`Scenario 1`)
            }else{
              dt[dt$Year == 2040, var] <- unique(infile[target,]$`Scenario 2`)
            }
            
          }else{
            dt[dt$Year == 2010, var] <- as.numeric(unique(infile[target,]$`2010 adopted plans`))
            if(folder == '01-Base-Year-2010'){
              dt[dt$Year == 2040, var] <- as.numeric(unique(infile[target,]$`2040 adopted plans`))
            }else if(folder == '02-Scenario1'){
              dt[dt$Year == 2040, var] <- as.numeric(unique(infile[target,]$`Scenario 1`))
            }else{
              dt[dt$Year == 2040, var] <- as.numeric(unique(infile[target,]$`Scenario 2`))
            }
          }
        }
      }
      cat('After:\n')
      print(dt)
      write.csv(dt, paste0(inpath, '/inputs/', csv), row.names = FALSE)
    }
  }
  cat('Completed updating the inputs for', folder, '\n')
}
modify_scenario_inputs()

modify_scenario_inputs('02-Scenario1')
modify_scenario_inputs('03-Scenario2')

# make a copy in the reference folder
copy.files <- function(folder='01-Base-Year-2010'){
  inpath <- paste0("E:/VisionEval/models/ETSP-scenarios/", folder, "/inputs")
  currentfiles <- list.files(inpath, recursive = FALSE)
  newlocation <- "E:/VisionEval/models/reference/inputs"
  file.copy(from=paste0(inpath, "/", currentfiles), to=newlocation, 
            overwrite = TRUE, recursive = TRUE, 
            copy.mode = TRUE)
}
copy.files()

################################# Run the model ############################################
setwd("E:/VisionEval")
library(visioneval)
ETSP_scenarios <- openModel("ETSP-scenarios")
ETSP_scenarios$run()


################################# Get the outputs ############################################
runnm = 10
path <- 'E:/VisionEval/models/'
setwd(paste0(path, 'ETSP-scenarios'))
start.time <- Sys.time()
source(paste0(path,"ETSP-scenarios/CLMPO-Query-Script.R"))
Sys.time() - start.time

copy.output <- function(s="02-Scenario1"){
  if(s=="reference"){
    inpath <- paste0("E:/VisionEval/models/", s)
  }else{
    inpath <- paste0("E:/VisionEval/models/ETSP-scenarios/", s)
  }
  df <- file.info(list.files(inpath, pattern =s, full.names = T))
  target <- rownames(df)[which.max(df$mtime)]
  newlocation <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/memo/output"
  file.copy(from=target, to=newlocation, 
            overwrite = TRUE, copy.mode = TRUE)
  if(s=="reference"){
    file.rename(paste0(newlocation, "/", gsub(paste0(inpath, "/"), "", target)),
                paste0(newlocation, "/Reference.csv"))
  }else{
    file.rename(paste0(newlocation, "/", gsub(paste0(inpath, "/"), "", target)),
                paste0(newlocation, "/", gsub(".*-", "", s), ".csv"))
  }
}

copy.output()
copy.output(s="03-Scenario2")

ETSP_scenarios$clear()

# get the reference scenario output
ETSP_reference <- openModel("reference")
ETSP_reference$run()

copy.output(s="reference")
ETSP_reference$clear()
