% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - readVarian
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Reads in the file from disk 
% ARGUMENTS: blank mbsSpectrum, filename. If no filename is provided, a gui
%   will prompt for one.
% RETURNS: mbsSpectrum
% MODIFICATIONS:
%   10/7/2002 PJB - adding TR and TE
%   5/18/2003 PJB - adding kludgy support for navigators
%   7/16/2003 PJB - added extension for manual referencing
%   12/14/2005 CAC - added scale_flag for scaling of combined data
% ****************************************************************************** 
function sp = readVarian(sp,filename,scale_flag)

% set scale flag to false (0) if no argument passed
if nargin <= 2
    scale_flag = 0;
end

if nargin < 2
    % prompt the user for a filename
    [fname, pname] = uigetfile('*','Select the FID');
    if fname == 0
        return
    end
    filename = pname;
    disp(sprintf('reading %s', filename));
end


% Filename checking
if exist(filename, 'dir')== 0
    error(sprintf('FID not found: %s', filename));    
end

% Read in 
[sp.fid, mh, bh]=readVarianSpec(filename,1, scale_flag);
sp.fid = squeeze(sp.fid);
sp.pts = size(sp.fid,1);
sp.numspec = size(sp.fid,2);

% Navigator hack
% All the other methods of this object rely on the fid and spec being 2D.
% With a navigator, there is a third dimension. It would be prefereable to
% redesign the class with this in mind, but the quick fix is to simply
% store the navigator fids separately and ignore it for most all methods.
if size(sp.fid,3) == 2
    % We've got a 3rd dimension
    sp.navfid = sp.fid(:,:,2);
    sp.fid = sp.fid(:,:,1);
end

% Get data from the procpar
sp.filename = filename;
procparFileId = fopen([sp.filename '/procpar'], 'r');

sp.at = getProcparVal_Fileid('at',procparFileId);
sp.sfrq = getProcparVal_Fileid('sfrq',procparFileId);
sp.gain = getProcparVal_Fileid('gain',procparFileId);
sp.pts = getProcparVal_Fileid('np',procparFileId)/2; % pts is the number of complex points
sp.voxsize = getProcparVal_Fileid('vox1',procparFileId) * ...
    getProcparVal_Fileid('vox2',procparFileId) * ...
    getProcparVal_Fileid('vox3',procparFileId) / 1000;
swhz = getProcparVal_Fileid('sw',procparFileId);
sp.swppm = swhz / sp.sfrq;
sp.tr = getProcparVal_Fileid('d1',procparFileId);
sp.seqfil = getProcparVal_Fileid('seqfil',procparFileId);
sp.p1 = getProcparVal_Fileid('p1',procparFileId);
sp.array = getProcparVal_Fileid('array',procparFileId);


rfl = getProcparVal_Fileid('rfl',procparFileId);
rfp = getProcparVal_Fileid('rfp',procparFileId);

% disp(sprintf('rof1=%f, rof2=%f',...
%     getProcparVal_Fileid('rof1',procparFileId),...
%     getProcparVal_Fileid('rof2',procparFileId) ));

% The TE calculation 
if (strcmp(sp.seqfil, 'laser_breast_1') == 1) | ...
        (strcmp(sp.seqfil, 'laser_breast_3') == 1)
    
    % Read in necessary parameters
    ipd = getProcparVal_Fileid('ipd',procparFileId);
    mapg = getProcparVal_Fileid('mapg',procparFileId) / 100;
    gmax = getProcparVal_Fileid('gmax',procparFileId);
    trise = getProcparVal_Fileid('trise',procparFileId);
    pw180 = getProcparVal_Fileid('pw180',procparFileId) / 1000000;
    rof2 = getProcparVal_Fileid('rof2',procparFileId) / 1000000;
    tcrush = getProcparVal_Fileid('tcrush',procparFileId);
    nDim = getProcparVal_Fileid('nDim',procparFileId);
    nt = getProcparVal_Fileid('nt',procparFileId);
    
    crushamp = mapg*gmax;
    slew = gmax/trise;
    
    % Note that I don't necessarily use all TEs, only the first N acquired. 
    maxidx = min(size(ipd,2),sp.numspec); % if numspec>ipdarray
    sp.te = 2 * nDim * (pw180 + 2*rof2 + 2*tcrush + 4*crushamp/slew + 2.*ipd(1:maxidx));
    
    if (strcmp(sp.array, 'ipd,nt')==1)
        % In this case, you need to expand the TE array from [45 46 47...]
        % to [45 45 46 46 47 47 ...]
        numNt = max(size(nt));
        
        for idx = 1:max(size(sp.te))
            for jdx = 1:numNt
                teTmp( (idx-1)*numNt + jdx ) = sp.te(idx);
            end
        end
        sp.te = teTmp;
    end
else
    disp(sprintf('** mbsSpectrum.readVarian Warning: sequence is %s, not laser_breast_X', sp.seqfil))
    disp('**    TE calculation is incorrect.');
    sp.te = 0;
end

% Close procpar file
fclose(procparFileId);

% FFT
sp = spec_fft(sp);

% Reference the spectrum using the rfl and rfp parameters.
% rfp is the frequency in Hz from 0ppm. 
% rfl is the position in Hz, relative from the RHS of the spectrum of the
% reference line.
sp.centerfreq = (swhz/2 - rfl + rfp) / sp.sfrq;

% Under some circumstances (recent ramp-up?), these parameters are just WAY
% off. If its not reasonable, just assume that its on water.
if abs(sp.centerfreq)>10
    sp.centerfreq = 4.7;
end


% Extension to the Varian file format.
% On principle, I don't like to modify the raw data. This mechanism enables
% me to manually reference a FID without modifying the original files. To
% manually reference a peak, simply make a file called "refppm" in the .fid
% directory. This file should be an ascii text file containing a single
% number, indicating the frequency of the center of the spectrum in ppm
% units. There may be comment lines beginning with "%". If the file does
% not exist, assume the center is on water.
refFile = [sp.filename '/refppm'];
if (exist(refFile) > 0)
    
    % Read the center frequency from the file
    sp.centerfreq = textread(refFile, '%f', 'commentstyle', 'matlab');
    disp(sprintf(...
        'mbsSpectrum::readVarian() manual referencing extension, %.2f ppm',...
        sp.centerfreq)); 
end


% Calculate axes
sp = calcAxes(sp);
return;




% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: readVarianSpec
% AUTHOR: Originally, I think JP Strupp wrote rdFid. This is adapted from that
% CREATED: 8/7/2002
% DESCRIPTION: Reads in a VARIAN fid file. Specialized for spectroscopy - 
%   slices are ignored. Has a silent flag, too
% ARGUMENTS: 
%   dirname - the name of the directory containing the procpar and fid
%   bSilent - a flag. 1 - no output.
% RETURNS: 
%   fid - the fid, possibly arrayed
%   mh - main header
%   bh - block header
% MODIFICATIONS:
%   12/14/2005 - CAC    scale_flag added for combined spectra reading
% ****************************************************************************** 
function [fid, mh, bh] = readVarianSpec( dirname, bSilent , scale_flag )

% Silent flag
if (nargin == 2) & (bSilent == 1)
    outputFileId = 0;
else
    outputFileId = 1;
end

ppPath = [dirname '/procpar'];
fidPath = [dirname '/fid'];

% out = fopen( 'trcIdx_m.log', 'w');
[fp,message] = fopen( fidPath, 'r', 'ieee-be');
if(fp == -1) 
    % Check to see that it exists
    if( exist(fidPath))
        error(sprintf('Failed to fopen <%s>: \n%s\n', fidPath,message));
    else
        error(sprintf('Cannot find file <%s>\n', fidPath));
    end
end

fprintf(outputFileId, 'Reading: %s\n', fidPath);
mh = getMainHdr( fp );

% A Quick Endian test
if (mh.nblocks > 1000000)
    % Most likely an error
    fprintf(outputFileId,'Found %d blocks. Trying to switch endian-ness...', mh.nblocks);
    fclose(fp);
    fp = fopen( fidPath, 'r', 'ieee-le');
    mh = getMainHdr( fp );
    fprintf(outputFileId,'now %d blocks. ', mh.nblocks);
end 



bh = getBlkHdr( fp);

fpProcpar = fopen(ppPath, 'r');
nv = getProcparVal_Fileid( 'nv', fpProcpar);
nv2 = getProcparVal_Fileid( 'nv2', fpProcpar);
np = getProcparVal_Fileid( 'np', fpProcpar);
pss = getProcparVal_Fileid( 'pss', fpProcpar);
nf = getProcparVal_Fileid( 'nf', fpProcpar);
fclose(fpProcpar);
% nv = getProcparVal( 'nv', ppPath);
% nv2 = getProcparVal( 'nv2', ppPath);
% np = getProcparVal( 'np', ppPath);
% pss = getProcparVal( 'pss', ppPath);
% nf = getProcparVal( 'nf', ppPath);

typefid=4; % spectrum. For now assume only 1D.

dx = np / 2;    
dy = mh.nblocks;
dz = 1;

% If nf=2 (when using explicit acquisition, as in navigated MRS) then there
% are 2 traces. 
%dt = 1;  
dt = mh.ntraces * mh.nblocks / (dz * dy);



% The old allocation is very slow. 
q = i;
fid = q(ones(dx,1),ones(dy,1),ones(dz,1),ones(dt,1));


mainHdrSize = 32;
blkHdrSize = 28;
offArr = zeros(1, mh.ntraces * mh.nblocks);
fileOff = mainHdrSize;
idx = 1;
for blkIdx=1:mh.nblocks
   fileOff = fileOff + blkHdrSize;
   for trcIdx=1:mh.ntraces
		offArr(idx) = fileOff;
		idx = idx + 1;
      fileOff = fileOff + mh.tbytes;
   end
end

% Check for data type.
bIsFloat = bitget(mh.status,4);
%disp(sprintf('IsFloat %.1f', bIsFloat));
if (bIsFloat == 1)
	strPrefix = 'float';
else
	strPrefix = 'int';
end

% Other bits. I don't think I need them
bIsFID = bitget(mh.status,2); % FID or spectrum
bIsComplex = bitget(mh.status,5); % Real or complex	

if (mh.ebytes == 2) 
	strPostfix = '16';
elseif (mh.ebytes == 4)
	strPostfix = '32';
else 
	strPostfix = '64';
end
precision = [strPrefix strPostfix];
fprintf( outputFileId, 'Dims: %d x %d x %d x %d, format=%s\n', dx, dy, dz, dt, precision);


realIdx = 1:2:np;
imagIdx = realIdx + 1;


% Removing the Z-iterator because its confusing and not used
trcIdx = 0;
for it=1:dt
    fprintf( outputFileId, '\nArray: %d ', it);
    for iy=1:dy
        % index must take into account #traces
        %trcIdx = iy + (iz-1)*dy;
        trcIdx = (iy-1)*dt + (it-1) + 1;
        %fprintf(outputFileId, '\ntrcIdx %f, offArr %f', trcIdx, offArr(trcIdx));
        
        if (0 ~= fseek( fp, offArr(trcIdx), 'bof'))
            error( 'Seek failed' );
        end
        trc = fread( fp, np, precision );
        fid(:,iy,it) = trc(realIdx) + i*trc(imagIdx);
    end
end
fprintf( outputFileId, '\nDone\n' );


% 3/26/2004 PJB Hack
% When I combine two spectra together using a VNMR magical macro, the data
% format gets modified somehow. Instead of being int32, it gets saved as
% float32. And, for a truly inexplicable reason, it is scaled 16x lower! In
% this case I will correct the scale and dump out an error message that
% (hopefully) someone will notice so it doesn't cause too much trouble
% later. 
if (bIsFloat) & (mh.status==25)
    disp('**** WARNING ****');    
    disp('This data is flagged as status 25, float and complex. Normal spectra ');
    disp('are flagged as real and integer (which is not correct). This data is ');
    disp('likely produced by combining two normal data sets. For reasons I dont');
    disp('understand, this data needs to be scaled by a factor of 16x. Before relying');
    disp('on this data, make sure that the resultant quantifications from a combined')
    disp('spectrum is consistent with the results from fitting the individual spectra.');
    disp('*****************'); 
    
    % 12/14/2005 CAC Hack
    disp('scale_flag = 1 sets if the 16x scaling is used, CAC 12/14/2005');
    scale_flag
    disp('*****************'); 
    if scale_flag == 1
        fid = fid .* 16;
    end
    
end

fclose(fp);
return;





% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: getMainHdr
% getMainHdr returns the main header of an fid filePointer
% ****************************************************************************** 
function mainHdr = getMainHdr( fp ) 
mainHdr.nblocks = fread( fp, 1, 'int32');
mainHdr.ntraces = fread( fp, 1, 'int32');
mainHdr.np = fread( fp, 1, 'int32');
mainHdr.ebytes = fread( fp, 1, 'int32');
mainHdr.tbytes = fread( fp, 1, 'int32');
mainHdr.bbytes = fread( fp, 1, 'int32');
mainHdr.transf = fread( fp, 1, 'int16');
mainHdr.status = fread( fp, 1, 'int16');
mainHdr.spare1 = fread( fp, 1, 'int32');
return;


% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: getBlkHdr
% getBlkHdr -> returns the block header of an fid filePointer
% ****************************************************************************** 
function blkHdr = getBlkHdr( fp )
blkHdr.scale  = fread( fp, 1, 'int16');
blkHdr.status  = fread( fp, 1, 'int16');
blkHdr.index  = fread( fp, 1, 'int16');
blkHdr.spare3  = fread( fp, 1, 'int16');
blkHdr.ctcount  = fread( fp, 1, 'int32');
blkHdr.lpval  = fread( fp, 1, 'float32');
blkHdr.rpval  = fread( fp, 1, 'float32');
blkHdr.lvl  = fread( fp, 1, 'float32');
blkHdr.tlt  = fread( fp, 1, 'float32');
return;
