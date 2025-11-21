# defensivechk
This repository contains a SAS macro designed to perform defensive checks on macro parameters, datasets, and variables. It ensures that the necessary items are defined before further data processing, and if any required items are missing or incorrect, it will provide error messages and can abort execution.
### This repository is an adapted version of Saikrishnareddy Yengannagari’s original package ([https://github.com/kusy2009/defensivechk](https://github.com/kusy2009/sas-defensive-check-macro)) tailored for the SAS Package Framework, and the original license remains the property of Saikrishnareddy Yengannagari.　　


<img width="180" height="180" alt="defensivechk_small" src="https://github.com/user-attachments/assets/4b9c7271-dbf1-46dc-a9e5-c4ed0740065d" />


## Overview
The defensivechk macro performs the following checks:  

### Macro Parameter Checks: Ensures required parameters are passed and not null.
### Dataset Existence Check: Verifies if the specified dataset exists.
### Variable Existence Check: Checks if the specified variables exist within the dataset.
If any check fails, the macro will abort further execution and display an error message.

Dependency
The defensivechk macro uses the varexist macro, which is sourced from the SAS Community. This macro checks whether a specified variable exists in a dataset, and it returns 1 if the variable exists, and 0 if it does not.

Installation
Clone the Repository
Start by cloning this repository to your local machine:

git clone https://github.com/kusy2009/sas-defensive-check-macro.git

Place SAS Macros in Your Working Directory
After cloning, ensure that the following files are in your SAS working directory, or reference them in your SAS program:

defensivechk.sas: The main macro for performing defensive checks.
varexist.sas: The dependency macro from SAS Community (checks variable existence).
Usage
The defensivechk macro checks if required parameters are defined, if the specified dataset exists, and if the specified variables exist within the dataset. The syntax is as follows:

%defensivechk(reqparmlst=, reqvardsn=, reqvarlst=);

Parameters:
reqparmlst: A space-separated list of required macro parameters that must be defined.
reqvardsn: The name of the required dataset.
reqvarlst: A space-separated list of required variables that must exist in the dataset.
Example Usage:
%defensivechk(reqparmlst=param1 param2, reqvardsn=dataset_name, reqvarlst=var1 var2); This example checks if param1 and param2 are passed into the macro, if the dataset dataset_name exists, and if the variables var1 and var2 are present in the dataset.
