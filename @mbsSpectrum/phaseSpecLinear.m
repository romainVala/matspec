% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - phaseSpecLinear
% AUTHOR: pjb
% CREATED: 2/6/2006
% DESCRIPTION: Phases the spectra by both zero and first order phase
% ARGUMENTS: mbsSpectrum 
%   angDegrees - this operates in one of two modes. If andDegrees is scalar, 
%   it phases all spectra the same. If its an array, it better be equal to the 
%   number of spectra - then each gets different phases. In degrees.
%   lpDegrees is interpreted as degrees per ppm.
% RETURNS: mbsSpectrum, phased
% MODIFICATIONS:
% ****************************************************************************** 

function sp = phaseSpecLinear(sp, angDegrees, lpDegrees)

dim = max(size(angDegrees));
if dim ==1
    angDegrees = (1:sp.numspec).* 0 + angDegrees;
elseif max(size(angDegrees)) ~= sp.numspec
    error('Dimension of angDegrees is not equal to numspec');  
end

% Convert to radians
angRadians = angDegrees * pi/180;
lpRadians = lpDegrees * pi/180;

for idx = 1:sp.numspec

	% Performance - zero order is faster
	if (lpDegrees(idx) == 0) 
		sp.spec(:,idx) = sp.spec(:,idx) .* exp(-i*angRadians(idx));
	else
		% Calculate the phase function
		clear phs;
		for jdx = 1:sp.pts
			phs(jdx) = angRadians(idx) + (((sp.pts/2)-jdx)/sp.pts) * (lpRadians(idx)*sp.swppm);
		end
		phs = phs';

		% Apply it
		sp.spec(:,idx) = sp.spec(:,idx) .* exp(-i.*phs);
	end
end

sp = spec_ifft(sp);













