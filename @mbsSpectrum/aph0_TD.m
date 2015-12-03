% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - aph0_TD
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: 
% Finds the zeroth order phase of the spectrum, and returns 
%   the phased fid, and the angle in radians.
% Works only on a single fid at a time. Polyfit isn't vectorized.
% This is a dumb version which uses a fixed number of points to calculate
% the linear fit. 
% ARGUMENTS: one mbsSpectrum
% RETURNS: the phased mbsSpectrum, and the array of phases (rad) corrected
% MODIFICATIONS:
% ****************************************************************************** 
function [sp, rp] = aph0_TD(sp, N)

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
    
    phs = unwrap(angle(sp.fid(1:N,idx)));
    p = polyfit(1:N, phs',1);
    
    % Now y=mx+b, x=1. This projects to first FID point.
    rp(idx) = p(1) + p(2);
    
    % Shift the spectrum
    %sp.spec(:,idx) = fftshift(fft(sp.fid(:,idx))) .* exp(-i*sp.rp(idx));
    sp.spec(:,idx) = sp.spec(:,idx) .* exp(-i*rp(idx));
end

% Convert from the spectrum back to fid.
sp = spec_ifft(sp);








