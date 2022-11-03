# VE-RSPM

The repo includes scripts for edits in the input, model running, and output. The `input` folder include scripts to create or edit input files. The `output` folder contains scripts to reorganize and/or visualize output data. The `run` folder covers scripts for model running. Each of these three folders includes a folder `firstrun` that includes scripts for the initial efforts to explore VE-RSPM (Version 1.0 and 2.0, installers 2019-09-18 and 2020-09-18) for CLMPO in 2020, and a folder `nextgen` that includes scripts for the exploration on the Version 3.0 VisionEval "Next Generation" framework (installer 2022-05-27). The folders `debugging` and `package` are set up for scripts related to debugging and package issues. This notes document was started from the exploration of version 3.0.

# How to start

The most recent version of VisionEval can be downloaded [here](https://visioneval.org/category/download.html). Install the required R version for the specific VE version before launching `VisionEval.Rproj` in the installer's folder to install VisionEval. The "[Getting Started](https://visioneval.org/docs/getting-started.html#getting-started)" is where to start on the set up and model running.

## VE 3.0 R4.1.3_2022-05-27

The walkthrough steps provide guidance to use the functions for model installation and running, input setting, and output queries and visualization. Key changes on this version are explained [here](https://github.com/VisionEval/VisionEval-Dev/releases/tag/beta-release-0.9).The advantage of VE 3.0 includes setting the number of processors.

### Run CLMPO base model
In 2020, ODOT requested to run three different models, 'reference (Ref)', 'target rule (TR)' and 'statewide transportation strategy recommended (STSRec)'. Reference model is the base model, which was run successfully in VE 3.0.

### Run CLMPO scenarios

Scenario running is the primary task in CLMPO. The practice of running CLMPO scenarios in the first versions is to create folders with modified input files to run each scenario (it took up 78.1 GB in an external drive for 1297 scenarios including the reference model!) for staged models. In this version, the configuration and model running is set up in a *scenarios-cat* model, however, the setup doesn't include an option to select scenarios for running, while the total number of scenarios is added up to 6400 that caused a fatal error and would have taken up 198 GB. Similarly, the *scenarios-ms* set-up is limited to scenarios that don't involve different changes in the same input file (i.e., only unique input files are included in the same folder). Instead, selected (or grouped) scenarios can also be run in the staged model option. The user guide on [developing scenarios](https://visioneval.org/docs/developing-scenarios.html) explains the details of grouping scenarios.

The staged model for CLMPO scenarios was not run through due to an error on the calculation of households' urban DVMT in the region (i.e., CLMPO marea).  
