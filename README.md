# Datamastery: Cooling Effect on the University of Twente Campus

## Introduction

This repository replicates and adapts the methodologies of the research paper [“Urban green spaces and variation in cooling in the humid tropics: The case of Paramaribo.”](https://doi.org/10.1016/j.ufug.2023.128111). The goal is to analyze the cooling effects of urban green spaces in the moderate maritime climate of the University of Twente campus, using adapted datasets and translated Python scripts.

---

## Objectives

### Original Objectives:
- Explore the effects of urban green spaces on diurnal and seasonal micro-climate cooling in Paramaribo's tropical climate.

### Adapted Objectives:
- Study the cooling effects of green spaces in the moderate maritime climate of Enschede, Netherlands.
- Validate hypotheses regarding temperature variations across urban green and non-green areas.

#### Hypotheses:
- **Summer Hypothesis:** Areas with greenery exhibit lower mean temperatures.
- **Winter Hypothesis:** Areas with greenery exhibit cooler mean temperatures compared to non-green areas.

---

## Workflow

### 1. Research Paper Analysis
- Reviewed the Paramaribo study and its methodologies.
- Discussed design plans, variables, and challenges with project stakeholders.

### 2. Testing Original Data and Code
- Verified functionality of R scripts and datasets from the original study.
- Analyzed outputs using the original sensor and satellite data.

### 3. Data Preprocessing
- Cleaned University of Twente sensor data.
- Mapped campus land cover using QGIS, Google Earth, and in-situ observations.
- Below is a more in-depth description of all the tools used in this analysis and their respective versions:

1. **Google**  
   - **Tool**: Google Earth Engine  
   - **Version**: 2023  
   - **Description**: A powerful platform for geospatial analysis.  
   - **Developer**: Google LLC  
   - **Link**: [https://earthengine.google.com/](https://earthengine.google.com/)  

2. **Microsoft Corporation**  
   - **Tool**: Microsoft Excel for Microsoft 365  
   - **Version**: Version 2412 Build 16.0.18324.20092 (2023)  
   - **Description**: Spreadsheet software used for data management and analysis.  
   - **Developer**: Microsoft  
   - **Link**: [https://www.microsoft.com](https://www.microsoft.com)  

3. **OpenAI**  
   - **Tool**: ChatGPT  
   - **Version**: Version 4.0 (2024)  
   - **Description**: A large language model for generating text-based responses and analysis.  
   - **Developer**: OpenAI  
   - **Link**: [https://chat.openai.com](https://chat.openai.com)  

4. **QGIS Development Team**  
   - **Tool**: QGIS Geographic Information System  
   - **Version**: Version 3.40.3 ("Bratislava") (2023)  
   - **Description**: Open-source GIS software for spatial data analysis and visualization.  
   - **Developer**: Open Source Geospatial Foundation Project  
   - **Link**: [https://qgis.org](https://qgis.org)  



### 4. Adaptation and Replication
- Translated and adapted R code into Python.
- Adjusted analysis for Dutch seasonal and daily temperature variations.

### 5. Results and Visualization
- Calculated **Delta T** (temperature deviations from seasonal averages).
- Created comparative graphs and heatmaps.

---

## Results Overview

### Key Findings:
1. **Seasonal Rankings**:
   - **Summer:** Residential grass areas were coolest; parking lots were warmer.
   - **Winter:** Parking lots were warmest; forested areas were coolest.

2. **Delta T Analysis**:
   - Delta T (temperature difference): Sensor data revealed measurable cooling effects based on proximity to greenery.

---

## Visualizations

Generated visualizations include:
- Seasonal temperature differences.
- Land Surface Temperature (LST) analyses.
- Effects of land cover categories on temperature variations.

See the `graphs/` folder for all plots.

---


---

## Methodology Adjustments

### Seasonal Reclassification:
Adapted the seasonal data to reflect Dutch climate classifications:
- **Winter:** December–February
- **Spring:** March–May
- **Summer:** June–August
- **Fall:** September–November

### Daily Timeframe Adjustments:
Adjusted time periods to reflect Dutch sunrise and sunset:
- **Summer:** Day: 6:00 AM – Night: 10:00 PM
- **Winter:** Day: 8:00 AM – Night: 5:00 PM

### Satellite Data Selection:
- Used **Sentinel-3** data instead of Landsat due to heavy cloud cover in winter months.
- Acknowledged lower resolution in thermal accuracy compared to Landsat.

---

## Limitations

1. Limited dataset with only four sensor points.
2. Challenges with cloud coverage impacting satellite image quality.
3. Sentinel-3’s lower thermal resolution affected fine-detail analysis.

---


## If you want to use any code or data from this repository, you can clone it and run the following command:
git clone https://github.com/JoanWaithira/DataMastery.git