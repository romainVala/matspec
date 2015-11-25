% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - get
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: the big GET
% ARGUMENTS: mbsSpectrum and property name
% RETURNS: property value
% MODIFICATIONS:
%   5/17/2003 PJB - added navfid
%   6/16/2005 CAC - getProcparVal call for otherwise case
% ******************************************************************************
function val = get(sp,prop_name)
% GET 
switch prop_name
case 'fid'   
    val = sp.fid;
case 'navfid'   
    val = sp.navfid;
case 'spec'
    val = sp.spec;
case 'time'
    val = sp.time;
case 'freq'
    val = sp.freq;
case 'at'
    val = sp.at;
case 'sfrq'
    val = sp.sfrq;
case 'swppm'
    val = sp.swppm;
case 'gain'
    val = sp.gain;
case 'pts'
    val = sp.pts;
case 'numspec'
    val = sp.numspec;
case 'filename'
    val = sp.filename;
case 'voxsize'
    val = sp.voxsize;
case 'centerfreq'
    val = sp.centerfreq;
case 'tr'
    val = sp.tr;
case 'te'
    val = sp.te;
case 'seqfil'
    val = sp.seqfil;
case 'version'
    val = sp.version;
case 'centerfreq'
    val = sp.centerfreq;
case 'p1'
    val = sp.p1;
case 'array'
    val = sp.array;
case 'limleft'
    val = max(sp.freq);
case 'limright'
    val = min(sp.freq);
otherwise
    warning('mbsSpectrum:get_procpar','mbsSpectrum: getting from procpar');
    
    % Try to get it from the procpar, C.Corum after P. Bolan comment
    procpar = [sp.filename '/procpar'];
    val = getProcparVal(prop_name, procpar);
    
    if isempty( val);
        warning('mbsSpectrum:not_found','mbsSpectrum: property not found');
    end
    
end