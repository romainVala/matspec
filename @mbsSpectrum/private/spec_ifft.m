% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - spec_ifft
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Calcs the FID from the SPEC
% ARGUMENTS: mbsSpectrum 
% RETURNS: mbsSpectrum
% MODIFICATIONS:
% ******************************************************************************
function sp = spec_ifft(sp)
% This can be unwrapped


for idx = 1:sp.numspec
    sp.fid(:,idx) = ifft(fftshift(sp.spec(:,idx)));  
    
    % I'm adjusting the magnitude here to keep the fid and spec in same scale.
    sp.fid(:,idx) = sp.fid(:,idx) .* sqrt(sp.pts);
end
