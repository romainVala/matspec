% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - spec_fft
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Creates the SPEC from teh FID
% ARGUMENTS: mbsSpectrum 
% RETURNS: mbsSpectrum
% MODIFICATIONS:
% ******************************************************************************
function sp = spec_fft(sp)

% First clear the old spectrum
clear sp.spec;
sp.spec = sp.fid .* 0;
sp.pts = size(sp.fid,1);

% This is the fast, matrix form of fft + fftshift

sp.spec = fft(sp.fid,[],1);
shiftidx = cat(2,[sp.pts/2+1:sp.pts],[1:sp.pts/2]);
sp.spec(1:sp.pts,:) = sp.spec(shiftidx,:);



% I normalize the frequency spectrum by the number of points
%   so that the units of the time and frequency domain are
%   equal
sp.spec = sp.spec ./ sqrt(sp.pts);
