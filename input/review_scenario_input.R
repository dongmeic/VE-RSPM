# Objective: Review the example scenario input folders to create CLMPO scenario data; 
# run the VERSPM_Scenarios model
# By: Dongmei Chen (dchen@lcog.org)
# September 23rd, 2020 

inpath <- 'C:/Users/DChen/all/VE-RSPM/VisionEval/models/VERSPM_Scenarios/scenario_inputs'
infolder <- 'C:/Users/DChen/all/VE-RSPM/VisionEval/models/model/inputs/'
input.files <- list.files(infolder, pattern = "^(.*)csv$")
  
json.files <- list.files(inpath, recursive = FALSE, pattern = "^(.*)json$")
all.files <- list.files(inpath, recursive = FALSE)
scen.folders <- all.files[!(all.files %in% json.files )]
scen.folders

# print out all the tables and compare with CLMPO data
path <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
sink(paste0(path, 'scenario_data_review.txt'))
for(folder in scen.folders){
  level.folders <- list.files(paste0(inpath, "/", folder), recursive = FALSE)
  for(level in level.folders){
    input.csvs <- list.files(paste0(inpath, "/", folder, '/', level), recursive = FALSE)
    for(csv in input.csvs){
      csvfilepath <- paste0(inpath, "/", folder, '/', level, '/', csv)
      dt <- read.csv(csvfilepath, stringsAsFactors = FALSE)
      cat(paste0('The scenario is ', folder, ', the level is ', level, ', and the input file is ', csv, '...\n'))
      cat('Here is the example:\n')
      print(dt)
      
      if(csv %in% input.files){
        cat('Here is the CLMPO data:\n')
        clmpo.dt <- read.csv(paste0(infolder, csv), stringsAsFactors = FALSE)
        print(clmpo.dt)
      }else{
        cat(paste(csv, 'is not available in the CLMPO input folder...\n'))
      }
    }
  }
}
sink()

# change the scenario input folders wth CLMPO data
# read the CLMPO scenario list
infile <- read_excel(paste0(path, "sensitivity_test_inputs.xlsx"), sheet = "newtest")
head(infile)

cats <- unique(infile$category_name)
convert.value <- function(value, variable){
  if(variable == 'CarSvcLevel'){
    return(value)
  }else{
    return(as.numeric(value))
  }
}

# clean the folders before writing new input files
do.call(file.remove, list(paste0(inpath, '/', list.files(inpath, recursive = TRUE, pattern = "^(.*)csv$"))))

for(cat in cats){
  lvls <- infile[infile$category_name == cat,]$policy_name
  for(lvl in lvls){
    csvs <- infile[infile$category_name == cat & infile$policy_name == lvl, ]$file
    for(csv in csvs){
      # make a copy of data
      csvfilepath <- paste0(inpath, "/", cat, '/', lvl, '/', csv)
      if(file.exists(csvfilepath)){
        cat(paste0(csvfilepath, ' already exists.\n'))
      }else{
        file.copy(from=paste0(infolder, csv), to=csvfilepath, 
                  overwrite = TRUE, 
                  copy.mode = TRUE)
      }
      dt <- read.csv(csvfilepath, stringsAsFactors = FALSE)
      vars <- infile[infile$category_name == cat & 
                       infile$policy_name == lvl & 
                       infile$file == csv, ]$variable
      for(var in vars){
        cities <- infile[infile$category_name == cat & 
                           infile$policy_name == lvl & 
                           infile$file == csv & 
                           infile$variable == var, ]$city
        if('NA' %in% cities){
          target.value <- infile[infile$category_name == cat & 
                                  infile$policy_name == lvl & 
                                  infile$file == csv & 
                                  infile$variable == var, ]$value
          dt[dt$Year == 2040,var] <- convert.value(target.value, variable = var)
        }else{
          for(cty in cities){
            target.value <- infile[infile$category_name == cat & 
                                     infile$policy_name == lvl & 
                                     infile$file == csv & 
                                     infile$variable == var &
                                     infile$city == cty, ]$value
            dt[substring(dt$Geo, 1, 3) %in% substring(cty, 1, 3) & dt$Year == 2040,var] <- convert.value(target.value, variable = var)
          }
        }
      }
      write.csv(dt, csvfilepath, row.names = FALSE)
    }
    cat(paste0('Category ', cat, ' in level ', lvl, ' is modified...\n'))
  }
  cat(paste0('Category ', cat, ' is ready...\n'))
}

verspm_scen <- openModel('VERSPM_Scenarios')
verspm_scen_test <- verspm_scen$copy('verspm_scen_test')
