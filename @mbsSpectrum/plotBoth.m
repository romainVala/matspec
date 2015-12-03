% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - plotBoth
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: A plotting tool, shows both spectra anf FID on same plot
% ARGUMENTS: mbsSpectrum
% RETURNS: none
% MODIFICATIONS:
% ****************************************************************************** 
function plotBoth(sp)

sp = average(sp);

plot(1:sp.pts,abs(sp.spec), 1:sp.pts, abs(sp.fid));
