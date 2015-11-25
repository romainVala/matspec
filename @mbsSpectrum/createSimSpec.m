% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - createSimSpec
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Creates a simulated spectrum. 
%   This blows away all old info. Should probably be a constructor
% ARGUMENTS: none
%   amp - amplitude, arbitrary units
%   frq - frequency in Hz
%   phs - phase in Deg
%   sfrq - freqeuncy in MHz
%   centerfreq - in ppm
%   lw - lorentzian linewidth in Hz
%   gb - StdDev of gaussian frequency distribution, Hz
%   noiserms - the rms of the noise, specified complex. 
%       This is 2x the real imag components, consistent with other 
%       functions in this object.
% RETURNS: simulated mbsSpectrum
% MODIFICATIONS:
% ******************************************************************************
function sp = createSimSpec(sp, at, pts, sfrq, centerfreq, ...
    amp, frq, phs, lw, glw, noiserms)

clear sp.fid;
clear sp.spec
sp.numspec = 1;

% Calculate Axes
sp.at = at;
sp.pts = pts;
sp.sfrq = sfrq;
sp.centerfreq = centerfreq;
sp = calcAxes(sp);

lambda = lw .* pi;
gamma = glw .* (pi/(2*sqrt(log(2))));

% Simulate
% ! This should use the td_model function!
%disp('WARNING: mbsSpectrum::createSimSpec() not using td_model.');
sp.fid = amp .* exp( ...
    (i * 2 * pi *  frq) .* sp.time + ...
    (i * phs / 180 * pi) + ...
    (- lambda .* sp.time) + ...
    (- (gamma .* sp.time).^2 ) ); 

% Add noise. Normally distributed circular in the time domain
noiseRe = randn(sp.pts,1) .* (noiserms / sqrt(2));
noiseIm = randn(sp.pts,1) .* (noiserms / sqrt(2));
noise = noiseRe + i*noiseIm;
sp.fid  = sp.fid + noise;

sp = spec_fft(sp);