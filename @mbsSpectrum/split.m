% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - split
% AUTHOR: rrr
% CREATED: 8/7/2002
% DESCRIPTION: split in 2 for MEGA sequence
% ARGUMENTS: one mbsSpectrum
% RETURNS: 2 mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function [sp1,sp2] = split(sp)

numspec2 = sp.numspec/2;

sp1 = extractSpec(sp,1:numspec2);
sp2 = extractSpec(sp,(numspec2+1):sp.numspec);

