# England Recycling Waste Analysis (2023–2025) - Tableau Project

An interactive Tableau data story exploring England's local authority recycling data — what actually gets recycled, which trends are genuine versus seasonal, and how performance varies once population is accounted for.

## Overview

Local authorities across England report waste collection and processing data every quarter through WasteDataFlow. This project takes two years of that raw data (2023–2025, ~624,000 records across 321 authorities) and turns it into a guided data story, built to answer three questions a simple recycling-rate headline number can't:

What actually dominates recycling by volume, and how "clean" is that recycling once you look past the label?
Is a change in the data a real trend, or just the seasons turning?

How does recycling performance really compare between authorities, once you stop letting population size distort the picture?
Tech Stack

## Technology used for this project

- Draw.io : To create the Darabase Diagram.
- Github : Version Control used to upload all Scripts, Resources, Tableau project and Documentation.
- MySQL : Database used to import/export and transform data into csv file.
- LibreOffice : To view xls/csv files.
- Tableau : This is the main tool to create the sheets and Dashboard.

## Data Origin

- <a href="https://www.data.gov.uk/dataset/0e0c12d8-24f6-461f-b4bc-f6d6a5bf2de5/waste-data-flow" target="_blank">Waste Recycling Data</a>

- <a href="https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland%26lang%3Dde%26lang%3Dde" target="_blank">The UK Population Data</a>

- <a href="https://geoportal.statistics.gov.uk/datasets/ons::local-authority-districts-december-2025-boundaries-uk-bfc/about" target="_blank">Local Authority District</a>



## SQL Procedures to created Master Tables (inside Procedures folder)

- MainTableLocalAuthoritiesProcedure.sql - This procedure stores the UK authorities name, code and geolocation data
- MainTablePopulationProcedure.sql - This procedure stores the each authorities population data
- MainTableWasteCollectionProcedure.sql - This is the biggest and the most important data, it will store the waste collection data in England between 2023 and 2025

## Loading data Script (inside Scripts folder)

- CreateProjectSchema - It will run all the procedures, mentioned before, creating the tables and loading data to master tables

## Data Conversion Scripts (inside Scripts folder)

- WasterCollectionSummaryQueries.sql - This script contains the Data local authorities names conversion and clean up. This is important for a correct link with Authorities population data
- AuthotiryLocationMappingQueries.sql - This is the most important query as it populated the lookup table that works as a bridge between local authorities and ONS codes 
- DataAnalysisScripts.sql - This is a mix of different queries to check data content in different tables

## Data Export Scripts

- The scripts are contained in the Data conversion ones

## Tableau Data Source, Sheet, and Dashboard (inside Tableau folder)

- The Tableau project is stored inside Tableau folder

## The Datasets are not included in this repository as they were quite big files


