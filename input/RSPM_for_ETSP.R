# Objective: Modify inputs for ETSP RSPM
# By: Dongmei Chen (dchen@lcog.org)
# November 23rd, 2020
# Reference: Ref_input.R

################################# Set up ############################################
inpath <- 'E:/VisionEval/models/model/inputs'
# list CSV files
csvfiles <- list.files(path = inpath, pattern = ".csv")
print(csvfiles)

infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/memo/"
infile <- read_excel(paste0(infolder, "scenarios_City_of_Eugene.xlsx"), sheet = "Updated")
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
modify_scenario_inputs('04-Reference')

################################# Run the model ############################################
setwd("E:/VisionEval")
library(visioneval)
ETSP_scenarios <- openModel("ETSP-scenarios")
ETSP_scenarios$run()
ETSP_scenarios$clear()

################################# Get the outputs ############################################
runnm = 10
path <- 'E:/VisionEval/models/'
setwd(paste0(path, 'ETSP-scenarios'))
start.time <- Sys.time()
source(paste0(path,"ETSP-scenarios/CLMPO-Query-Script.R"))
Sys.time() - start.time

# get the reference scenario output
ETSP_reference <- openModel("reference")
ETSP_reference$run()
