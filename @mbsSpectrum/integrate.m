% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - integrate
% AUTHOR: cac
% CREATED: 2/17/2005
% DESCRIPTION: Integrates over a range in the spectrum
% ARGUMENTS: 
%   sp - mbsSpectrum object
%   limleft, limright - the range to integrate over. Should be in ppm.
%   bAbsMode - 1 for abs mode, 0 for real mode
% RETURNS: the integral and centroid of the peak (in ppm)
% MODIFICATIONS:
% 
% ******************************************************************************
function [integral, posppm] = integrate(sp, limleft, limright, bAbsMode)


if nargin < 4
    bAbsMode = 1;
end

% Get the indices to integrate over
if nargin < 2
    jdxleft = 1;
    jdxright = sp.pts;
else
    % Check for limits at endpoints
    limleft = min([limleft max(sp.freq)]);
    limright = max([limright min(sp.freq)]);

    % Find the indices to integrate over
    jdxleft = interp1(sp.freq,1:sp.pts,limleft,'nearest');
    jdxright = interp1(sp.freq,1:sp.pts,limright,'nearest');
end

for idx = 1:sp.numspec
    if bAbsMode
        integral = sum(abs(sp.spec(jdxleft:jdxright,idx)));
        integralW = sum(abs(sp.spec(jdxleft:jdxright,idx) .* sp.freq(jdxleft:jdxright)));
    else
        integral = sum(real(sp.spec(jdxleft:jdxright,idx)));
        integralW = sum(real(sp.spec(jdxleft:jdxright,idx) .* sp.freq(jdxleft:jdxright)));
    end
    
end

posppm = integralW/integral;












