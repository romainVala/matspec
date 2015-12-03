% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - freqAlignXCorr
% AUTHOR: pjb
% CREATED: 7/15/2002
% DESCRIPTION: 
%   Shifts the spectra. Finds the max point between limits, and sets that peak 
%   to the reference ppm specified.
% To calculate the x-correlation, it will compare each spectrum to the mean
% spectrum, and determine the max of the xcorrelation. 
% ARGUMENTS: 
% RETURNS: corrected mbsSpectrum, and the shift(s) 
% MODIFICATIONS:

% ****************************************************************************** 
function [sp, shiftppm] = freqAlignXCorr(sp, range, resolutionHz)

numspec = get(sp, 'numspec');
sfrq = get(sp, 'sfrq');
swppm = get(sp, 'swppm');
pts = get(sp,'pts');
deltaFppm = swppm / (pts-1);
deltaFHz = deltaFppm * sfrq;

% Pre-calculate how much ZF is necessary
zf = ceil(deltaFHz/resolutionHz);
zf = max(zf,1);
newDeltaFHz = deltaFHz/zf;
disp(sprintf('Native FD res %.2f Hz, requested %.2f Hz, need zf %.0f gives %.2f Hz',...
    deltaFHz, resolutionHz, zf, newDeltaFHz));

% Pre-calculate Range
maxlags = ceil(range/newDeltaFHz);
disp(sprintf('To cover %.2f Hz, need %.0f points', range, maxlags));

% Zero-fill first
shiftppm = zeros(numspec,1);
sp_sm = zeroFill(sp, pts*zf);
spec = abs(get(sp_sm,'spec'));
specmean = abs(get(average(sp_sm), 'spec'));
%clear sp_sm;


% Loop over each.
for idx = 1:numspec
    %s1 = spec(:,1);
    s1 = specmean;
    s2 = spec(:,idx);
    c = xcorr(s1, s2, maxlags);
    
    % Find the max point
    peakpt = find(c==max(c));
    offsetIdx(idx) = peakpt - (maxlags+1);
    shiftHz(idx) = offsetIdx(idx) * newDeltaFHz;
    
    
%     % DEBUG
%     figure(202)
%     xcrng = -maxlags:1:maxlags;
%     plot(xcrng,c);
%     
%     freq = get(sp_sm, 'freq');
%     sfrq = get(sp_sm, 'sfrq');
%     freq = freq .* sfrq;s
%     figure(201)
%     plot(freq, s1, '-k',...
%         freq, s2, '-b');
%     set(gca,'xlim',[0 1000]);
%     legend(sprintf('%.0f', idx-1), sprintf('%.0f', idx));
%     dummy = input(sprintf('Shift %.0f pts, %.2f Hz', offsetIdx(idx), shiftHz(idx)));
    
end


% Check that the range was sufficient.
if (max(abs(offsetIdx(:))) == maxlags)
    % The max was at the end. Probbably not OK.
    % be more robust - allow 1 or two to be this large.
    disp(sprintf('freqAlignXCorr: Likely insufficient Freq range'))
end

% The shifts shiftHz are differential. Convert them to absolute
% shiftHzAbs(1) = shiftHz(1);
% for idx = 2:numspec
%     shiftHzAbs(idx) = shiftHz(idx) + shiftHzAbs(idx-1);    
% end
shiftHzAbs = -shiftHz;

% Now apply the shifts, in ppm
shiftppm = shiftHzAbs ./ sfrq;

sp = shiftSpec(sp, shiftppm);











