# Description 

This repository includes code to generate AIS inferred dive events and figures in the manuscript Morse *et al.* (in prep): "Preferential selection of marine protected areas by the recreational scuba diving industry"  

# Overview

This ReadMe contains the following information (click to jump directly to a section):  

 - [Repository Structure](#repository-structure): brief overview of repository structure  
 - [Instructions](#instructions): important information on how to use the repository   
 - [Repository Details](#repository-details): full list of all scripts in the repository with brief descriptions of their objectives 
 - [Software](#software): details on software and versions used to run analysis 
 
# Repository Structure

The repository uses the following basic structure: 

```
boi-dive-analysis
  |__ src
    |__ data-prep 
    |__ exploratory-reports
    |__ figures
```

The `src` folder includes all the relevant code. The `data-prep` folder contains all the code to process the raw input data and creates the final files that are required to run the analysis. The `exploratory-reports` folder contains html and PDF version of exploratory data analysis on dive events. The `src/figures` folder contains all the code to generate manuscript figures. 

A detailed accounting of all scripts in the repository with a brief description of their objectives is described below in `Repository Details`.  

[Back to Top](#description)

# Instructions

All of the relevant code is contained in the `src` folder. The order of running scripts should be as follows: 

  - The scripts required to process and prepare all data used in the analysis can be found in the `src/data-prep` folder. Each stage of data processing is contained in a folder and should be in run in numeric order from `00_spatial` to `04_dive_events`. 
  - Scripts used to generate html and pdf reports are in `src/exploratory-reports` and should be run after the data prep. Scripts can be run in any order.      
  - Additional scripts to create paper figures are in `src/figures`, and should be run after the data prep. Figure scripts can be run in any order and are labeled according to their order in the manuscript.    

[Back to Top](#description)

# Repository Details

All of the code is contained in the `src` folder. A list of all scripts included in this repository and their objectives are described below: 

```
src
  |__ data-prep: cleans and processes data   
    |__ 00_spatial.Rmd: sets up the spatial files used throughout the analysis, including Channel Island boundaries, MPA boundaries, MPA buffers, and harbors   
    |__ 01_vessel_list.Rmd*: matches dive vessels by name to AIS vessels in the Global Fishing Watch vessel database  
    |__ 02_ais_data.Rmd*: pulls AIS vessel tracks for dive vessels from 2015-2022   
    |__ 03a_dive_sites.Rmd*: identifies possible dive sites from the AIS data   
    |__ 03b_mpa_dive_site_overlap.Rmd: assigns possible dive sites to MPA categories (outside, in buffer, in MPA) for different buffer distances and MPA definitions   
    |__ 04_dive_events.Rmd: identifies dive events from the AIS data, creates final subsets of dives used in resource selection model   
  |__ exploratory-reports: exploratory data analysis reports generated for collaborators
    |__ ecotourism_<x>.Rmd: code to generate a report visualizing the ecotourism dive scenarios where <x> refers to the output form, either pdf or html  
    |__ lobster_<x>.Rmd: code to generate a report visualizing the lobster dive scenarios where <x> refers to the output form, either pdf or html   
  |__ figures: scripts used to generate figures
    |__ figure_<x>.R: code to generate paper figure <x>; where x represents the manuscript figure number  
    |__ figure_s<x>.R: code to generate supplemental figure <x>; where x represents the manuscript figure number  
  |__ common.R: file paths and plot themes used in the analysis 

* Uses data that requires authorization     
```

# Software 

All code was run using RStudio: 2023.03.01+446 for MacOS and R version 4.1.0   

[Back to Top](#description)
