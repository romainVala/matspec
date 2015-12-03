% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - truncate
% AUTHOR: pjb
% CREATED: 5/21/2003
% DESCRIPTION: Removes the first pts points and zero-fills the remainder
% ARGUMENTS: mbsSpectrum, and # points to pretruncate
% RETURNS: mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function sp = pretruncate(sp,pts)

fid = sp.fid;
sp.fid(1:sp.pts-pts) = fid(1+pts:sp.pts);
sp.fid(sp.pts-pts+1:sp.pts) = 0;

% Regenerate spec and axes
sp = spec_fft(sp);
sp = calcAxes(sp);









