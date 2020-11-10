#===========
#run_model.R - Modified to manually check the Calculate4DMeasures method.
#Author: Dan Flynn (Daniel.Flynn@dot.gov)
#Modified by: Dongmei Chen (dchen@lcog.org)
#===========

# Assumes model directory is named VERSPM_CLMPO, change as appropriate for how you named the model directory
# Assumes that VisionEval was launched in RStudio by double-clicking 'VisionEval.Rproj'. By doing this, the working directory is set to 
# the location of your VisionEval folder on your machine. 

library(tidyverse)

model_dir <- 'models/CLMPO' # Change as appropriate

setwd(model_dir)

#--------------
library(visioneval)

planType <- 'callr'

#Initialize model
#----------------
initializeModel(
  ModelScriptFile = "run_model.R",
  ParamDir = "defs",
  RunParamFile = "run_parameters.json",
  GeoFile = "geo.csv",
  ModelParamFile = "model_parameters.json",
  LoadDatastore = FALSE,
  DatastoreName = NULL,
  SaveDatastore = TRUE
  )  
cat('run_model.R: initializeModel completed\n')

#---------------------------------
# Run for just 2040
Year = '2040'

runModule("CreateHouseholds",                "VESimHouseholds",       RunFor = "AllYears",    RunYear = Year)
runModule("PredictWorkers",                  "VESimHouseholds",       RunFor = "AllYears",    RunYear = Year)
runModule("AssignLifeCycle",                 "VESimHouseholds",       RunFor = "AllYears",    RunYear = Year)
runModule("PredictIncome",                   "VESimHouseholds",       RunFor = "AllYears",    RunYear = Year)
runModule("PredictHousing",                  "VELandUse",             RunFor = "AllYears",    RunYear = Year)
runModule("LocateEmployment",                "VELandUse",             RunFor = "AllYears",    RunYear = Year)
runModule("AssignLocTypes",                  "VELandUse",             RunFor = "AllYears",    RunYear = Year)

#---------------------------------

# Now manually run Calculate4DMeasures, by running the steps of runModule manually for first few steps
# see runModule for these steps, in sources/framework/visioneval/R/visioneval.R
# this writes to the data store using setInDatastore, in sources/framework/visioneval/R/datastore.R
ModuleName = 'Calculate4DMeasures'
PackageName = 'VELandUse'
RunFor = "AllYears"
RunYear = Year

BaseYear <- getModelState()$BaseYear # 2010
Function <- paste0(PackageName, "::", ModuleName)
Specs <- paste0(PackageName, "::", ModuleName, "Specifications")
M <- list()

M$Func <- eval(parse(text = Function))
M$Specs <- processModuleSpecs(eval(parse(text = Specs)))
if (is.list(M$Specs$Call)) {
  Call <- list(Func = list(), Specs = list())
  for (Alias in names(M$Specs$Call)) {
    Function <- M$Specs$Call[[Alias]]
    if (length(unlist(strsplit(Function, "::"))) == 
        1) {
      Pkg_df <- getModelState()$ModuleCalls_df
      if (sum(Pkg_df$Module == Function) != 0) {
        Pkg_df <- getModelState()$ModuleCalls_df
        Function <- paste(Pkg_df$Package[Pkg_df$Module == 
                                           Function], Function, sep = "::")
        rm(Pkg_df)
      }
      else {
        Pkg_df <- getModelState()$ModulesByPackage_df
        Function <- paste(Pkg_df$Package[Pkg_df$Module == 
                                           Function], Function, sep = "::")
        rm(Pkg_df)
      }
    }
    Specs <- paste0(Function, "Specifications")
    Call$Func[[Alias]] <- eval(parse(text = Function))
    Call$Specs[[Alias]] <- processModuleSpecs(eval(parse(text = Specs)))
    Call$Specs[[Alias]]$RunBy <- M$Specs$RunBy
  }
}
Errors_ <- character(0)
Warnings_ <- character(0)

# Get the List from the Datastore here
L <- getFromDatastore(M$Specs, RunYear = Year)

# Check the units after fetching from datastore. Since M$Specs says to get the area in acres, it is converted from sqmi to acres in getFromDatastore
M$Specs$Get[[8]]$NAME
M$Specs$Get[[8]]$UNITS

attr(L$Year$Bzone$UrbanArea, 'UNITS')

# -------------------------------
# Now manually running Calculate4DMeasures steps here.

# Take a look at the Bzone area and population components
# These are steps from Calculate4DMeasures
# Eug-41039003700 has 81.98775111 acres of urban and zero of other in the input file,
# bzone_unprotected_area.csv

set.seed(L$G$Seed)
#Define a vector of Bzones
Bz <- L$Year$Bzone$Bzone
#Create data frame of Bzone data
D_df <- data.frame(L$Year$Bzone)
D_df$Area <- D_df$UrbanArea + D_df$TownArea + D_df$RuralArea

# Examine area of Eug-41039003700

D_df %>% 
  filter(Bzone == 'Eug-41039003700') # Area is 81.98775

#Initialize list
Out_ls <- initDataList()

#Calculate density measures
#--------------------------
#Population density
D1B_ <- with(D_df, Pop / Area)
#Check for high population density values and add warning
IsHighDensity_ <- D1B_ > 100
HighDensityBzones_ <- Bz[IsHighDensity_]
if (any(IsHighDensity_)) {
  Msg <- paste0(
    "The following Bzones in the year ", L$G$Year, " ",
    "have population densities greater than ",
    "100 persons per acre: ", paste(HighDensityBzones_, collapse = ", "), ". ",
    "This density is a relatively high level. ",
    "Check your Bzone area and housing inputs for these Bzones and make ",
    "sure that they are correct."
  )
  print(Msg)
  addWarningMsg("Out_ls", Msg)
  rm(Msg)
}
rm(IsHighDensity_, HighDensityBzones_)
#Employment density
D1C_ <- with(D_df, TotEmp / Area)
#Activity density
D1D_ <- with(D_df, (TotEmp + NumHh) / Area)

# Examine D1B_ output
D1B_[Bz == 'Eug-41039003700'] # 100.9419 persons/acre in out Bzone of interest

pop = D_df$Pop[Bz == 'Eug-41039003700'] # 8276
area = D_df$Area[Bz == 'Eug-41039003700'] # 81.98775

pop/area # 100.9419 persons per acre

# -------------------------------
# Back to runModule steps 
# !!! This is the step that runs Calculate4DMeasures on the list L

R <- M$Func(L)
  
# Examine results from the runModule approach to this step
R$Year$Bzone$D1B[L$Year$Bzone$Bzone == 'Eug-41039003700'] # 100.9419, same as before

# Ok, so far looks good. Now use the standard approach to calling Calculate4DMeasures, then we will examine the ouput in the datastore

runModule("Calculate4DMeasures",             "VELandUse",             RunFor = "AllYears",    RunYear = Year)

# Now look at the output in the datastore
output_to_load = 'Datastore/2040/Bzone/D1B.Rda'

load(file.path(output_to_load))

attr(Dataset, 'UNITS') # Persons per square mile now!
Dataset[Bz == 'Eug-41039003700'] # 64602.82 persons per square mile

# When did the conversion happen? Multiple times, in fact.
# First, in initialzeModel, the default area is set to the units in defs/units.csv
# When running getFromDatastore(), conversion happens to put back in to the units in M$Specs.
# Then after the module calculations are complete, setInDatastore writes the values back to the datastore, using the default units.

# Manual runModule Steps --------------- 
# manually step through runModule, using these inputs. 

ModuleName = 'Calculate4DMeasures'
PackageName = 'VELandUse'
RunFor = "AllYears"
RunYear = Year

# Then step through runModule function manually
