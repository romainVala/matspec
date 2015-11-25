% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - calcAxes
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Recalculates domain information
%   Calculates the time and frequency axes.
% ARGUMENTS: mbsSpectrum 
% RETURNS: mbsSpectrum
% MODIFICATIONS:
% ******************************************************************************
function sp = calcAxes(sp)

% Requires at, pts, centerfreq, sfrq
deltaT = sp.at / (sp.pts-1);
swhz = 1/deltaT;
deltaomega = swhz/(sp.pts-1);

sp.freq = (swhz/2:-deltaomega:-swhz/2)';
sp.freq = sp.freq + sp.centerfreq * sp.sfrq;
sp.freq = sp.freq ./ sp.sfrq;
sp.time = (0:sp.at/(sp.pts-1):sp.at)';

