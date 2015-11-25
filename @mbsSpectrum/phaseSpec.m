% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - phaseSpec
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Phases the spectra by the specified angles (degrees)
% ARGUMENTS: mbsSpectrum 
%   angDegrees - this operates in one of two modes. If andDegrees is scalar, 
%   it phases all spectra the same. If its an array, it better be equal to the 
%   number of spectra - then each gets different phases. In degrees.
% RETURNS: mbsSpectrum, phased
% MODIFICATIONS:
% ****************************************************************************** 

function sp = phaseSpec(sp, angDegrees)

dim = max(size(angDegrees));
if dim ==1
    angDegrees = (1:sp.numspec).* 0 + angDegrees;
elseif max(size(angDegrees)) ~= sp.numspec
    error('Dimension of angDegrees is not equal to numspec');  
end

% Convert to radians
angRadians = angDegrees * pi/180;


for idx = 1:sp.numspec
    sp.spec(:,idx) = sp.spec(:,idx) .* exp(-i*angRadians(idx));
end

sp = spec_ifft(sp);













