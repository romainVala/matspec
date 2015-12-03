% ******************************************************************************
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ******************************************************************************
% FUNCTION: appendSpec - add a single spectrum to the end of the array
% AUTHOR: pjb
% CREATED: 9/27/2006
% DESCRIPTION: Add one to the end
% ARGUMENTS: sp - the one being appended to
%           spnew - the spectra to be appended
% RETURNS: sp, the appended array
% MODIFICATIONS:
% ******************************************************************************
function sp = appendSpec(sp, spnew)

if(sp.numspec < 1)
    sp = spnew;
else
    numtoappend = spnew.numspec;
    for idx=1:numtoappend
        sp.fid(:, sp.numspec+idx) = spnew.fid(:,idx);
    end
    sp.numspec = size(sp.fid, 2);
    sp = spec_fft(sp);
end