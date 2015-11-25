% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - loadobj
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Reconstitutes a mbsSpectrum after loading a serialized version
% ARGUMENTS: mbsSpectrum
% RETURNS: mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function sp = loadobj(sp)

% Need to recalculate the spec and axes

% I think this needs to be done smart
num = size(sp,2);
for idx = 1:num
    sp(idx) = calcAxes(sp(idx));
    sp(idx) = spec_fft(sp(idx));
end
