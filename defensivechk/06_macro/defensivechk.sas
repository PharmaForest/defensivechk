/*** HELP START ***//*

@file defensivechk.sas

@brief Validates required macro parameters, dataset existence, and variable presence in a defensive programming approach.

@details 
This macro performs runtime validation of required macro parameters, checks for the existence of a specified dataset, and verifies whether essential variables are present in that dataset. If any required elements are missing, it logs descriptive error messages and forcefully aborts execution. This promotes robustness and avoids silent failures.

Syntax:
@code
%defensivechk(
    reqparmlst=ds invar outvar,
    reqvardsn=work.input_data,
    reqvarlst=USUBJID PARAMCD AVAL
);
@endcode

Usage:
@code
%let ds = work.adsl;
%let invar = TRT01P;
%let outvar = RESULT;

%defensivechk(
    reqparmlst=ds invar outvar,
    reqvardsn=&ds,
    reqvarlst=USUBJID &invar
);
@endcode

@param reqparmlst Space-separated list of macro parameter names to validate as non-empty (e.g., ds invar outvar).
@param reqvardsn Name of the input dataset to check for existence.
@param reqvarlst Space-separated list of variable names expected to exist in the dataset specified in `reqvardsn`.

@return Aborts macro execution if any required parameter, dataset, or variable is missing. Otherwise, the macro completes silently.

@version 1.0

@author Saikrishnareddy Yengannagari

*//*** HELP END ***/

%macro defensivechk(reqparmlst=, reqvardsn=, reqvarlst=);
	
	%local _err i param_name param_value variable_name;
	
/*--------------------------------------------------------------------------------------------------------------------------------------------------/     
	Flag for premature macro termination
/--------------------------------------------------------------------------------------------------------------------------------------------------*/ 

	%let _err = N;
	
/*--------------------------------------------------------------------------------------------------------------------------------------------------/     
 1.	Macro parameter checks
	Iterate through parameters
/--------------------------------------------------------------------------------------------------------------------------------------------------*/ 

	%do i = 1 %to %sysfunc(countw(&reqparmlst., %str( )));
	
/*--------------------------------------------------------------------------------------------------------------------------------------------------/     
		Sub-select macro name
/--------------------------------------------------------------------------------------------------------------------------------------------------*/ 

		%let param_name = %scan(&reqparmlst., &i., %str( ));
		
/*--------------------------------------------------------------------------------------------------------------------------------------------------/     
		Sub-select macro value
/--------------------------------------------------------------------------------------------------------------------------------------------------*/ 

		%let param_value = &%scan(&reqparmlst., &i., %str( )).;
		
/*--------------------------------------------------------------------------------------------------------------------------------------------------/     
		Check whether required parameters are empty
/--------------------------------------------------------------------------------------------------------------------------------------------------*/ 

		%if %length(&param_value.) = 0 %then %do;
			%put %str(ERR)%str(OR: &param_name. is a required parameter and should not be NULL);
			%let _err = Y;
		%end;
		
	%end;
	
/*--------------------------------------------------------------------------------------------------------------------------------------------------/     
	2. Check whether required dataset exist 
/--------------------------------------------------------------------------------------------------------------------------------------------------*/ 
	
    %if %length(&reqvardsn.) ne 0 %then %do;	
		%if (%sysfunc(exist(&reqvardsn.))) = 0 %then %do;
			%put %str(ERR)%str(OR: Dataset &reqvardsn. is required and should be present);
			%let _err = Y;
		%end;
	%end;
	
/*--------------------------------------------------------------------------------------------------------------------------------------------------/     
	3.	Check if variable exists
		Iterate through variables
/--------------------------------------------------------------------------------------------------------------------------------------------------*/ 

	%do i = 1 %to %sysfunc(countw(&reqvarlst., %str( )));
	
/*--------------------------------------------------------------------------------------------------------------------------------------------------/     
		Sub-select variable name
/--------------------------------------------------------------------------------------------------------------------------------------------------*/ 
	
		%let variable_name = %scan(&reqvarlst., &i., %str( ));
	
/*--------------------------------------------------------------------------------------------------------------------------------------------------/     
		Check whether required variables are exist in input dataset
/--------------------------------------------------------------------------------------------------------------------------------------------------*/ 
		
		%if %varexist(&reqvardsn,&variable_name) = 0 %then %do;
			%put %str(ERR)%str(OR: &variable_name. is a required variable and should be present in input dataset &reqvardsn.);
			%let _err = Y;
		%end;
		
	%end;
	
/*--------------------------------------------------------------------------------------------------------------------------------------------------/     
	Stop macro if one of the parameters/variables broke the requirements
/--------------------------------------------------------------------------------------------------------------------------------------------------*/ 

	%if "&_err." = "Y" %then %abort;

%mend defensivechk;
