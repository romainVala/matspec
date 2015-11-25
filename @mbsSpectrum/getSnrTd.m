% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - getSnrTd
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: 
% Returns the snr, noiserms, and maxsig in the Time domain
% 	for the summed FID.
% Noise is always for complex data = 2x real data
% ARGUMENTS: mbsSpectrum
% RETURNS: snr_amp, snr_pwr, noiserms, maxsig
%   This function returns a simple ratio - you can convert it to dB as follows:
%       snr dB  = 10*log10(snr_amp) 
%               = 20*log10(snr_pwr)
% MODIFICATIO%   1/18/2003 PJB: returns power and amplitude SNRs
% ******************************************************************************
function [snr_amp, snr_pwr, noiserms, maxsig] = getSnrTd(sp)

sp = average(sp);
noiserange = 7/8 * sp.pts: sp.pts;

noisevar = mean((conj(sp.fid(noiserange)) .* sp.fid(noiserange))); % Complex noise
noiserms = sqrt(noisevar);
maxsig = abs(max(sp.fid)); % Max complex signal
snr_amp = maxsig / (noiserms); 


% I should be calculating the SNR using a power measure, not just an amplitude 
%   ratio. Assume the noise value is correct. Then use the power for the 
%   signal power. 
snr_pwr = (1/sp.pts)*sum(sp.fid.*conj(sp.fid))/(noisevar);
