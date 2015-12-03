% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - getProcparVal
% AUTHOR: Originally JP Strupp, I think. Adapted by PJB
% CREATED: 8/7/2002
% DESCRIPTION: Extracts a procpar value from the procpar file.
% Get the values for parameter name in procpar file path
% Usage: vals = getPPV( ppName, ppPath )
% ARGUMENTS: parameter name, procpar full path
% RETURNS: values
% MODIFICATIONS:
% ****************************************************************************** 
function vals = getProcparVal( ppName, ppPath )

fp = fopen( ppPath, 'r');

vals = getProcparVal_Fileid(ppName, fp);

fclose( fp );
return;

