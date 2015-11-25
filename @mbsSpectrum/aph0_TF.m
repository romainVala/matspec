% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - aph0_TF
% AUTHOR: pjb
% CREATED: 7/5/2003
% DESCRIPTION: 
% Finds the zeroth order phase of the spectrum, and returns 
%   the phased fid, and the angle in radians.
% Works only on a single fid at a time. 
% This attempts to be a robust method, by calculating the phase using the
% dumb TD method AND the FDmaxmin method and taking the mean value.
% ARGUMENTS: one mbsSpectrum
% RETURNS: the phased mbsSpectrum, and the array of phases (rad) corrected
% MODIFICATIONS:
% ****************************************************************************** 
function [sp, rp] = aph0_TF(sp)

% Algorithm:
% This is an improvement on using the first FID point.
% Take the first N points, do a linear fit, and then use the predicted
%   value of the phase of the first FID point.

% My original idea was to use 4 points, but I switched to 10 because
%   it seemed so small. However, for low snr, its very reasonable.
% In the future, change this to 4. But for consistency, I need to keep it at 10
%N=8;
if nargin < 2
    N=4;
end

for idx = 1:sp.numspec
    
    % One of the keys is to pass the TD phase into the FD algorithm,
    % becuase otherwise it might find a phase 2Pi off, and the mean will be
    % -pi!
    spSingle = extractSpec(sp,idx);
    [spTD, rpTD] = aph0_TD(spSingle);
    [spFD, rpFD] = aph0_FDmaxmin(spSingle,rpTD);
    
    rp(idx) = mean([rpTD rpFD]);
    
end

% Apply the phase shifts.
sp = phaseSpec(sp, rp*180/pi);

