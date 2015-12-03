% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - shiftSpec
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: 
%   Shifts the spectrum.
%   This operates in one of two modes. If shiftppm is scalar, it shifts 
%       all spectra the same. If its an array, it better be equal to the 
%       number of spectra - then each gets different shifts.
% ARGUMENTS: mbsSpectrum, array of shifts, degrees
% RETURNS: corrected mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function sp = shiftSpec(sp, shiftppm)

dim = max(size(shiftppm));
if dim ==1
    shiftppm = (1:sp.numspec).* 0 + shiftppm;
elseif max(size(shiftppm)) ~= sp.numspec
    error('Dimension of shiftppm is not equal to numspec');  
end
   
% Convert to radians
shiftrad = 2*pi * shiftppm/sp.swppm;

for idx = 1:sp.numspec
    % Note that there is no phase shift for the first point, otherwise
    %   this would introduce a zero-order phase shift in the FD.
    tdshift = exp(-i * shiftrad(idx) * (0:sp.pts-1)');
    sp.fid(:,idx) = sp.fid(:,idx) .* tdshift;
end

sp = spec_fft(sp);








