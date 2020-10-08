#setwd(paste0(getwd(),"/models/",Sc)) 
 
 library(visioneval)
 library(VEReports)
 Year <-c("2010", "2040")
 Ma<-"CLMPO"


 ##Function To pull the outputs from DataStore
 calcMetropolitanMeasures <- 
  function(Year, Ma, DstoreLocs_ = c("Datastore"), DstoreType = "RD") {
    
    #Prepare for datastore queries
    #-----------------------------
    QPrep_ls <- prepareForDatastoreQuery(
      DstoreLocs_ = DstoreLocs_,
      DstoreType = DstoreType
    )
    
    #Define function to create a data frame of measures
    #--------------------------------------------------
    makeMeasureDataFrame <- function(DataNames_, Ma) {
      if (length(Ma) > 1) {
        Data_XMa <- t(sapply(DataNames_, function(x) get(x)))
      } else {
        Data_XMa <- t(t(sapply(DataNames_, function(x) get(x))))
      }
      colnames(Data_XMa) <- Ma
      Measures_ <- gsub("_Ma", "", DataNames_)
      Units_ <- 
        unname(sapply(DataNames_, function(x) attributes(get(x))$Units))
      Description_ <- 
        unname(sapply(DataNames_, function(x) attributes(get(x))$Description))
      Data_df <- cbind(
        Measure = Measures_,
        data.frame(Data_XMa),
        Units = Units_,
        Description = Description_
      )
      rownames(Data_df) <- NULL
      Data_df
    }

    #===========================================================        
    #PBOT Measures
    #===========================================================
##############################################################################################################################################################################################################################################################################
    #### DVMT
     #Urban area household DVMT
      #--------------------
      UrbanHhDvmt_Ma <- summarizeDatasets(
        Expr = "sum(UrbanHhDvmt)",
        Units_ = c(
          UrbanHhDvmt = "MI/DAY",
          Marea = ""
        ),
        By_ = "Marea",
        Table = "Marea",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )[Ma]
      attributes(UrbanHhDvmt_Ma) <- list(
        Units = "Miles per day",
        Description = "Daily vehicle miles traveled by households residing in the urban area"
      )
      
   # #Urban area household DVMT in Multnomah county
#    UrbanHhDvmt_MaAz <- summarizeDatasets(
#        Expr = "sum(Dvmt[Azone == 'Multnomah' & LocType == 'Urban'] )",
#        Units_ = c(
#          Dvmt = "MI/DAY",
#          LocType = "",
#          Azone = "",
#          Marea = ""
#        ),
#        By_ = "Marea",
#        Table = "Household",
#        Group = Year,
#        QueryPrep_ls = QPrep_ls
#      )[Ma]
#     attributes(UrbanHhDvmt_MaAz) <- list(
#        Units = "Miles per day",
#        Description = "Daily vehicle miles traveled by households residing in the urban area in Multnomah county"
#      )
#    
    #Urban area household DVMT in mix use
    UrbanHhDvmt_MaAzMx <- summarizeDatasets(
        Expr = "sum(Dvmt[IsUrbanMixNbrhd == '1'] )",
        Units_ = c(
          Dvmt = "MI/DAY",
          LocType = "",
          Azone = "",
          IsUrbanMixNbrhd = "",
          Marea = ""
        ),
        By_ = "Marea",
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )[Ma]
     attributes(UrbanHhDvmt_MaAzMx) <- list(
        Units = "Miles per day",
        Description = "Daily vehicle miles traveled by households residing in mixed use"
      )
    
    #Urban area public transit 'van' DVMT
    #-------------------------------
    UrbanVanDvmt_Ma <- summarizeDatasets(
      Expr = "sum(VanDvmt)",
      Units = c(
        VanDvmt = "MI/DAY",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanVanDvmt_Ma) <- list(
      Units = "Miles per day",
      Description = "Daily vehicle miles traveled by on-demand transit vans in the Urban area."
    )
    
        #Urban area commercial service vehicle DVMT
    #-------------------------------------
    UrbanComSvcDvmt_Ma <- summarizeDatasets(
      Expr = "sum(ComSvcUrbanDvmt)",
      Units = c(
        ComSvcUrbanDvmt = "MI/DAY",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanComSvcDvmt_Ma) <- list(
      Units = "Miles per day",
      Description = "Commercial service vehicle daily vehicle miles traveled attributable to the demand of households and businesses located in the urban area"
    )
    
    #Urban area light-duty vehicle DVMT
    #-----------------------------
    UrbanLdvDvmt_Ma <- UrbanHhDvmt_Ma + UrbanVanDvmt_Ma + UrbanComSvcDvmt_Ma
    attributes(UrbanLdvDvmt_Ma) <- list(
      Units = "Miles per day",
      Description = "Sum of daily vehicle miles traveled by households residing in the urban area, commercial service travel attributable to the demand of urban area households and businesses, and on-demand transit van travel in the urban area."
    )
    
    #Urban Population in Marea
    #-------------------
    UrbanHhPop_Ma <- summarizeDatasets(
      Expr = "sum(HhSize)",
      Units_ = c(
        HhSize = "",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHhPop_Ma) <- 
      list(Units = "Persons",
           Description = "Number of persons residing in urban area")
     
  #  #Urban Population in Multnomah county
#    #-------------------
#    UrbanHhPop_MaAz <- summarizeDatasets(
#      Expr = "sum(HhSize[Azone == 'Multnomah' & LocType == 'Urban'])",
#      Units_ = c(
#        HhSize = "",
#        LocType = "",
#        Azone = "",
#        Marea = ""
#      ),
#      By_ = "Marea",
#      Table = "Household",
#      Group = Year,
#      QueryPrep_ls = QPrep_ls
#    )[Ma]
#    attributes(UrbanHhPop_MaAz) <- 
#      list(Units = "Persons",
#           Description = "Number of persons residing in urban area in Multnomah county")
#     
     #Urban Population in mixed use
    #-------------------
    UrbanHhPop_MaAzMx <- summarizeDatasets(
      Expr = "sum(HhSize[IsUrbanMixNbrhd == '1'])",
      Units_ = c(
        HhSize = "",
        LocType = "",
        Azone = "",
        IsUrbanMixNbrhd = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHhPop_MaAzMx) <- 
      list(Units = "Persons",
           Description = "Number of persons residing in mixed use in urban area")

     #Urban Population in mixed use
    #-------------------

        UrbanHhPopLowInc_Ma <- summarizeDatasets(
      Expr = "sum(HhSize)",
      Units_ = c(
        HhSize = "",
        LocType = "",
        Income = "USD",
        Marea = ""
      ),
      By_ = c(
          "Income",
          "Marea"),
      Breaks_ls = list(
          Income = c(20000, 40000, 60000, 80000, 100000)
      ),    
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[,Ma][1]
    attributes(UrbanHhPopLowInc_Ma) <- 
      list(Units = "Persons",
           Description = "Number of persons in low income (0to20K 2010$) households residing in urban area")


     
     #DVMT per Capita in Marea
     UrbanLdvDmvtPerCap_Ma <- UrbanLdvDvmt_Ma / UrbanHhPop_Ma     
     attributes(UrbanLdvDmvtPerCap_Ma) <- list(
      Units = "Dvmt per person",
      Description = "daily vehicle miles traveled per person residing in the urban area."
    )
    
    #urban DVMT per Capita in Multnomah county
     UrbanLdvDmvtPerCap_MaAz <- UrbanHhDvmt_Ma / UrbanHhPop_Ma    
     attributes(UrbanLdvDmvtPerCap_MaAz) <- list(
      Units = "Dvmt per person",
      Description = "daily vehicle miles traveled per person residing in the urban area."
    )
    
    #urban DVMT per Capita in mixed use in Multnomah county
     UrbanLdvDmvtPerCap_MaAzMx <- UrbanHhDvmt_MaAzMx / UrbanHhPop_MaAzMx     
     attributes(UrbanLdvDmvtPerCap_MaAzMx) <- list(
      Units = "Dvmt per person",
      Description = "daily vehicle miles traveled per person residing in mixed use in the urban area."
    )


    
    #Urban area Bus DVMT
    #-------------------------------
    UrbanBusDvmt_Ma <- summarizeDatasets(
      Expr = "sum(BusFwyDvmt)+ sum(BusArtDvmt) + sum(BusOthDvmt)",
      Units = c(
        BusFwyDvmt = "MI/DAY",
        BusArtDvmt = "MI/DAY",
        BusOthDvmt = "MI/DAY",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanBusDvmt_Ma) <- list(
      Units = "Miles per day",
      Description = "Daily vehicle miles traveled by Bus in the Urban area."
    )
    
    #Urban area Hvy Trk DVMT
    #-------------------------------
    UrbanHvyTrkDvmt_Ma <- summarizeDatasets(
      Expr = "sum(HvyTrkFwyDvmt)+ sum(HvyTrkArtDvmt) + sum(HvyTrkOthDvmt)",
      Units = c(
        HvyTrkFwyDvmt = "MI/DAY",
        HvyTrkArtDvmt = "MI/DAY",
        HvyTrkOthDvmt = "MI/DAY",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHvyTrkDvmt_Ma) <- list(
      Units = "Miles per day",
      Description = "Daily vehicle miles traveled by Heavy Truck in the Urban area."
    )
    
    #Urban area Rail DVMT
    #-------------------------------
    UrbanRailDvmt_Ma <- summarizeDatasets(
      Expr = "sum(RailDvmt)",
      Units = c(
        RailDvmt = "MI/DAY",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanRailDvmt_Ma) <- list(
      Units = "Miles per day",
      Description = "Daily vehicle miles traveled by Rail in the Urban area."
    )
    
    
#############################################################################################################################################################################################################################################################################   
    ###Annual Fuel Use
    #Household fuel consumption for Urban
    #------------------------------------
    UrbanHhGGE_Ma <- summarizeDatasets(
      Expr = "sum(DailyGGE)",
      Units = c(
        DailyGGE = "GGE/DAY",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHhGGE_Ma) <- list(
      Units = "Gas gallon equivalents per day",
      Description = "Average daily fuel consumption for the travel of households residing in the Urban"
    )
    
    #Commercial service fuel consumption for Urban
    #---------------------------------------------
    UrbanComSvcGGE_Ma <- summarizeDatasets(
      Expr = "sum(ComSvcUrbanGGE )",
      Units = c(
        ComSvcUrbanGGE = "GGE/DAY",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanComSvcGGE_Ma) <- list(
      Units = "Gas gallon equivalents per day",
      Description = "Average daily fuel consumption for commercial services vehicle travel arising from households and businesses located in the Urban"
    )
    
    #Public transit van fuel consumption for Urban area
    #---------------------------------------------
    UrbanVanGGE_Ma <- summarizeDatasets(
      Expr = "sum(VanGGE)",
      Units = c(
        VanGGE = "GGE/DAY",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanVanGGE_Ma) <- list(
      Units = "Gas gallon equivalents per day",
      Description = "Average daily fuel consumption for public transit van in the urban area"
    )
    
    #Light-duty vehicle fuel consumption for urban area
    #---------------------------------------------
    UrbanLdvGGE_Ma <- UrbanHhGGE_Ma + UrbanComSvcGGE_Ma + UrbanVanGGE_Ma
    attributes(UrbanVanGGE_Ma) <- list(
      Units = "Gas gallon equivalents per day",
      Description = "Average daily fuel consumption for light-duty vehicle travel attributable to households and businesses in the urban area"
    )
    
    #Bus fuel consumption for urban area
    #---------------------------------------------
    UrbanBusGGE_Ma <- summarizeDatasets(
      Expr = "sum(BusGGE)",
      Units = c(
        BusGGE = "GGE/DAY",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanBusGGE_Ma) <- list(
      Units = "Gas gallon equivalents per day",
      Description = "Average daily fuel consumption for Bus in the urban area"
    )
    
    #Rail fuel consumption for urban area
    #---------------------------------------------
    UrbanRailGGE_Ma <- summarizeDatasets(
      Expr = "sum(RailGGE)",
      Units = c(
        RailGGE = "GGE/DAY",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanRailGGE_Ma) <- list(
      Units = "Gas gallon equivalents per day",
      Description = "Average daily fuel consumption for Rail in the urban area"
    )
    
    #Heavy truck fuel consumption for Urban area
    #---------------------------------------------
    UrbanHvyTrkGGE_Ma <- summarizeDatasets(
      Expr = "sum(HvyTrkUrbanGGE)",
      Units = c(
        HvyTrkUrbanGGE = "GGE/DAY",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHvyTrkGGE_Ma) <- list(
      Units = "Gas gallon equivalents per day",
      Description = "Average daily fuel consumption for heavy truck in the urban area"
    )
#####################################################################################################################################################################################################################################################################    
    
    ### Household vehicle ownership
    #Number of households in urban area
    #--------------------------------------
    UrbanHhNum_Ma <- summarizeDatasets(
      Expr = "count(HhSize)",
      Units_ = c(
        HhSize = "",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHhNum_Ma) <- 
      list(Units = "Households",
           Description = "Number of households residing in urban area")
    
    #Household Number of vehicles in urban area
    #------------------
    UrbanHhVehicles_Ma <- summarizeDatasets(
      Expr = "sum(NumAuto) + sum(NumLtTrk)",
      Units_ = c(
        NumAuto = "VEH",
        NumLtTrk = "VEH",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHhVehicles_Ma) <- 
      list(Units = "Household light-duty vehicles",
           Description = "Total number of light-duty vehicles owned/leased by households residing in urban area")
    
    #Average number of vehicles per household in urban area
    #----------------------------------------
    UrbanHhAveVehPerHh_Ma <- UrbanHhVehicles_Ma / UrbanHhNum_Ma
    attributes(UrbanHhAveVehPerHh_Ma) <- 
      list(Units = "Household light-duty vehicles per household",
           Description = "Average number of light-duty vehicles owned/leased by households residing in urban area")
    
    #Number of workers in urban
    #--------------------------
    UrbanHhWorkers_Ma <- summarizeDatasets(
      Expr = "sum(Workers)",
      Units_ = c(
        Workers = "PRSN",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHhWorkers_Ma) <- 
      list(Units = "Workers",
           Description = "Number of workers residing in urban")
    
    #Number of drivers in urban
    #--------------------------
    UrbanHhDrivers_Ma <- summarizeDatasets(
      Expr = "sum(Drivers)",
      Units_ = c(
        Drivers = "PRSN",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHhDrivers_Ma) <- 
      list(Units = "Drivers",
           Description = "Number of drivers residing in urban")
     
     #Number of households in urban-mixed neighborhoods
    #-------------------------------------------------
    if (isDatasetPresent("LocType", "Bzone", Year, QPrep_ls)) {
      NumUrbanMixHh_Ma <- summarizeDatasets(
        Expr = "sum(IsUrbanMixNbrhd)",
        Units_ = c(
          IsUrbanMixNbrhd = "",
          LocType = "category",
          Marea = ""
        ),
        By_ = "Marea",
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )[Ma]
    } else {
      NumUrbanMixHh_Ma <- summarizeDatasets(
        Expr = "sum(IsUrbanMixNbrhd)",
        Units_ = c(
          IsUrbanMixNbrhd = "",
          Marea = ""
        ),
        By_ = "Marea",
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )[Ma]
    }
    attributes(NumUrbanMixHh_Ma) <- list(
      Units = "Households",
      Description = "Number of households residing in urban-mixed neighborhoods in urbanized area"
    )
           
########################################################################################################################################################################################################################################################################    
    ### CO2
    #Household CO2e for urban area
    #------------------------
    UrbanHhCO2e_Ma <- summarizeDatasets(
      Expr = "sum(DailyCO2e)",
      Units = c(
        DailyCO2e = "MT/YR",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHhCO2e_Ma) <- list(
      Units = "Metric tons CO2e per year",
      Description = "Average annual production of greenhouse gas emissions from light-duty vehicle travel by households residing in the urban area"
    )
    
    #Commercial service CO2e for urban area
    #---------------------------------
    UrbanComSvcCO2e_Ma <- summarizeDatasets(
      Expr = "sum(ComSvcUrbanCO2e)",
      Units = c(
        ComSvcUrbanCO2e = "MT/YR",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanComSvcCO2e_Ma) <- list(
      Units = "Metric tons CO2e per year",
      Description = "Average annual production of greenhouse gas emissions from commercial service light-duty vehicle travel attributable to households and businesses in the urban area"
    )
    
    #Van CO2e for urban area
    #------------------
    UrbanVanCO2e_Ma <- summarizeDatasets(
      Expr = "sum(VanCO2e)",
      Units = c(
        VanCO2e = "MT/YR",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanVanCO2e_Ma) <- list(
      Units = "Metric tons CO2e per year",
      Description = "Average annual production of greenhouse gas emissions from public transit van travel in the urban area"
    )
    
    #Light-duty vehicle CO2e for urban area
    #---------------------------------
    UrbanLdvCO2e_Ma <- UrbanHhCO2e_Ma + UrbanVanCO2e_Ma + UrbanComSvcCO2e_Ma
    attributes(UrbanLdvCO2e_Ma) <- list(
      Units = "Metric tons CO2e per year",
      Description = "Average annual production of greenhouse gas emissions from light-duty vehicle travel of households and businesses in the urban area"
    )
    
    #Light-duty vehicle CO2e Rate for urban area
    #---------------------------
     UrbanLdvCO2eRate_Ma <- UrbanLdvCO2e_Ma / (UrbanLdvDvmt_Ma * 365)
    attributes(UrbanLdvCO2eRate_Ma) <- list(
      Units = "Grams CO2e per mile",
      Description = "Average greenhouse gas emissions per mile of light duty vehicle travel in the urban area"
    )
    
    #Bus CO2e for urban area
    #---------------------------
    UrbanBusCO2e_Ma <- summarizeDatasets(
      Expr = "sum(BusCO2e)",
      Units = c(
        BusCO2e = "MT/YR",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanBusCO2e_Ma) <- list(
      Units = "Metric tons CO2e per year",
      Description = "Average annual production of greenhouse gas emissions from public transit bus travel in the urban area"
    )
    
    #Rail CO2e for urban area
    #---------------------------
    UrbanRailCO2e_Ma <- summarizeDatasets(
      Expr = "sum(RailCO2e)",
      Units = c(
        RailCO2e = "MT/YR",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanRailCO2e_Ma) <- list(
      Units = "Metric tons CO2e per year",
      Description = "Average annual production of greenhouse gas emissions from Rail travel in the urban area"
    )
    
    #Bus CO2e Rate for urban area
    #---------------------------
    UrbanBusCO2eRate_Ma <- (UrbanBusCO2e_Ma * 1000000) / (UrbanBusDvmt_Ma * 365)
    attributes(UrbanBusCO2eRate_Ma) <- list(
      Units = "grams CO2e per mile",
      Description = "Average greenhouse gas emissions per mile of public transit bus travel in the urban area"
    )
    
    #Heavy Truck CO2e for Urban
    #---------------------------
    UrbanHvyTrkCO2e_Ma <- summarizeDatasets(
      Expr = "sum(HvyTrkUrbanCO2e)",
      Units = c(
        HvyTrkUrbanCO2e = "MT/YR",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHvyTrkCO2e_Ma) <- list(
      Units = "Metric tons CO2e per year",
      Description = "Average annual production of greenhouse gas emissions from heavy truck travel in the urban area"
    )
    
    #Heavy Truck CO2e Rate for urban area
    #---------------------------
    UrbanHvyTrkAveCO2eRate_Ma <- (UrbanHvyTrkCO2e_Ma * 1000000) / (UrbanHvyTrkDvmt_Ma * 365)
    attributes(UrbanHvyTrkAveCO2eRate_Ma) <- list(
      Units = "Grams CO2e per mile",
      Description = "Average greenhouse gas emissions per mile of heavy truck travel in the urban area"
    )
    
#################################################################################################################################################################################################################################################################    
    ###Trips, Delay, Speed and Mode shift 
    #Walk Trips in Urban area          
      UrbanWalkTrips_Ma <- summarizeDatasets(
            Expr = "sum(WalkTrips)",
            Units_ = c(
              WalkTrips = "TRIP/DAY",
              LocType = "",
              Marea = ""
            ),
            By_ = "Marea",
            Table = "Household",
            Group = Year,
            QueryPrep_ls = QPrep_ls
            )[Ma]
      attributes(UrbanWalkTrips_Ma) <- 
          list(Units = "Trips per Day",
            Description = "Average number walk trips per day in urban area")  

      #Bike Trips in Urban area          
      UrbanBikeTrips_Ma <- summarizeDatasets(
            Expr = "sum(BikeTrips)",
            Units_ = c(
              BikeTrips = "TRIP/DAY",
              LocType = "",
              Marea = ""
            ),
            By_ = "Marea",
            Table = "Household",
            Group = Year,
            QueryPrep_ls = QPrep_ls
          )[Ma]
      attributes(UrbanBikeTrips_Ma) <- 
          list(Units = "Trips per Day",
            Description = "Average number bike trips per day in urban area")                

      #Transit Trips in Urban area          
      UrbanTransitTrips_Ma <- summarizeDatasets(
            Expr = "sum(TransitTrips)",
            Units_ = c(
              TransitTrips = "TRIP/DAY",
              LocType = "",
              Marea = ""
            ),
            By_ = "Marea",
            Table = "Household",
            Group = Year,
            QueryPrep_ls = QPrep_ls
          )[Ma]
      attributes(UrbanTransitTrips_Ma) <- 
          list(Units = "Trips per Day",
            Description = "Average number transit trips per day in urban area") 
    
    #Mode shift Trips in urban area
    #------------------
    UrbanModeShiftTrips_Ma<- UrbanWalkTrips_Ma+UrbanBikeTrips_Ma+UrbanTransitTrips_Ma 
    attributes(UrbanModeShiftTrips_Ma) <- 
      list(Units = "Trips per Day",
           Description = "Average number mode shift trips (Bike, Walk, & Transit) per day in urban area")
     
     
     ###Hours of congestion (total delay of ldv and hvy trk)
     #total delay of ldv in urban area
    #---------------------------
    UrbanLdv_TotalDelay_Ma <- summarizeDatasets(
      Expr = "sum(LdvTotDelay)",
      Units = c(
        LdvTotDelay = "HR",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanLdv_TotalDelay_Ma) <- list(
      Units = "Hours",
      Description = "Total light-duty vehicle delay (hours per day) on urban area roads"
    )                 
     
     #total delay of hvy trk in urban area
    #---------------------------
    UrbanHvyTrk_TotalDelay_Ma <- summarizeDatasets(
      Expr = "sum(HvyTrkTotDelay)",
      Units = c(
        HvyTrkTotDelay = "HR",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHvyTrk_TotalDelay_Ma) <- list(
      Units = "Hours",
      Description = "Total heavy truck vehicle delay (hours per day) on urban area roads"
    )
          
     #total delay of ldv and hvy trk in urban area
    #---------------------------
    UrbanLdv_HvyTrk_TotalDelay_Ma <- UrbanLdv_TotalDelay_Ma + UrbanHvyTrk_TotalDelay_Ma
    attributes(UrbanLdv_HvyTrk_TotalDelay_Ma) <- list(
      Units = "Hours",
      Description = "Total light duty vehicle and heavy truck delay (hours per day) on the urban area roads"
    )
    
    #Ligh duty vehicle speed in urban area
    #---------------------------
    UrbanLvdAveSp_Ma <- summarizeDatasets(
      Expr = "mean(LdvAveSpeed)",
      Units = c(
        LdvAveSpeed = "MI/HR",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanLvdAveSp_Ma) <- list(
      Units = "Miles per Hour",
      Description = "Average speed (miles per hour) of light-duty vehicle travel on urban area roads"
    )
          
    #Heavy truck speed in urban area
    #---------------------------
    UrbanHvyTrkAveSp_Ma <- summarizeDatasets(
      Expr = "mean(HvyTrkAveSpeed)",
      Units = c(
        HvyTrkAveSpeed = "MI/HR",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanHvyTrkAveSp_Ma) <- list(
      Units = "Miles per Hour",
      Description = "Average speed (miles per hour) of heavy truck travel on urban area roads"
    )
    
    #Bus speed in urban area
    #---------------------------
    UrbanBusAveSp_Ma <- summarizeDatasets(
      Expr = "mean(BusAveSpeed)",
      Units = c(
        BusAveSpeed = "MI/HR",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Marea",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanBusAveSp_Ma) <- list(
      Units = "Miles per Hour",
      Description = "Average speed (miles per hour) of bus travel on urban area roads"
    ) 
###########################################################################################################################################################################################################################################################################     
    ###Household Transportation Costs as Percentage of Income      
    #Vehicle ownership cost in urban area
    #------------------
    UrbanVehOwnershipCost_Ma <- summarizeDatasets(
      Expr = "mean(OwnCost)",
      Units_ = c(
        OwnCost = "USD",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanVehOwnershipCost_Ma) <- 
      list(Units = "USD per year",
           Description = "Average annual household vehicle ownership cost (depreciation, finance, insurance, taxes) in urban area")
     
    #Vehicle average out-of-pocket cost in dollars per mile of vehicle travel in urban area
    #------------------
    UrbanAveVehCostPM_Ma <- summarizeDatasets(
      Expr = "mean(AveVehCostPM)",
      Units_ = c(
        AveVehCostPM = "USD",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanAveVehCostPM_Ma) <- 
      list(Units = "USD",
           Description = " Average out-of-pocket cost in dollars per mile of vehicle travel in urban area")
           
    #Vehicle Operating cost in urban area
    #------------------
    UrbanVehOperatingCost_Ma <- summarizeDatasets(
      Expr = "mean(AveVehCostPM) * mean(Dvmt)*365",
      Units_ = c(
        AveVehCostPM = "USD",
        Dvmt = "MI/DAY",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanVehOperatingCost_Ma) <- 
      list(Units = "USD per year",
           Description = " Average annual household vehicle operating cost in urban area")
     
    #Total annual household income in urban area
    #------------------
    UrbanTotalHhIncome_Ma <- summarizeDatasets(
      Expr = "sum(Income)",
      Units_ = c(
        Income = "USD",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanTotalHhIncome_Ma) <- 
      list(Units = "USD per year",
           Description = " Total annual household income in urban area")
    
    #Average annual household income in urban area
    #---------------------------------
    UrbanAveHhIncome_Ma <- UrbanTotalHhIncome_Ma / UrbanHhNum_Ma 
    attributes(UrbanAveHhIncome_Ma) <- list(
      Units = "USD per year",
      Description = "Average annual household income in the urban area"
    )
    
    #Total annual low household income in urban area
    #------------------
    UrbanTotalHhIncomeLowInc_Ma <- summarizeDatasets(
      Expr = "sum(Income)",
      Units_ = c(
        Income = "USD",
        LocType = "",
        Marea = ""
      ),
      By_ = c(
         "Income",
         "Marea"
         ),
      Breaks_ls = list(
         Income = c(20000,40000,60000,80000,100000)
       ),   
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[,Ma][1] 
    attributes(UrbanTotalHhIncomeLowInc_Ma) <- 
      list(Units = "USD per year",
           Description = " Total annual low household income (0to20K 2010$) in urban area")
           
    #Number of low income households in urban area
    #--------------------------------------
    UrbanHhNumLowInc_Ma <- summarizeDatasets(
      Expr = "count(HhSize)",
      Units_ = c(
        HhSize = "",
        LocType = "",
        Income = "USD",
        Marea = ""
      ),
      By_ = c(
          "Income",
          "Marea"),
      Breaks_ls = list(
          Income = c(20000, 40000, 60000, 80000, 100000)
      ),    
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[,Ma][1]   
    attributes(UrbanHhNumLowInc_Ma) <- 
      list(Units = "Households",
           Description = "Number of low income (0to20K 2010$) households residing in urban area")
    
    #Average annual low household income in urban area
    #---------------------------------
    UrbanAveHhIncomeLowInc_Ma <- UrbanTotalHhIncomeLowInc_Ma / UrbanHhNumLowInc_Ma 
    attributes(UrbanAveHhIncomeLowInc_Ma) <- list(
      Units = "USD per year",
      Description = "Average annual low household income (0to20K 2010$) in the urban area"
    )
           
    #Average annual household DVMT in urban area
    #---------------------------------
    UrbanAveHhDVMT_Ma <- UrbanHhDvmt_Ma / UrbanHhNum_Ma 
    attributes(UrbanAveHhDVMT_Ma) <- list(
      Units = "Vehicle Mile Travel",
      Description = "Average household DVMT in urban area"
    )
    
    # Average Household operating cost for low income - Inc0to20K
    UrbanVehOperatingCostLowInc_Ma <- summarizeDatasets(
    Expr = "mean(AveVehCostPM)* mean(Dvmt)*365",
     Units_ = c(
       AveVehCostPM = "USD",
       LocType = "",
       Income = "USD",
       Dvmt = "MI/DAY",
       Marea = ""
     ),
     By_ = c(
       "Income",
       "Marea"
       ),
     Breaks_ls = list(
       Income = c(20000,40000,60000,80000,100000)
     ),
     Table = "Household",
     Group = Year,
     QueryPrep_ls = QPrep_ls)[,Ma][1]  
     attributes(UrbanVehOperatingCostLowInc_Ma) <- list(
      Units = "USD per year",
      Description = "Average annual household vehicle operating cost for low income (0to20K 2010$) in urban area"
    )
    
      
      # Average Household vehicle ownership cost for low income - Inc0to20K
        UrbanVehOwnershipCostLowInc_Ma <- summarizeDatasets(
       Expr = "mean(OwnCost)",
       Units_ = c(
         OwnCost = "USD",
         LocType = "",
         Income = "USD",
         Marea = ""
       ),
       By_ = c(
         "Income",
         "Marea"
         ),
       Breaks_ls = list(
         Income = c(20000,40000,60000,80000,100000)
       ),
       Table = "Household",
       Group = Year,
       QueryPrep_ls = QPrep_ls)[,Ma][1]
       attributes(UrbanVehOwnershipCostLowInc_Ma) <- list(
        Units = "USD per year",
        Description = "Average annual household vehicle ownership cost for low income(0to20K 2010$) in urban area"
        )
     
     #low income Hh Dvmt in urban area
     UrbanHhDvmtLowInc_Ma <- summarizeDatasets(
      Expr = "sum(Dvmt)",
      Units_ = c(
        Dvmt = "MI/DAY",
        LocType = "",
        Income = "USD",
        Marea = ""
      ),
      By_ = c(
         "Income",
         "Marea"
         ),
      Breaks_ls = list(
         Income = c(20000,40000,60000,80000,100000)
       ),   
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[,Ma][1]
     attributes(UrbanHhDvmtLowInc_Ma) <- list(
        Units = "Miles per day",
        Description = "Daily vehicle miles traveled by low income (0to20K 2010$) households residing in the urban area"
        )
     
     #Low income household vehicle Own & out-of-pocket costs share of HH low Income total (all low income HHs)
      HhVehTravCostShareLowInc_Ma <- (UrbanVehOperatingCostLowInc_Ma  + UrbanVehOwnershipCostLowInc_Ma* UrbanHhNumLowInc_Ma)/ UrbanTotalHhIncomeLowInc_Ma
      attributes(HhVehTravCostShareLowInc_Ma) <- list(
        Units = "Proportion",
        Description = "Low income (0to20K 2010$) household vehicle Own & out-of-pocket costs share of HH low income total (all low income HHs)in urban area"
        )
     
     #household vehicle Own & out-of-pocket costs share of HH income total (all HHs)
      HhVehTravCostShare_Ma<- ((UrbanVehOperatingCost_Ma + UrbanVehOwnershipCost_Ma)* UrbanHhNum_Ma) / UrbanTotalHhIncome_Ma  
      attributes(HhVehTravCostShare_Ma) <- list(
        Units = "Proportion",
        Description = "Household vehicle Own & out-of-pocket costs share of HH income total (all HHs) in urban area"
        ) 

    #urban DVMT per Capita in LowInc HHs
     UrbanLdvDmvtPerCapLowInc_Ma <- UrbanHhDvmtLowInc_Ma / UrbanHhPopLowInc_Ma     
     attributes(UrbanLdvDmvtPerCapLowInc_Ma) <- list(
      Units = "Dvmt per person",
      Description = "daily vehicle miles traveled per person in low income (0to20K 2010$) households residing in the urban area."
    )
          
     #Average car service light truck proportion of car service DVMT
    #--------------------------------------------------------------
    MareaCarSvcLtTrkDvmtProp_Ma <- summarizeDatasets(
      Expr = "sum(DvmtProp[VehicleAccess != 'Own' & Type == 'LtTrk']) / sum(DvmtProp[VehicleAccess != 'Own'])",
      Units_ = c(
        DvmtProp = "",
        VehicleAccess = "",
        Type = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Vehicle",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(MareaCarSvcLtTrkDvmtProp_Ma) <- 
      list(Units = "Proportion",
           Description = "Average proportion car service vehicle DVMT in light trucks used by households residing in the Marea")  
      
    #Average population density
    #--------------------------
    UrbanAvePopDen_Ma <- summarizeDatasets(
      Expr = "sum(UrbanPop) / sum(UrbanArea)",
      Units_ = c(
        UrbanArea = "ACRE",
        UrbanPop = "PRSN",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Bzone",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]	
    attributes(UrbanAvePopDen_Ma) <- list(
      Units = "Persons per acre",
      Description = "Average number of persons per acre in the urbanized area"
    )
    
    #Median Bzone population density
    #-------------------------------
    if (isDatasetPresent("LocType", "Bzone", Year, QPrep_ls)) {
      MedianBzonePopDen_Ma <- summarizeDatasets(
        Expr = "median(D1B)",
        Units_ = c(
          D1B = "PRSN/ACRE",
          LocType = "Category",
          Marea = ""
        ),
        By_ = "Marea",
        Table = "Bzone",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )[Ma]
    } else {
      MedianBzonePopDen_Ma <- summarizeDatasets(
        Expr = "median(UrbanPop / UrbanArea)",
        Units_ = c(
          UrbanPop = "PRSN",
          UrbanArea = "ACRE",
          Marea = ""
        ),
        By_ = "Marea",
        Table = "Bzone",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )[Ma]
    }
    attributes(MedianBzonePopDen_Ma) <- list(
      Units = "Persons per acre",
      Description = "Median Bzone population density in urbanized area"
    )
    
    #Average activity density
    #------------------------
    if (isDatasetPresent("LocType", "Bzone", Year, QPrep_ls)) {
      AveActivityDen_Ma <- summarizeDatasets(
        Expr = "sum(NumHh + TotEmp) / sum(UrbanArea)",
        Units_ = c(
          NumHh = "HH",
          TotEmp = "PRSN",
          UrbanArea = "ACRE",
          LocType = "category",
          Marea = ""
        ),
        By_ = "Marea",
        Table = "Bzone",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )[Ma]	
    } else {
      AveActivityDen_Ma <- summarizeDatasets(
        Expr = "sum(NumHh + TotEmp) / sum(UrbanArea)",
        Units_ = c(
          NumHh = "HH",
          TotEmp = "PRSN",
          UrbanArea = "ACRE",
          Marea = ""
        ),
        By_ = "Marea",
        Table = "Bzone",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )[Ma]
    }
    attributes(AveActivityDen_Ma) <- list(
      Units = "Households and jobs per acre",
      Description = "Average number of households and jobs per acre in the urbanized area"
    )
    
    #Proportion of households in urban-mixed neighborhoods
    #-----------------------------------------------------
    PropUrbanMixHh_Ma <- NumUrbanMixHh_Ma / UrbanHhNum_Ma
    attributes(PropUrbanMixHh_Ma) <- list(
      Units = "Proportion of Households",
      Description = "Proportion of urbanized area households that reside in urban-mixed neighborhoods"
    )
    
    #Total daily work parking cost
    #-----------------------------
    HhTotDailyWkrParkingCost_Ma <- summarizeDatasets(
      Expr = "sum(ParkingCost)",
      Units_ = c(
        ParkingCost = "",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = list(
        Worker = c("ParkingCost"),
        Household = c("Marea", "LocType")
      ),
      Key = "HhId",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(HhTotDailyWkrParkingCost_Ma) <-
      list(Units = "USD per day",
           Description = "Total daily work parking expenditures by households living in the urbanized portion of the Marea")
     
    #Total daily non-work parking cost
    #---------------------------------
    HhTotDailyOthParkingCost_Ma <- summarizeDatasets(
      Expr = "sum(OtherParkingCost)",
      Units = c(
        OtherParkingCost = "",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(HhTotDailyOthParkingCost_Ma) <-
      list(Units = "USD per day",
           Description = "Total daily non-work parking expenditures by households living in the urbanized portion of the Marea")
    
     #Proportion of single-family dwelling units
    #------------------------------------------
    if (isDatasetPresent("LocType", "Bzone", Year, QPrep_ls)) {
      PropSFDU_Ma <- summarizeDatasets(
        Expr = "sum(SFDU) / (sum(NumHh))",
        Units = c(
          SFDU = "DU",
          NumHh = "HH",
          LocType = "category",
          Marea = ""
        ),
        By_ = "Marea",
        Table = "Bzone",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )[Ma]
    } else {
      PropSFDU_Ma <- summarizeDatasets(
        Expr = "sum(SFDU) / (sum(NumHh))",
        Units = c(
          SFDU = "DU",
          NumHh = "HH",
          Marea = ""
        ),
        By_ = "Marea",
        Table = "Bzone",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )[Ma]
    }
    attributes(PropSFDU_Ma) <- list(
      Units = "Proportion of Households",
      Description = "Proportion of urbanized area households that reside in single-family dwellings"
    )
    
     #Vehicle trips in urban
    #---------------------------------
    UrbanVehicleTrips_Ma <- summarizeDatasets(
      Expr = "sum(VehicleTrips)",
      Units = c(
        VehicleTrips = "TRIP/DAY",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanVehicleTrips_Ma) <-
      list(Units = "Trips per day",
           Description = "Average number of vehicle trips per day by household members in urban")
    
    
    #Average Vehicle trip length in urban
    #---------------------------------
    UrbanVehTripLen_Ma <- summarizeDatasets(
      Expr = "sum(AveVehTripLen)",
      Units = c(
        AveVehTripLen = "MI",
        LocType = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(UrbanVehTripLen_Ma) <-
      list(Units = "Miles",
           Description = "Average household vehicle trip length in miles in urban")
     
        #Average car service auto proportion of car service DVMT
    #--------------------------------------------------------------
    MareaCarSvcAutoDvmtProp_Ma <- summarizeDatasets(
      Expr = " sum(DvmtProp[VehicleAccess != 'Own' & Type == 'Auto']) / sum(DvmtProp[VehicleAccess != 'Own'])",
      Units_ = c(
        DvmtProp = "",
        VehicleAccess = "",
        Type = "",
        Marea = ""
      ),
      By_ = "Marea",
      Table = "Vehicle",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Ma]
    attributes(MareaCarSvcAutoDvmtProp_Ma) <- 
      list(Units = "Proportion",
           Description = "Average proportion car service vehicle DVMT in autos used by households residing in the Marea")
     
     #House hold car service DVMT in Marea
     MareaHouseholdCarSvcDvmt_Ma <- summarizeDatasets(
        Expr = "sum(Dvmt[VehicleAccess != 'Own' ] * DvmtProp[VehicleAccess != 'Own' ])",
        Units = c(
          Dvmt = "MI/DAY",
          DvmtProp = "",
          VehicleAccess = "",
          Marea = ""
        ),
        By_ = "Marea",
        Table = list(
          Household = c("Dvmt", "Marea"),
          Vehicle = c("DvmtProp", "VehicleAccess")
        ),
        Key = "HhId",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )[Ma]
      attributes(MareaHouseholdCarSvcDvmt_Ma) <- list(
        Units = "miles per day",
        Description = "Total DVMT in car service vehicles of persons in households and non-institutional group quarters in Marea"
      )
      
       
#####################################################################################################################################################################################################################################################################################################################         
     ###put all the measures into dataframe for reporting
     CO2e_df <- makeMeasureDataFrame(
      DataNames_ = c(
        #DVMT Related
        "UrbanHhDvmt_Ma",
      #  "UrbanHhDvmt_MaAz",
        "UrbanHhDvmt_MaAzMx",
        "UrbanVanDvmt_Ma",
        "UrbanComSvcDvmt_Ma",
        "UrbanLdvDvmt_Ma",
        "UrbanHhPop_Ma",
       # "UrbanHhPop_MaAz",
        "UrbanHhPop_MaAzMx",
        "UrbanHhPopLowInc_Ma",
        "UrbanLdvDmvtPerCap_Ma",
        "UrbanLdvDmvtPerCap_MaAz",
        "UrbanLdvDmvtPerCap_MaAzMx",
        "UrbanLdvDmvtPerCapLowInc_Ma",
        "UrbanBusDvmt_Ma",
        "UrbanHvyTrkDvmt_Ma",
        "UrbanRailDvmt_Ma",
        #GGE Related
        "UrbanHhGGE_Ma",
        "UrbanComSvcGGE_Ma",
        "UrbanVanGGE_Ma",
        "UrbanLdvGGE_Ma",
        "UrbanBusGGE_Ma",
        "UrbanRailGGE_Ma",
        "UrbanHvyTrkGGE_Ma",
        #Hh related
        "UrbanHhNum_Ma",
        "UrbanHhVehicles_Ma",
        "UrbanHhAveVehPerHh_Ma",
        "UrbanHhWorkers_Ma",
        "UrbanHhDrivers_Ma",
        "NumUrbanMixHh_Ma",
        #CO2 Related
        "UrbanHhCO2e_Ma",
        "UrbanComSvcCO2e_Ma",
        "UrbanVanCO2e_Ma",
        "UrbanLdvCO2e_Ma",
        "UrbanBusCO2e_Ma",
        "UrbanRailCO2e_Ma",
        "UrbanBusCO2eRate_Ma",
        "UrbanHvyTrkCO2e_Ma",
        "UrbanHvyTrkAveCO2eRate_Ma",
        #Trips, Delay, Speed, & Mode Shift Related
        "UrbanWalkTrips_Ma",
        "UrbanBikeTrips_Ma",
        "UrbanTransitTrips_Ma",
        "UrbanModeShiftTrips_Ma",
        "UrbanLdv_TotalDelay_Ma",
        "UrbanHvyTrk_TotalDelay_Ma",
        "UrbanLdv_HvyTrk_TotalDelay_Ma",
        "UrbanLvdAveSp_Ma",
        "UrbanHvyTrkAveSp_Ma",
        "UrbanBusAveSp_Ma",        
        #Cost related
        "UrbanVehOwnershipCost_Ma",
        "UrbanAveVehCostPM_Ma",
        "UrbanVehOperatingCost_Ma",
        "UrbanVehOperatingCostLowInc_Ma",
        "UrbanVehOwnershipCostLowInc_Ma",
        #Income Related
        "UrbanTotalHhIncome_Ma",
        "UrbanAveHhIncome_Ma",
        "UrbanTotalHhIncomeLowInc_Ma",
        "UrbanHhNumLowInc_Ma",
        "UrbanAveHhIncomeLowInc_Ma",
        #Other
        "UrbanAveHhDVMT_Ma",
        "UrbanHhDvmtLowInc_Ma",
        "HhVehTravCostShareLowInc_Ma",
        "HhVehTravCostShare_Ma",
        "MareaCarSvcLtTrkDvmtProp_Ma",
        "UrbanAvePopDen_Ma",
#        "MedianBzonePopDen_Ma",
        "AveActivityDen_Ma",
        "PropUrbanMixHh_Ma",
        "HhTotDailyWkrParkingCost_Ma",
        "HhTotDailyOthParkingCost_Ma",
        "PropSFDU_Ma",
        "UrbanVehicleTrips_Ma",
        "UrbanVehTripLen_Ma",
        "MareaCarSvcAutoDvmtProp_Ma",
        "MareaHouseholdCarSvcDvmt_Ma"
        ),
      Ma = Ma
      )
      
   }

Metro_Measures_AllYrs<-NULL   
for(i in Year) {
      temp<-calcMetropolitanMeasures(i , Ma )
      Metro_Measures_AllYrs<-cbind(Metro_Measures_AllYrs,temp[,2])
          }
Metro_Measures_AllYrs<-as.data.frame(Metro_Measures_AllYrs)
colnames(Metro_Measures_AllYrs)<-Year
Metro_Measures_AllYrs$Measure<-temp$Measure 
Metro_Measures_AllYrs$Units<-temp$Units
Metro_Measures_AllYrs$Description<-temp$Description
Metro_Measures_AllYrs<-Metro_Measures_AllYrs[,c(ncol(Metro_Measures_AllYrs)-2,1:(ncol(Metro_Measures_AllYrs)-3),(ncol(Metro_Measures_AllYrs)-1):ncol(Metro_Measures_AllYrs))]  

write.csv(Metro_Measures_AllYrs, row.names = FALSE,
          file = "metro_measures_AllYears.csv")
          
          
          