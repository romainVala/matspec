% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - readGEPfile
% AUTHOR: pjb
% CREATED: 3/13/2007
% DESCRIPTION: Reads in the file from a GE p-file
% The GE format is a binary header followed by data. I got this code from 
% Yakir Levin adpated it for the MBS object. 
% ****************************************************************************** 
% I DO NOT HAVE PERMISSION TO SHARE THIS FILE!!!!!!!!! For Internal UMN use
% only!!!!!!!!!!!!!!
% ****************************************************************************** 
% ARGUMENTS: blank mbsSpectrum, filename. If no filename is provided, a gui
%   will prompt for one.
% Note that the header reading is primitive, and does not get all the
% header tags. Need to get this from GE or Marcus Alley. 
% RETURNS: mbsSpectrum. Optionally, the header structure
% MODIFICATIONS:
% ****************************************************************************** 
function [sp, hdr] = readGEPfile(sp, filename)

if nargin < 2
    % prompt the user for a filename
    [fname, pname] = uigetfile('*','Select the GE p-file');
    if fname == 0
        return
    end
    filename = pname;
    disp(sprintf('reading %s', filename));
end

% Filename checking
if exist(filename, 'file')== 0
    error(sprintf('file not found: %s', filename));    
end

% Read in header. Check endian-ness if there's an error.
fp = fopen(filename,'r','native'); 
hdr = ge_pfile_readrdb(fp);
fclose(fp);

% Interpret the header info
sp.pts = hdr.frame_size;
swhz = hdr.spectral_width;
sp.sfrq = hdr.ps_mps_freq / 1E7; % Why such a strange unit?
if sp.sfrq ==0
   % It just wasn't included in the file. Fake it:
   sp.sfrq = 63.8600000;
end

deltaT = 1/swhz; % in s

% Optional Info
% voxel_dimx = hdr.roilenx
% voxel_posx = hrd.roilocx
% Transmit gain = ps_mps_tg. There are two, mps and aps (manual and auto?)


% Prepare to read data
switch hdr.point_size
    case 2
        prec = 'int16';
    case 4
        prec = 'int32';
end

if (hdr.rdbm_rev >= 14.)
    hdrsize = 145908;
elseif (hdr.rdbm_rev >= 11.)
    hdrsize = 66072;
elseif (hdr.rdbm_rev >= 9.)
    hdrsize = 61464;
elseif (hdr.rdbm_rev >= 8.)
    hdrsize = 60464;
elseif (hdr.rdbm_rev >= 7.)
    hdrsize = 39984;
end

% Read it in
fp = fopen(filename,'r','native'); % PJB: Again, Yakir's was BE (mac)
tmp = fread(fp, hdrsize, 'char'); % Skip over the header. Use fseek instead
raw = fread(fp, prec);
stat = fclose(fp);

cplxraw = complex(raw(1:2:length(raw(:))),raw(2:2:length(raw(:))));
sp.numspec = length(cplxraw(:))/sp.pts;

% Assign all fids. Can be faster without loop using reshape, but this is safer.
%sp.fid = zeros(sp.pts, sp.numspec);
sp.fid = reshape(cplxraw, sp.pts, sp.numspec);

% Calculate some more parameters
sp.at = deltaT * sp.pts;
sp.gain = 0;
sp.voxsize = hdr.roilenx * hdr.roileny * hdr.roilenz / 1000; % in mL
sp.swppm = swhz / sp.sfrq;
sp.tr = 0;
sp.seqfil = '';
sp.p1 = 0;
sp.array = '';

sp.te = 0;

% FFT
sp = spec_fft(sp);

% Calculate axes
sp = calcAxes(sp);

return;


