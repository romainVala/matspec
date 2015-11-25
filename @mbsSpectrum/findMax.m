% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - findMax
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Finds peaks in the spectrum
% ARGUMENTS: 
%   sp - mbsSpectrum object
%   limleft, limright - the range to look for. Should be in ppm.
%   bAbsMode - 1 for abs mode, 0 for real mode
% RETURNS: the intensity and position of the peak
% MODIFICATIONS:
% 12/18/2002 PJB - made arguements optional
% ******************************************************************************
function [inten, posppm] = findMax(sp, limleft, limright, bAbsMode)


if nargin < 4
    bAbsMode = 1;
end

% Get the indices to find a max over
if nargin < 2
    jdxleft = 1;
    jdxright = sp.pts;
else
    % Check for limits at endpoints
    limleft = min([limleft max(sp.freq)]);
    limright = max([limright min(sp.freq)]);

    % Find the indices to search over
    jdxleft = interp1(sp.freq,1:sp.pts,limleft,'nearest');
    jdxright = interp1(sp.freq,1:sp.pts,limright,'nearest');
end

for idx = 1:sp.numspec
    if bAbsMode
        maxjdx = find(abs(sp.spec(:,idx))==max(abs(sp.spec(jdxleft:jdxright,idx))));
    else
        maxjdx = find(real(sp.spec(:,idx))==max(real(sp.spec(jdxleft:jdxright,idx))));    
    end
    
    % Could have a problem if there are two identical points
    if max(size(maxjdx))>1 
        error('findMax failed - found two points with identical values');    
    end
    
    posppm(idx) = sp.freq(maxjdx);
    
    if bAbsMode
        inten(idx) = abs(sp.spec(maxjdx,idx));
    else
        inten(idx) = real(sp.spec(maxjdx,idx));
    end
    
end












