% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - display
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: One-line text ouput
% ARGUMENTS: mbsSpectrum
% RETURNS: none
% MODIFICATIONS:
% ******************************************************************************
function display(sp)

disp(' ');
disp(sprintf('   class <mbsSpectrum> (version %s) %dx%d', sp.version, sp.pts,sp.numspec));
disp(' ');
