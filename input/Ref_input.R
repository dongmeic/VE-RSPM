# Objective: Modify the reference scenario input
# By: Dongmei Chen (dchen@lcog.org)
# November 6th, 2020

inpath <- 'E:/VisionEval/models/CLMPO/inputs'
# list CSV files
csvfiles <- list.files(path = inpath, pattern = ".csv")
print(csvfiles)

infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
infile <- read_excel(paste0(infolder, "sensitivity_test_inputs.xlsx"), sheet = "clmpo")
head(infile)

for(csv in csvfiles){
  if(csv %in% unique(infile$file)){
    dt <- read.csv(paste0(inpath, '/', csv), stringsAsFactors = FALSE, 
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
      if(var %in% unique(infile[infile$file == csv,]$variable)){
        target <- infile$file == csv & infile$variable == var & infile$policy_name == 1 & infile$strategy_level %in% c(0, 1)
        if('NA' %in% infile[target,]$city){
          if(var == 'CarSvcLevel'){
            dt[dt$Year == 2040, var] <- unique(infile[target,]$value)
          }else{
            dt[dt$Year == 2040, var] <- as.numeric(unique(infile[target,]$value))
          }
        }else{
          dt[dt$Year == 2040,var] <- as.numeric(infile[target,]$value)
        }
      }
    }
    cat('After:\n')
    print(dt)
    write.csv(dt, paste0(inpath, '/', csv), row.names = FALSE)
  }
}