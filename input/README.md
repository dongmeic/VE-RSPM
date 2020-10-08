# Explanations

Adjustments on some input files are made to run through the model.

## Recalculate carbon intensity

The utility shapefile is provided by ODOT and the green house emissiions data is provided by Ellen. 

The pop-weighting is calculated by the percentages of areas for each of untility names (EWEB, Springfield Utility Board, Emerald PUD, Lane Elec) in each of the three cities (Eugene, Springfield, and Coburg). This step is processed using both ArcMap and R to compare the results. 

The carbon intensity is calculated using the approach explained in *VE_State_InputsTo_MPO_20200518.pdf* and using the script *carbon_intensity.R*.

## Debug population density

The population density by BZone is warned too high in some tracts. To examine the input values, several steps are followed. The BZone boundary is *\\clsrv111\transpor\Trans Projects\Model Development\UrbanSim_LandUse\Inputs\VisionEval\CLTracts_GsBoundary.shp*, a copy of which is saved in *OneDrive - lanecouncilofgovernments\data\Boundaries*.

### Recalcuate unprotected area
The unbuildable proportion data is from *\\clsrv111\transpor\Trans Projects\Model Development\UrbanSim_LandUse\Working2020-2045\DataPrep\Parcels\parcels.shp*, a copy of which is saved in *OneDrive - lanecouncilofgovernments\data\parcels*. The unprotected area is calculated as '(100 - Proportion)/100 * ShapeArea' in parcels and summarized by bzone using the [Summary Within](https://pro.arcgis.com/en/pro-app/tool-reference/analysis/summarize-within.htm) function in ArcGIS Pro. The calcuated data is organized in the new input CSV file using the script *population_density.R*. 
