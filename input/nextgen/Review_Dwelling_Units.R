# Objective: adjust group quarter (GQ) dwelling units to include only non-institutional GQ
# By: Dongmei Chen (dchen@lcog.org)
# October 28th, 2022
# Source: dwelling_units.R, Test_D1B_Issue.R, run_model_Test_4D_Calculations.R

library(stringr)
library(sf)
library(tidyverse)

#setwd("T:/Models/VisionEval/VE-3.0-Installer-Windows-R4.1.3_2022-05-27")

infolder <- "T:/DCProjects/Data/Census/P5/DECENNIALPL2020.P5_2022-10-28T180822"
cltracts <- st_read(dsn = 'T:/Trans Projects/Model Development/UrbanSim_LandUse/Inputs/VisionEval',
                    layer = 'CLTracts_GsBoundary',
                    stringsAsFactors = FALSE)

############################################### Check group quarters by type #######################################################
# group quarters population by major group quarters type
gq_by_type <- read.csv(file.path(infolder, "DECENNIALPL2020.P5-Data.csv"), stringsAsFactors = FALSE)
bzone_du <- read.csv(file.path("models/CLMPO-base/inputs", "bzone_dwelling_units.csv"), stringsAsFactors = FALSE)
gq_by_type$GeoID <- str_split(gq_by_type$GEO_ID, "US", simplify = TRUE)[,2]
bzone_du$GeoID <- str_split(bzone_du$Geo, "-", simplify = TRUE)[,2]

gq_by_type <- gq_by_type[-1,]
gq_by_type$PCT_N <- mapply(function(x, y) if(y==0){0}else{as.numeric(x)/as.numeric(y)}, gq_by_type$P5_007N, gq_by_type$P5_001N)
bzone_du_N <- merge(bzone_du, gq_by_type[,c('GeoID', 'PCT_N')], by="GeoID")
head(bzone_du_N)
bzone_du_N$GQDU <- bzone_du_N$GQDU * bzone_du_N$PCT_N
bzone_du_N[bzone_du_N$Geo == 'Eug-41039003700',]$GQDU
bzone_du[bzone_du$Geo == 'Eug-41039003700',]$GQDU
bzone_du_N[bzone_du_N$Geo == 'Eug-41039003700',]$GQDU
bzone_du_N[bzone_du_N$Geo == 'Eug-41039003700',]$PCT_N

# the highest GQ population is 100% non-institutional
summary(as.numeric(gq_by_type$P5_001N))
gq_by_type[gq_by_type$GeoID == '41039003700',]$P5_001N

head(bzone_du_N)
bzone_du_N$GQDU <- bzone_du_N$GQDU * bzone_du_N$PCT_N
write.csv(bzone_du_N[, names(bzone_du)[1:5]],
          file.path("models/CLMPO-base/inputs", "bzone_dwelling_units.csv"),
          row.names = FALSE)

bzone_du <- read.csv(file.path("models/CLMPO-base/inputs", "bzone_dwelling_units.csv"),
                     stringsAsFactors = FALSE)
bzone_du[bzone_du$Geo == 'Eug-41039003700', 'GQDU'] <- c(1419, 1670)
write.csv(bzone_du,
          file.path("models/CLMPO-base/inputs", "bzone_dwelling_units.csv"),
          row.names = FALSE)


############################################### Visualize high-density bzones #######################################################
model_dir <- 'models/CLMPO-base' # Change as appropriate

geo <- read_csv(file.path(model_dir, 'defs', 'geo.csv'))

output_to_load = 'results/Datastore/2040/Bzone/D1B.Rda'

if(!file.exists(file.path(model_dir, output_to_load))){
  stop('File not found. Please complete the VERSPM base run before running this script')
}

load(file.path(model_dir, output_to_load))
# Load area file
bzone_unprotected_area <- read_csv(file.path(model_dir, 'inputs', 'bzone_unprotected_area.csv'))


# Join geography with output files ----

geo <- geo %>%
  mutate(D1B = Dataset) %>%
  left_join(bzone_unprotected_area, by = c('Bzone' = 'Geo'))

# Make a label column for only the most dense Bzones
geo <- geo %>%
  mutate(D1B_rank = rank(1/D1B),
         high_density_Bzones = ifelse(D1B_rank < 10, Bzone, NA))

# Make a plot of area by density
ggplot(geo %>% filter(Year == '2040'), aes(x = UrbanArea,
                                           y = D1B,
                                           label = high_density_Bzones)) +
  geom_point() +
  geom_text(size = 4, hjust = -0.1)

ggsave('debugging/Density_vs_Area_by_Bzone.jpeg')


# Adding examination of dwelling units ----

bzdu <- read_csv(file.path(model_dir, 'inputs', 'bzone_dwelling_units.csv'))

bzdu10 <- bzdu %>%
  filter(Year == "2040") %>%
  select(Geo, SFDU, MFDU) %>%
  rename(Bzone = Geo) %>%
  mutate(AllDU = SFDU + MFDU)

# Join with the existing geo file by Bzone

geo <- geo %>%
  left_join(bzdu10, by = 'Bzone')

# Calculate proportions
geo <- geo %>%
  mutate(DUperArea = AllDU / UrbanArea)

# Plot
ggplot(geo, aes(x = DUperArea,
                y = D1B,
                color = UrbanArea,
                label = high_density_Bzones)) +
  geom_point() +
  geom_text(size = 4, hjust = 1.1)

ggsave('debugging/Density_vs_DUperArea_by_Bzone.jpeg')

############################################### run model to test 4D calculations #######################################################

setwd(model_dir)

#--------------
library(visioneval)

planType <- 'callr'

#Initialize model
#----------------
initializeModel(
  ModelScriptFile = "scripts/run_model.R",
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



