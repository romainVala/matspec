% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - aph0_TDopt
% AUTHOR: pjb
% CREATED: 5/23/2003
% DESCRIPTION: 
% Finds the zeroth order phase of the spectrum, and returns 
%   the phased fid, and the angle in radians.
% Works only on a single fid at a time. Polyfit isn't vectorized.
% This is just like aph0, except that it doesn't use a fixed number of
% points. It uses all the first points up until the SNR drops below a
% treshold.
% ARGUMENTS: one mbsSpectrum
% RETURNS: the phased mbsSpectrum, and the array of phases (rad) corrected,
%   the number of points used in each
% MODIFICATIONS:
% ****************************************************************************** 
function [sp, rp, np] = aph0_TDopt(sp)

% Algorithm:
% This is an improvement on using the first FID point.
% Take the first N points, do a linear fit, and then use the predicted
%   value of the phase of the first FID point.

for idx = 1:sp.numspec
    
    spSingle = extractSpec(sp,idx);
    
    % Calculate the number of points to use. 
    %   1) Find noiserms, define a threshold. 
    [snr_amp, snr_pwr, noiserms, maxsig] = getSnrTd(spSingle);
    highsnr_threshold = noiserms * 2;
    
    %   2) Make a smoothed version of the fid. I use a median filter. I
    %   first have to extend the data, because it zero-pads for boundary
    %   conditions. 
    fid = get(spSingle,'fid');
    filtersize = 10;
    extendedFid = zeros(size(fid,1)+2*filtersize,1);
    extendedFid(1:filtersize) = fid(1);
    extendedFid(filtersize+1:size(fid,1)+filtersize) = fid;
    extendedFid(size(fid,1)+filtersize+1:size(extendedFid,1)) = fid(size(fid,1));
    exsmfid = medfilt1(abs(extendedFid), filtersize);
    smfid = exsmfid(filtersize+1:size(fid,1)+filtersize);
    %smfid = medfilt1(abs(fid), filtersize);
    
    %   3) Find the first point where the smoothed fid drops below the
    %       threshold. Ignore the first few points in case the receiver 
    %       didn't gate. For invivo data, skippts can be 2. In phantoms, it
    %       should be 4 or more.
    skippts = 1; 
    tmp = find(smfid(skippts:sp.pts) < highsnr_threshold);
    
    % DEBUG
    %     figure(101)
    %     plotFidDetail(spSingle);
    %     %dummy = input('press return');
    % END DEBUG
    
    if isempty(tmp)
        % Error case: the whole FID is above the treshold. This means the DC
        % correction was probably bad. Display a message and do not phase.
        disp('WARNING: aph0_TDopt logic failure. FID is above noise threshold.');
        rp(idx) = 0;
        np(idx) = 0;
    elseif tmp(1) == 1
        % Error case: the whole FID is below the treshold. Low SNR - a
        % common situation. Simply don't phase
        rp(idx) = 0;
        np(idx) = 0;
        disp('apho_TDopt: low SNR, no phasing')
    else
        % Don't fit any more than 10 points. This is becuase the phase is
        % only linear in theory - it does evolve in time. What I really
        % want is the phase at t=0, so only take the first few beginning
        % points.
        N = skippts + tmp(1);
        N = min(N,10);
        np(idx) = N;
        %disp(sprintf('apho_TDopt: phasing with %.0f pts', N));
        
        % Fit the phase of the first N points of the fid
        fid = get(spSingle,'fid');
        phs = unwrap(angle(fid(skippts+1:N)));
        p = polyfit(skippts+1:N, phs',1);
        
        % Now y=mx+b, x=1. This projects to first FID point.
        rp(idx) = p(1) + p(2);
        
        % DEBUG
        %         % Show the fit of the phase
        %         figure(111)
        %         plot(1:N, unwrap(angle(fid(1:N))), 'b', ...
        %             1:N, p(1).*(1:N)+p(2), 'k');
        
        
        % Shift the spectrum
        %sp.spec(:,idx) = fftshift(fft(sp.fid(:,idx))) .* exp(-i*sp.rp(idx));
        sp.spec(:,idx) = sp.spec(:,idx) .* exp(-i*rp(idx));
    end
    
    % DEBUG
    %         % Display the two spectra
    %         figure(109)
    %         subplot(2,1,1)
    %         plot(real(get(spSingle,'spec')));
    %         subplot(2,1,2)
    %         if rp(idx) ~= 0
    %             plot(real(get(phaseSpec(spSingle,rp(idx)*180/pi),'spec')));
    %         else
    %             cla
    %         end
    %         dummy = input('press return');
    
    
    % DEBUG
    % Report the values
    %     if 1
    %         disp(sprintf('phasing %.0f: rp %f, np %.0f', idx, rp(idx), np(idx)));    
    %     end
    
end

% Convert from the spectrum back to fid.
sp = spec_ifft(sp);








