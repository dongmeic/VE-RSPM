# Explanations

This is to document the bugs in the modeling process for future Reference. The folders `files` and `logs` are for the files related to bugs or that document the bugs.

## Input file format

The input file 'marea_transit_ave_fuel_carbon_intensity' had a format issue that was fixed by using the example file format.

## High population density

Census tract 'Eug-41039003700' from 'bzone_dwelling_units.csv' exceeds the population density limit 100 persons per acre set in the model, which was reported as an error (it was a warning in VE 2.0). The error was fixed by decreasing the group quarter dwelling units from 1672 to 1600 in 2040, which is a rough estimation. The percentage of non-institutional population in this census tract is 100%.

## RStudio fatal error

When running scenarios by category, RStudio experienced a fatal error multiple times. The reasons are not exactly clear. It could be the measure of 198 GB storage required for the results are not met in the current machine, or due to an outdated 'rlang' package. The running was not continued because the option to select certain scenarios is not available and there is not enough storage for the 6400 scenarios!

## Different length of vectors in an equation

When calculating daily vehicle miles traveled in the VETravelPerformance module, an error as below occurred in the staged model.

`Error in names(HhUrbanRoadDvmt_Ma) <- Ma :
  'names' attribute [1] must be the same length as the vector [0]`
