% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - truncate
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Truncates the FID to the specified number of points,
%   and recalculates the header values as needed.
% ARGUMENTS: mbsSpectrum, and # poins
% RETURNS: mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function sp = truncate(sp,pts)

% Same as zerofilling!
sp = zeroFill(sp,pts);










