% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - readPhilips
% AUTHOR: pjb
% CREATED: 4/13/2004
% DESCRIPTION: Reads in the file from disk .
% The Philips format is two files, .SDAT and .SPAR. You pass in the .SDAT. To 
%	make this more robust, it should read values from the SPAR 
% ARGUMENTS: blank mbsSpectrum, filename. If no filename is provided, a gui
%   will prompt for one.
% RETURNS: mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function sp = readPhilips(sp, filename)


% Need to read the .SPAR file to get some parameters. 
[pathstr, name, ext, versn] = fileparts(filename);
spar = [pathstr filesep name '.SPAR'];
parvals = parsePhilipsSPAR(spar);

% Take some values
sfrq = parvals.synthesizer_frequency / 1000000;
swhz = parvals.sample_frequency;
npoints = parvals.samples * 2; % Samples is the number of complex samples
numspec = parvals.rows;

if nargin < 2
    % prompt the user for a filename
    [fname, pname] = uigetfile('*','Select the Philips .SDAT data');
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

% Open and read the data
fp = fopen(filename,'r','vaxd');
fid = zeros(npoints/2, numspec);
for idx = 1:numspec
    raw = fread(fp,npoints,'float');
    fid(:, idx) = raw(1:2:npoints) - i*raw(2:2:npoints);
end
fclose(fp);

% Save as sp
sp.fid = fid;
% Oct 1 2004 PJB: npoints is number of complex points!
sp.pts = npoints/2;
sp.numspec = numspec;
deltaT = 1/swhz;

sp.at = deltaT * (sp.pts);
sp.sfrq = sfrq;
sp.gain = 0;
sp.voxsize = parvals.ap_size * parvals.lr_size * parvals.cc_size;
sp.swppm = swhz / sp.sfrq;
sp.tr = parvals.repetition_time;
sp.seqfil = '';
sp.p1 = 0;
sp.array = '';

sp.te = parvals.echo_time;

% FFT
sp = spec_fft(sp);

% Calculate axes
sp = calcAxes(sp);

%disp(info);
%disp(mrprot);
return;


