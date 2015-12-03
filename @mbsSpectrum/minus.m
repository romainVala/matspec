% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - minus
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Subtracts two spectra together, in complex form
% ARGUMENTS: two mbsSpectrum objects
% RETURNS: the resultant mbsSpectrum object
% MODIFICATIONS:
% ****************************************************************************** 
function sp = minus(sp1, sp2)

sp = sp1 + sp2.*-1;
