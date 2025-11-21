# defensivechk
This repository contains a SAS macro designed to perform defensive checks on macro parameters, datasets, and variables. It ensures that the necessary items are defined before further data processing, and if any required items are missing or incorrect, it will provide error messages and can abort execution.
### This repository is an adapted version of Saikrishnareddy Yengannagari’s original package ([https://github.com/kusy2009/defensivechk](https://github.com/kusy2009/sas-defensive-check-macro)) tailored for the SAS Package Framework, and the original license remains the property of Saikrishnareddy Yengannagari.　　


<img width="180" height="180" alt="defensivechk_small" src="https://github.com/user-attachments/assets/4b9c7271-dbf1-46dc-a9e5-c4ed0740065d" />


## Overview
The defensivechk macro performs the following checks:  

### [1] Macro Parameter Checks: Ensures required parameters are passed and not null.
### [2] Dataset Existence Check: Verifies if the specified dataset exists.
### [3] Variable Existence Check: Checks if the specified variables exist within the dataset.
### If any check fails, the macro will abort further execution and display an error message.

## Dependency
The defensivechk macro uses the varexist macro, which is sourced from the SAS Community (https://communities.sas.com/t5/SAS-Programming/Macro-Varexist/td-p/753701).   
This macro checks whether a specified variable exists in a dataset, and it returns 1 if the variable exists, and 0 if it does not.

## Usage
The defensivechk macro checks if required parameters are defined, if the specified dataset exists, and if the specified variables exist within the dataset. The syntax is as follows:  
~~~sas
%defensivechk(reqparmlst=, reqvardsn=, reqvarlst=);
~~~

## Parameters:  
~~~text
reqparmlst: A space-separated list of required macro parameters that must be defined.
reqvardsn: The name of the required dataset.
reqvarlst: A space-separated list of required variables that must exist in the dataset.
~~~

## Example Usage:
~~~sas
/*----------------------------------------------------------
  0. Create test datasets
     - ADSL-like dataset
     - A dataset missing TRT01P for negative test
----------------------------------------------------------*/
data work.adsl;
    length USUBJID $10 TRT01P $8 AVAL 8;
    do i = 1 to 5;
        USUBJID = cats('SUBJ', put(i, z2.));
        TRT01P  = ifc(mod(i,2)=1, 'A', 'B');
        AVAL    = i * 10;
        output;
    end;
    drop i;
run;

/* Dataset missing TRT01P for validation failure testing */
data work.adsl_ntrt;
    set work.adsl;
    drop TRT01P;
run;
~~~

### Pattern 1: All required conditions satisfied (Positive case)
~~~sas
/*----------------------------------------------------------
  Pattern 1: All required conditions satisfied (Positive case)
----------------------------------------------------------*/
%macro demo_ok;
    %local ds invar outstat;

    %let ds      = work.adsl;
    %let invar   = AVAL;
    %let outstat = work.summary_ok;

    %put NOTE: *** Pattern 1: All checks pass successfully ***;

    /* Run defensive checks */
    %defensivechk(
        reqparmlst = ds invar outstat,
        reqvardsn  = &ds,
        reqvarlst  = USUBJID TRT01P &invar
    );

    /* Main processing executed only if checks pass */
    proc means data=&ds noprint;
        class TRT01P;
        var &invar;
        output out=&outstat mean=mean_aval;
    run;

%mend demo_ok;

/* Execute Pattern 1 */
%demo_ok;
~~~
<img width="610" height="106" alt="image" src="https://github.com/user-attachments/assets/d8cf7ba6-c3a2-45f6-ba9e-b728c5db101d" /> 

### Pattern 2: Required macro parameter missing (INVAR not set)
~~~sas
/*----------------------------------------------------------
  Pattern 2: Required macro parameter missing (INVAR not set)
----------------------------------------------------------*/
%macro demo_missing_param;
    %local ds invar outstat;

    %let ds      = work.adsl;
    /* %let invar = AVAL;   <-- left intentionally blank to trigger validation failure */
    %let outstat = work.summary_ng_param;

    %put NOTE: *** Pattern 2: Missing required macro parameter (INVAR) ***;

    /* This will trigger an error inside defensivechk due to missing INVAR */
    %defensivechk(
        reqparmlst = ds invar outstat,
        reqvardsn  = &ds,
        reqvarlst  = USUBJID &invar   /* &invar is empty → intentionally failing */
    );

    /* This block will NOT be executed because %abort stops execution */
    proc means data=&ds noprint;
        class TRT01P;
        var &invar;
        output out=&outstat mean=mean_aval;
    run;

%mend demo_missing_param;

/* Running this macro will abort the job due to failure */
%demo_missing_param;
~~~
<img width="704" height="192" alt="image" src="https://github.com/user-attachments/assets/e765f9b1-e3b7-4c93-b50c-6deaa3076edc" />

### Pattern 3: Dataset exists but required variable missing
~~~sas
/*----------------------------------------------------------
  Pattern 3: Dataset exists but required variable missing
----------------------------------------------------------*/
%macro demo_missing_var;
    %local ds invar outstat;

    %let ds      = work.adsl_ntrt;   /* Dataset missing TRT01P */
    %let invar   = AVAL;
    %let outstat = work.summary_ng_var;

    %put NOTE: *** Pattern 3: Required variable TRT01P is missing in dataset ***;

    /* This will trigger an error for missing TRT01P */
    %defensivechk(
        reqparmlst = ds invar outstat,
        reqvardsn  = &ds,
        reqvarlst  = USUBJID TRT01P &invar
    );

    /* This block will NOT be executed because %abort stops processing */
    proc means data=&ds noprint;
        class TRT01P;
        var &invar;
        output out=&outstat mean=mean_aval;
    run;

%mend demo_missing_var;

/* Running this macro will abort the job due to missing variable */
%demo_missing_var;
~~~
<img width="1006" height="148" alt="image" src="https://github.com/user-attachments/assets/876bf994-7c03-41a8-b3bf-cc58376da699" />

### Pattern 4: Dataset does NOT exist
~~~sas
/*----------------------------------------------------------
  Pattern 4: Dataset does NOT exist
----------------------------------------------------------*/
%macro demo_missing_dataset;
    %local ds invar outstat;

    /* Assign a non-existing dataset name */
    %let ds      = work.not_exist;
    %let invar   = AVAL;
    %let outstat = work.summary_ng_ds;

    %put NOTE: *** Pattern 4: Required dataset does NOT exist ***;

    /* This check will fail because work.not_exist does not exist */
    %defensivechk(
        reqparmlst = ds invar outstat,
        reqvardsn  = &ds,
        reqvarlst  = USUBJID TRT01P &invar
    );

    /* This block will NOT be executed because %abort stops processing */
    proc means data=&ds noprint;
        class TRT01P;
        var &invar;
        output out=&outstat mean=mean_aval;
    run;

%mend demo_missing_dataset;

/* Running this macro will abort the job because the dataset does not exist */
%demo_missing_dataset;
~~~

## version history
1.0.0(21Nov2025): Initial version

## What is SAS Packages?

The package is built on top of **SAS Packages Framework(SPF)** developed by Bartosz Jablonski.

For more information about the framework, see [SAS Packages Framework](https://github.com/yabwon/SAS_PACKAGES).

You can also find more SAS Packages (SASPacs) in the [SAS Packages Archive(SASPAC)](https://github.com/SASPAC).

## How to use SAS Packages? (quick start)

### 1. Set-up SAS Packages Framework

First, create a directory for your packages and assign a `packages` fileref to it.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "\path\to\your\packages";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Secondly, enable the SAS Packages Framework.
(If you don't have SAS Packages Framework installed, follow the instruction in 
[SPF documentation](https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation) 
to install SAS Packages Framework.)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%include packages(SPFinit.sas)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### 2. Install SAS package

Install SAS package you want to use with the SPF's `%installPackage()` macro.

- For packages located in **SAS Packages Archive(SASPAC)** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located in **PharmaForest** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, mirror=PharmaForest)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located at some network location run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, sourcePath=https://some/internet/location/for/packages)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  (e.g. `%installPackage(ABC, sourcePath=https://github.com/SomeRepo/ABC/raw/main/)`)


### 3. Load SAS package

Load SAS package you want to use with the SPF's `%loadPackage()` macro.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%loadPackage(packageName)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Enjoy!
  
