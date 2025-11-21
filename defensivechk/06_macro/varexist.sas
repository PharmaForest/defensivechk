/*** HELP START ***//*

The defensivechk macro uses the varexist macro, which is sourced from the SAS Community. This macro checks whether a specified variable exists in a dataset, and it returns 1 if the variable exists, and 0 if it does not.

*//*** HELP END ***/

%macro varexist(ds, var);
    %local dsid rc ;
    /*----------------------------------------------------------------------
    Use SYSFUNC to execute OPEN, VARNUM, and CLOSE functions.
    -----------------------------------------------------------------------*/
    %let dsid = %sysfunc(open(&ds));

    %if (&dsid) %then %do;
        %if %sysfunc(varnum(&dsid,&var)) %then 1;
        %else 0 ;
        %let rc = %sysfunc(close(&dsid));
    %end;
    %else 0;

%mend varexist;
