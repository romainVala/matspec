% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - zeroFill
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Expands the FID to the requested number of points, filling
%   in the remainder with zeros.
% ARGUMENTS: mbsSpectrum, new number of points
% RETURNS: mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function sp = zeroFill(sp,pts)

% Copy pts from the old FID to the new one
cp_pts = min(pts, sp.pts); 
tmp = zeros(pts,sp.numspec);
tmp(1:cp_pts,:) = sp.fid(1:cp_pts,:);
clear sp.fid;
sp.fid = tmp;

% Adjust header info
sp.at = sp.at * pts/sp.pts;
sp.pts = pts;

% Regenerate spec and axes
sp = spec_fft(sp);
sp = calcAxes(sp);












