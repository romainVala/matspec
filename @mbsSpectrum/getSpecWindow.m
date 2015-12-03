% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - getSpecWindow
% AUTHOR: pjb
% CREATED: 1/30/2003
% DESCRIPTION: 
%   Returns a the full spectrum, set to zero outside the window from 
%       [limleft, limright] (ppm)
% ARGUMENTS: mbsSpectrum, limits
% RETURNS: not the spectrum - returns the spectral data and the freq axis
% MODIFICATIONS:
% ****************************************************************************** 
function spec = getSpecWindow(sp, limleft, limright)

jdxleft = interp1(sp.freq,1:sp.pts,limleft,'nearest');
jdxright = interp1(sp.freq,1:sp.pts,limright,'nearest');


spec = sp.spec;
spec(1:jdxleft,:) = 0;
spec(jdxright:sp.pts,:) = 0;
