# Objective: Run the most recent VE version
# By: Dongmei Chen (dchen@lcog.org)
# August 26th, 2020 

source("DoOregonUpdate.R")
Base <- openModel("CLMPO-test")
Base$run()

Base$status
Base$groups
Base$tables
Base$fields
Base$fields$Name
Base$list()
Base$list(index = TRUE)
Base$list(pattern="Pop")
head(Base$inputs())
extr <- Base$extract()

Base$tables <- "Bzone"
Base$groups <- c("2040")

results <- Base$extract(saveTo = FALSE)
results[[1]]
summary(results[[1]]$D1B)

load("C:/Users/DChen/all/VE-RSPM/VisionEval/models/CLMPO-test/Datastore/2010/Bzone/Bzone.Rda")
Bzone <- Dataset[1:67]

Base$extract()
Base$extract(saveTo = "years-only")

#Base$fields <- Base$list(pattern="vmt")

TR <- Base$copy("TR-test")
STSRec <- Base$copy("STSRec-test")
TR$run()
STSRec$run()


# Scenario
RSPM_Sce <- openModel("VERSPM_Scenarios")
RSPM_Sce$run()
#scenarios = T
VERPAT_Sce <- openModel("VERPAT_Scenarios")
VERPAT_Sce$run()

# sensitivity testing
scenario <- openModel('B0C1D1E1F0G1I1P0T1V1')
scenario$run()

infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/" 
scenarios <- read.csv(paste0(infolder, "scenario_list.csv"), stringsAsFactors = FALSE)
tests <- scenarios$S[2:5]

for(test in tests){
  scenario <- openModel(test)
  scenario$run()
}
