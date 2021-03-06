# Quench Power BI Reporting :tada:

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Overview](#overview)
  - [Goals of this repository](#goals-of-this-repository)
  - [Datasets and Query Details](#datasets-and-query-details)
  - [Golden Dataset Methodology](#golden-dataset-methodology)
    - [Golden Dataset Diagram](#golden-dataset-diagram)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Overview

### Goals of this repository

* Documentation
* Scalability
* Cross department communication

### Datasets and Query Details
* Service_Data
  * For service related reporting, feeds bulk of the reports in the Service Analytics app
* Bevi_data
  * Cleans and processes BEVI work orders, primarily for determining and forecasting truck rolls
* Labor_Compliance
  * Estimates hours worked per day based on gps trip data
* Fleet Data
  * efleet data
  * telogis (gps telematics data)
* zuora_data
  * Dataset for collections reporting
* [Query Details](https://github.com/jfallt/PBI-Github/blob/master/Query_Documentation.md)

### Data Dictionaries
* Created using [tabular editor](https://github.com/otykier/TabularEditor)
* All tables, columns, and measures are given descriptors
    * These descriptors populate the data dictionary
* This is incredibly important for others to understand the processes and for them to have a reference when they have questions
* Each PowerBI dataset will have one

### Golden Dataset Methodology

* The Service Analytics PBI environment uses a modified version of the [golden dataset](https://exceleratorbi.com.au/new-power-bi-reports-golden-dataset/)
* Version history, commentary, and documentation for queires are captured in this github repository
* Additions, updates (optimizations etc.), and changes require a new branch and approval

#### Golden Dataset Diagram
<details>
  <summary> Golden Dataset Diagram  </summary>

![](https://github.com/jfallt/PBI-Github/blob/master/Golden_Dataset_Git_Workflow.png)

</details>
