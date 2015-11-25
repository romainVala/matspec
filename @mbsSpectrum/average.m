% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - average
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Sums all the spectra together 
% ARGUMENTS: one mbsSpectrum
% RETURNS: The average of mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function sp = average(sp)

sp.fid = mean(sp.fid,2);
sp.numspec = 1;

sp = spec_fft(sp);
