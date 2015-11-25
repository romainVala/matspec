% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - constructor
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Constructor for the mbsSpectrum object
% This class is specifically designed for the CMRR Breast MRS project, but it should
%   be applicable to any MRS data which is saved one FID at a time. 
% ARGUMENTS: either nothing, or another mbsSpectrum
% RETURNS: none
% MODIFICATIONS:
%   10/7/2002 PJB - adding TR and TE, seqfil, and a version
%   11/2/2002 PJB - added p1 for powercal
%   5/17/2003 PJB - added navfid, version 1.4
%   9/26/2006 PJB - Updated to version 3.0 for the ACRIN trial
% ****************************************************************************** 
function sp = mbsSpectrum(inVal,spec)
if nargin == 0
    
    % The default constructor. This is where the members are defined.
    %   If you add any here, you'll need to update readVarian, display,
    %   and whatever access methods you need.
    sp.fid = [];
    sp.spec = [];
    sp.time = [];
    sp.freq = [];
    sp.at = 0;
    sp.sfrq = 0;
    sp.swppm = 0;
    sp.gain = 1;
    sp.pts = 0;
    sp.numspec = 0;
    sp.filename = '';
    sp.voxsize = 0;
    sp.centerfreq = 4.7;
    sp.tr = 0;
    sp.te = 0;
    sp.seqfil = '';
    sp.version = '3.0';
    sp.p1 = 0;
    sp.array = '';
    sp.navfid = [];
    
    % Convert this struct into a class and return
    sp = class(sp,'mbsSpectrum');
    
  elseif isa(inVal,'mbsSpectrum')
    sp = inVal;
  else
    sp = mbsSpectrum();
    
    %    error('Unable to construct mbsSpectrum - unknown input');
    sp.fid = inVal;
    sp.pts = spec.spectrum.np;
    
    sp.numspec = size(inVal,2);
  
    sp.at = spec.spectrum.dw *  (spec.spectrum.np-1) ;
    
    sp.sfrq = spec.spectrum.cenfreq ;
    
    sp.gain = 0;
    sp.voxsize = 1;
    
    sp.swppm = spec.spectrum.SW_p;
    
    sp.tr = 0;
    sp.seqfil = '';
    sp.p1 = 0;
    sp.array = '';
 
    %sp = class(sp,'mbsSpectrum');

    % FFT
    sp = spec_fft(sp);


    %Calculate axes
    sp = calcAxes(sp);

end