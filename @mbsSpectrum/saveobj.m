% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - saveobj
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Clears out temp data prior to serializing
% ARGUMENTS: mbsSpectrum
% RETURNS: mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function sp = saveobj(sp)

% Clear out stuff that you don't really need to save. 
% They can be recalculated later
clear sp.spec;
clear sp.time;
clear sp.freq;