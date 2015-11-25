% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - correctDC
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Does a DC correction of the FID using the mean of the 
%   last 1/8 points.
% ARGUMENTS: mbsSpectrum
% RETURNS: mbsSpectrum, corrected
% MODIFICATIONS:
% ****************************************************************************** 
function sp = correctDC(sp)

noiserange = floor(.875 * sp.pts):sp.pts;

% Loop version
for idx = 1:sp.numspec
	sp.fid(:,idx) = sp.fid(:,idx) - mean(sp.fid(noiserange,idx));
end

% This is the matrix version. For some reason, this seems to be
%	leaving a small DC offset.
%sp.fid = sp.fid - mean(sp.fid(noiserange));

sp = spec_fft(sp);






