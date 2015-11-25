% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - getSnrFd
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: 
% Returns the snr, noiserms, and maxsig in the Frequency domain
% 	for the summed Spectra.
% Noise is always for complex data = 2x real data
% ARGUMENTS: mbsSpectrum
% RETURNS: snr_amp, snr_pwr, noiserms, maxsig
%   This function returns a simple ratio - you can convert it to dB as follows:
%       snr dB  = 10*log10(snr_amp) 
%               = 20*log10(snr_pwr)
% MODIFICATIONS:
%   1/18/2003 PJB: returns power and amplitude SNRs
% ******************************************************************************
function [snr_amp, snr_pwr, noiserms, maxsig] = getSnrFd(sp)

spave = average(sp);
spec = get(spave, 'spec');

noiserange = 1:1/8 * sp.pts;

% I calculate the noise with real data, since my 
%   baseline fitting requires real data. I could 
%   do real and imaginary separately and add them 
%   together, but they should be equal, so I'll 
%   do the real only and double it.
% Need to double check that approach this is correct.
specnoise = real(spec(noiserange));
P = polyfit(noiserange, specnoise',1);
baselineFit = P(1).*noiserange + P(2);
specnoise = specnoise - baselineFit';
    
noisevar = mean(conj(specnoise) .* specnoise) * 2; 
noiserms = sqrt(noisevar);
maxsig = abs(max(spec));
snr_amp = maxsig / (noiserms); 

% Also snr_pwr
snr_pwr = (1/sp.pts)*sum(spec.*conj(spec))/(noisevar);
