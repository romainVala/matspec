% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: extractSpec - extract a single spectrum from the array
% AUTHOR: pjb
% CREATED: 1/13/2003
% DESCRIPTION: Gets one mbsSpectrum out
% ARGUMENTS: one mbsSpectrum
% RETURNS: one mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function sp = extractSpec(sp, idx)

if (idx>sp.numspec)
    error('extractSpec: index too large');
end

sp.fid = sp.fid(:,idx);
sp.numspec = max(size(idx));

if idx <= max(size(sp.te))
    sp.te = sp.te(idx);
end
sp = spec_fft(sp);
