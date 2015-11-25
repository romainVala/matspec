% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - readSiemens
% AUTHOR: pjb
% CREATED: 4/13/2004
% DESCRIPTION: Reads in the file from disk .
% The Siemens format is a DICOM header, with the data in the end of the
% file. Various header values tell you where to begin and end the reading. 
% ARGUMENTS: blank mbsSpectrum, filename. If no filename is provided, a gui
%   will prompt for one.
% sfrq - resonance frequency, in MHz
% swhz - spectral width, Hz
% RETURNS: mbsSpectrum. Optionally, the shadow header structures
% MODIFICATIONS:
% ****************************************************************************** 
function [sp, img, ser, mrprot, dcminfo] = readSiemens(sp, filename)

if nargin < 2
    % prompt the user for a filename
    [fname, pname] = uigetfile('*','Select the Siemens DICOM data');
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

% Read in 
varlen = 4;
dcminfo = dicominfo(filename);
series = dcminfo.SeriesNumber;
%acq = dcminfo.AcquisitionNumber;


%  Note the following: 
%   0029|1210 is the Image header
%   0029|1220 is the series header, which includes the protocol
%   7fe1|1010 is the actual data
% These details are all handled by parse_siemens_shadow
    
% Read the shadow headers
[img, ser, mrprot] = parse_siemens_shadow(dcminfo);

    
    
sfrq = img.ImagingFrequency; % Expected in MHz
% Not sure which is the correct frequency. Both are in ns
deltaT = mrprot.sRXSPEC.alDwellTime; 
deltaT = img.RealDwellTime;
swhz = 1E9 / deltaT;

if isfield(dcminfo,'Private_7fe1_10xx_Creator')
    data_ver = char(dcminfo.Private_7fe1_10xx_Creator);
    if (strcmp(deblank(data_ver),'SIEMENS CSA NON-IMAGE'))
        raw = dcminfo.Private_7fe1_1010;
        npoints = size(raw,1) / 4;

        % dump unit8 data to a temp file
        tmp_fn = tempname;
        % open it using little endian ordering, so this should work on any machine
        fp = fopen(tmp_fn,'w+','ieee-le');
        fwrite(fp,raw);
        frewind(fp);
        raw = fread(fp,npoints,'*float32');
        fclose(fp);
        delete(tmp_fn);
        found_data = 1;
    end
else
    % Get som header info
    %startpos = dcminfo.StartOfPixelData;
    endpos = dcminfo.FileSize;
    nbytes = double(dcminfo.Private_0029_1132);
    npoints = nbytes / varlen;  
    
    % Open and read the data
    %fp = fopen(filename,'r','ieee-le');
    fp = fopen(filename,'r');
    stat = fseek(fp,endpos-nbytes,'bof');
    raw = fread(fp,npoints,'single');
    stat = fclose(fp);
end

fid = raw(1:2:npoints) + i*raw(2:2:npoints);

%rrr add multiarray

if sp.numspec==0

  % Save as sp
  sp.fid = fid;
  % Oct 1 2004 PJB: npoints is number of complex points!
  sp.pts = npoints/2;
  sp.numspec = 1;
  
  sp.at = deltaT * 1E-9 * (sp.pts);
  sp.sfrq = sfrq;
  sp.gain = 0;
  sp.voxsize = 1;
  sp.swppm = swhz / sp.sfrq;
  sp.tr = 0;
  sp.seqfil = '';
  sp.p1 = 0;
  sp.array = '';
  
  
  rfl = 0;
  rfp = 0;
  
  sp.te = 0;

else
  sp.fid(:,end+1) = fid
  sp.numspec = sp.numspec + 1;
  
end
% FFT
  sp = spec_fft(sp);


  %Calculate axes
sp = calcAxes(sp);

% disp('*************************')
% disp('The plain header:')
% disp(dcminfo);
% 
% disp('*************************')
% disp('The image:')
% disp(img);
% 
% disp('*************************')
% disp('The series:')
% disp(ser);
% 
% disp('*************************')
% disp('The protocol:')
% disp(mrprot);
return;


