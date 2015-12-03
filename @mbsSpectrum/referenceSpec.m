% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - referenceSpec
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: 
%   Shifts the spectra. Finds the max point between limits, and sets that peak 
%   to the reference ppm specified
% ARGUMENTS: 
%   sp - mbsSpectrum
%   limleft, limright - range to look for max
%   ppmref - offset for reference peak
%   bAbsMode - 1 for abs mode, 0 for real mode
% RETURNS: corrected mbsSpectrum, and the shift(s) 
% MODIFICATIONS:
% 030202 PJB - referencing should be done with high frequency resolution. Zero
%   filling is now an option
% ****************************************************************************** 
function [sp, shiftppm] = referenceSpec(sp, limleft, limright, ppmref, bAbsMode, zf)

if zf > 1
    sp_smooth = zeroFill(sp, sp.pts*zf);
else
    sp_smooth = sp;   
end

[inten, posppm] = findMax(sp_smooth, limleft, limright, bAbsMode); 
shiftppm = ppmref - posppm;
sp = shiftSpec(sp, shiftppm);
        









