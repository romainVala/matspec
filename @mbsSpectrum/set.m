% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - set
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Sets some parameters. Doesn't work for all
% ARGUMENTS: mbsSpectrum, param, value
% RETURNS: mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function sp = set(sp,varargin)
% SET 
property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop
    case 'at'
        sp.at = val;
    case 'fid'
        sp.fid = val;
        sp = spec_fft(sp);
        sp.numspec = size(val,2);
    otherwise
        error('Invalid property')
    end
end
