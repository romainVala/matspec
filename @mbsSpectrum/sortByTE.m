% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - sortByTE
% AUTHOR: pjb
% CREATED: 5/21/2003
% DESCRIPTION: Removes the first pts points and zero-fills the remainder
% ARGUMENTS: mbsSpectrum, and # points to pretruncate
% RETURNS: sp - sorted mbsSpectrum
%   sortIdx - indices of sorted sp.
% MODIFICATIONS:
% ****************************************************************************** 
function [sp, sortIdx] = sortByTE(sp)

% Rearrange spectra by TE
[tes sortIdx] = sort(get(sp,'te'));
fids = get(sp, 'fid');
fids = fids(:,sortIdx);
sp = set(sp,'fid',fids);
sp.te = tes;








