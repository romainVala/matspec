% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - aph0_FDmaxmin
% AUTHOR: pjb
% CREATED: 5/23/2003
% DESCRIPTION: 
% Finds the zeroth order phase of the spectrum, and returns 
%   the phased fid, and the angle in radians.
% A Frequency Domain algorithm - finds the zero-order phase
%   which maximizes the minimum of the real spectrum. First, it does some
%   linebroadening on the peak because it is susceptable to noise.
% Works only on a single fid at a time. Uses degrees internally, but 
%   inputs/outputs are all radians 
% Algorithm: A crude optimization technique - maximizes the real part of
%   the FD spectrum. Works in three passes. 
% ARGUMENTS: one mbsSpectrum
% RETURNS: the phased mbsSpectrum, and the array of phases (rad) corrected
% MODIFICATIONS:
% ****************************************************************************** 
function [sp, rp_out] = aph0_FDmaxmin(sp, rpstart)

% Work on a smoothed version
sp_sm = lineBroaden(sp, 20);

%figure(101)
for jdx = 1:sp.numspec
    
    spSingle = extractSpec(sp_sm,jdx);
    
    % Pass #1: find the global max. Not necessary if a rp was passed in
    if nargin < 2
        rps = -180:10:180;
        for idx = 1:size(rps,2)
            spec = real(get(phaseSpec(spSingle,rps(idx)),'spec'));
            realsumsq(idx) = sum(spec);
            minspec(idx) = min(spec(:));
                        
        end
        %rpstart = rps(find(realsumsq==max(realsumsq)));   
        rpstart = rps(find(minspec==max(minspec)));   
        
        % There can be two of these. I don't know how to choose.
        rpstart = rpstart(1);
        %subplot(3,1,1)
        %plot(rps,realsumsq);
    else
        % rpstart was passed in with radians units. Convert
        rpstart = rpstart * 180/pi;
    end
    
    % Pass #2: Find the phase to 1-degree accuracy. This time use Sum of
    % squares
    clear rps;
    clear realsumsq;
    clear minspec;
    rps = rpstart-10:1:rpstart+10;
    for idx = 1:size(rps,2)
        spec = real(get(phaseSpec(spSingle,rps(idx)),'spec'));
        realsumsq(idx) = sum(spec);
        minspec(idx) = min(spec(:));

    end
    %rp = rps(find(realsumsq==max(realsumsq)));   
    rp = rps(find(minspec==max(minspec)));   
    %subplot(3,1,2)
    %plot(rps,realsumsq);
    
    % Pass #3: 0.1 degree accuracy.
    clear rps;
    clear realsumsq;
    clear minspec;
    rps = rp-1:.1:rp+1;
    for idx = 1:size(rps,2)
        spec = real(get(phaseSpec(spSingle,rps(idx)),'spec'));
        realsumsq(idx) = sum(spec);
        minspec(idx) = min(spec(:));
    end
    %rp = rps(find(realsumsq==max(realsumsq)));   
    rp = rps(find(minspec==max(minspec)));
    %subplot(3,1,3)
    %plot(rps,realsumsq);
    
    % Pass #4: 0.01 degree accuracy.
    clear rps;
    clear realsumsq;
    clear minspec;
    rps = rp-.1:.01:rp+.1;
    for idx = 1:size(rps,2)
        spec = real(get(phaseSpec(spSingle,rps(idx)),'spec'));
        realsumsq(idx) = sum(spec);
        minspec(idx) = min(spec(:));
    end
    %rp = rps(find(realsumsq==max(realsumsq)));   
    rp = rps(find(minspec==max(minspec)));
    rp_out(jdx) = rp;   
    
    
end

% Apply the phase shifts.
sp = phaseSpec(sp, rp_out);

% Convert back to radians
rp_out = rp_out .* pi/180;

