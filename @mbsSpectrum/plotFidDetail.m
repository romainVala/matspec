% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - plotFidDetail
% AUTHOR: pjb
% CREATED: 5/23/2003
% DESCRIPTION: Plots the summed fid, and a variety of plots
% ARGUMENTS: mbsSpectrum
% RETURNS: none
% MODIFICATIONS:
% ****************************************************************************** 
function plotFidDetail(sp)

% First, average. This operates on one FID only
sp = average(sp);

% Get SNR
[snr_amp, snr_pwr, noiserms, maxsig] = getSnrTd(sp);

% Show the time axis in ms
timeax = sp.time .* 1000;

% First do the real and imaginary components with noise
subplot(3,1,1);
plot(timeax, timeax.*0 + noiserms,':k',...
    timeax, timeax.*0 - noiserms,':k', ...
    timeax, imag(sp.fid),'r',...
    timeax, real(sp.fid),'b');
xlabel('Time (ms)');


% Then show the magnitude with the regions divided into signal, transition,
% noise

% Calculate a smoothed fid
smfid = medfilt1(abs(sp.fid), 20);


% Find the first point where the smoothed fid drops below my highsnr
% threshold:
highsnr_threshold = noiserms * 2;
skippts = 5; % Ignore the first few points in case the receiver didn't gate
tmp = find(smfid(skippts:sp.pts) < highsnr_threshold);
if isempty(tmp)
    highsnr_threshpt = 1;
else
    highsnr_threshpt = skippts + tmp(1);
end
%disp(highsnr_threshpt);

% Find the noise region. Go back from end, and find the first point where
% the smoothed fid rises above a threshold. This is a first step; I know there is
% still signal in this region.
noise_threshold = noiserms * 2;
tmp = find(smfid > noise_threshold);
if isempty(tmp)
    % The entire spectrum is in the noise
    noise_threshpt = 1;
else
    noise_threshpt = max(tmp);
end

% Now readjust, and take only the last 1/2 of my predicted noise region
noisepoints = sp.pts - noise_threshpt;
noise_threshpt = round(sp.pts - 0.5 * noisepoints);

subplot(3,1,2);
plot(timeax, abs(sp.fid), 'b',...
    timeax, timeax.*0 + noiserms,':k', ...
    timeax, smfid, 'k');
hold on;
maxval = max(abs(sp.fid));
line(timeax(highsnr_threshpt) .* [1 1], [0 maxval], 'LineStyle', ':');
line(timeax(noise_threshpt) .* [1 1], [0 maxval], 'LineStyle', ':');
hold off;


% Then show the phase
subplot(3,1,3);
plot(timeax, unwrap(angle(sp.fid)));

