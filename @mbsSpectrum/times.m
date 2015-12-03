% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - times
% AUTHOR: pjb
% CREATED: 12/9/2002
% DESCRIPTION: Multiplies the spectrum by a scalar
% ARGUMENTS: a mbsSpectrum object and a scalar, either order
% RETURNS: the resultant mbsSpectrum object
% MODIFICATIONS:
% ****************************************************************************** 
function sp = times(a, b)

if isobject(a) 
    sp = a;
    k = b;
else
    sp = b;
    k = a;
end

fid = get(sp, 'fid');
sp = set(sp,'fid',fid.*k);



