% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - concatenate
% AUTHOR: rrr
% CREATED: 8/7/2002
% DESCRIPTION: concatenate 2 spectrum
% ARGUMENTS: 2 mbsSpectrum
% RETURNS: concatenate mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function [sp] = concatenate(sp1,sp2)

sp = sp1;
sp.fid = cat(2,sp1.fid,sp2.fid);
sp.spec = cat(2,sp1.spec,sp2.spec);
  
sp.numspec = sp1.numspec+sp2.numspec;


