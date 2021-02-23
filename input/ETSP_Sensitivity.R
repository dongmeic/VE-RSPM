# Objective: Collect inputs for the three strategic assessment sensitivity test levels
# By: Dongmei Chen (dchen@lcog.org)
# February 22nd, 2020
# Reference: Ref_input.R, run_sensitivity_tests.R, run_example_scenarios.R

################################## ALWAYS RUN THIS FIRST ###################################################
drive = 'E'

if(drive == 'C'){
  drive.path = 'C:/Users/DChen/all/VE-RSPM'
}else{
  drive.path = 'E:'
}
path <- paste0(drive.path, '/VisionEval/models/')

################################# Set up ############################################
library(readxl)

source("C:/Users/DChen/all/GitHub/VE-RSPM/run/VE_CLMPO_functions.R")

infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
scen.list <- read.csv(paste0(infolder, "scenario_list_with_categories.csv")) 

scenarios <- c('B0C1D1E1F0G1I1P0T1V1',
               'B1C1D1E1F1G1I1P1T1V1', 
               'B2C2D2E2F2G2I2P2T2V2', 
               'B2C3D3E3F3G3I3P3T3V2')

start.time <- Sys.time()
for(s in scenarios){
  print(Sys.time())
  i = which(scenarios==s) + 1
  copy.files(path, s, i, f='ETSP-sensitivity')
  modify.scenario.input(scenario = s, f='ETSP-sensitivity')
}
Sys.time() - start.time

################################# Run the model ############################################
library(visioneval)
setwd("E:/VisionEval")

ETSP_scenarios <- openModel("ETSP-sensitivity")
ETSP_scenarios$run()

################################# Get the outputs ############################################
runnm = 10
path <- 'E:/VisionEval/models/'
setwd(paste0(path, 'ETSP-sensitivity'))
start.time <- Sys.time()
source("CLMPO-Query-Script.R")
Sys.time() - start.time

for(s in scenarios){
  i = which(scenarios==s) + 1
  foldernm = paste0(0, i, '-', s)
  copy.output(s=foldernm, f='ETSP-sensitivity')
}
