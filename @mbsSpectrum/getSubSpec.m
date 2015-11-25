% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - getSubSpec
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: 
%   Returns a portion of the spectrum specified by [limleft, limright] (ppm)
% ARGUMENTS: mbsSpectrum, limits
% RETURNS: not the spectrum - returns the spectral data and the freq axis
% MODIFICATIONS:
% ****************************************************************************** 
function [spec, freq] = getSubSpec(sp, limleft, limright)

jdxleft = interp1(sp.freq,1:sp.pts,limleft,'nearest');
jdxright = interp1(sp.freq,1:sp.pts,limright,'nearest');

spec = sp.spec(jdxleft:jdxright,:);
freq = sp.freq(jdxleft:jdxright);