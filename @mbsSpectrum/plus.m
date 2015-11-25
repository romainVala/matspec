% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - plus
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Adds two spectra together, in complex form
% ARGUMENTS: two mbsSpectrum objects
% RETURNS: the resultant mbsSpectrum object
% MODIFICATIONS:
%   10/13/2002 PJB - added fmult to allow for subtraction.
% ****************************************************************************** 
function sp = plus(sp1, sp2, fmult)

if nargin < 3
    fmult = 1;
end

% First, verify that they are addable. That means the SW must
%   be the same. For now, force everything to be the same 
%   (at, sw, pts, centerfreq, numspec). 
% if not, call the error function
if (sp1.at ~= sp2.at |...
        sp1.sfrq ~= sp2.sfrq |...
        sp1.swppm ~= sp2.swppm |...
        sp1.pts ~= sp2.pts |...
        sp1.numspec ~= sp2.numspec |...
        sp1.centerfreq ~= sp2.centerfreq )
    
    error('Cannot add spectra with different acquisition parameters.')
end

% Extract both FIDs and add them complexly
fid1 = get(sp1, 'fid');
fid2 = get(sp2, 'fid');
fidsum = fid1 + fmult .* fid2;

% Then set the FID, and return
sp = sp1;
sp = set(sp, 'fid',fidsum);

