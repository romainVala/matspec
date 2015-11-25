% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - reorder
% AUTHOR: pjb
% CREATED: 7/15/2003
% DESCRIPTION: Puts the spectra back in the order specified
% ARGUMENTS: mbsSpectrum, and index of orders
% RETURNS: sp - sorted mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function sp = reorder(sp, sortIdx)

fids = get(sp, 'fid');
te = get(sp,'te');
fidNew = fids .* 0;
teNew = te .* 0;

for idx = 1:max(size(sortIdx))
    fidNew(:, sortIdx(idx)) = fids(idx);  
    teNew(sortIdx(idx)) = te(idx);
end

sp = set(sp,'fid',fidNew);
sp.te = teNew;








