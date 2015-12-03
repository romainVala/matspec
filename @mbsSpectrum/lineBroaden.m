% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - lineBroaden
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Multiplies the FID by an exponential.
% ARGUMENTS: mbsSpectrum, lb in Hz. lb = FWHM is 1/(pi*t2*) 
% RETURNS: mbsSpectrum, broadened
% MODIFICATIONS:
% ****************************************************************************** 
function sp = lineBroaden(sp,lb)

sp.fid = sp.fid .* ...
   (exp(-sp.time * lb * 2 * pi) * ones(1,sp.numspec));
sp = spec_fft(sp);










