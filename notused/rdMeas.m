function [mrprot, mdh, fid] = rdMeas(varargin)
% read in raw fid data from Siemens meas.out/meas.asc file
% returns MrProt, YAPS buffer, MDH entries, and raw fid data
% usage: [mrprot, mdh, fid] = rdMeas(outPath, ascPath, reInterpolate, deOversample, dcCorr, doFlip)

% ////////////////////////////////////////////////////
% ////// first, some options
% ////////////////////////////////////////////////////

% defaults
outPath = 'meas.out';
ascPath = 'meas.asc';

% EPI is often sampled on the ramps and requires interpolation
%   set reInterpolate if this should be done as it is read
reInterpolate = true;

% usually, data is oversampled 2X by default
% set deOversample if rdMeas.m should de-oversample the data
deOversample = true;

% set dcCorr ~= 0 if rdMeas.m should remove DC from the each fid
%    e.g., dcCorr = 16 will use 1/16 of the points on each tail to estimate
%    DC (4 points is the absolute minimum)
dcCorr = 0;  % this might be done already??

% set doFlip = true to reverse the appropriate EPI lines automatically
doFlip = true;

% read passed parameters
if (nargin >= 1)
    outPath = char(varargin{1});
    tpos = strfind(lower(outPath),'meas.out');
    if (tpos)
        ascPath = outPath;
        ascPath(tpos+5:tpos+7) = 'asc';
    end
    if (nargin >= 2)
        ascPath = char(varargin{2});
        if (nargin >= 3)
            reInterpolate = varargin{3};
            if (nargin >= 4)
                deOversample = varargin{4};
                if (nargin >= 5)
                    dcCorr = varargin{5};
                    if (nargin >= 6)
                        doFlip = varargin{6};
                    end
                end
            end
        end
    end
end

% end options -------------------------

% first, open the .out/.dat file and check the header

fprintf('Open %s\n',outPath)

fp = fopen(outPath, 'r', 'ieee-le');

% find file size
fseek(fp, 0, 'eof');
fsize = ftell(fp);
fprintf('File size: %.2f MB\n',fsize/(1024*1024));

fseek(fp, 0, 'bof');
hdrsize = fread(fp, 1, 'uint32');

% if the offset is 32 bytes, this is old (pre-VB13) data, so check for the
% meas.asc file--otherwise, the meas.asc equivalent data is embedded in the
% .dat

if (hdrsize == 32)
    % this must be pre-VB13 data
    % for pre-VB13, skip 32-byte header in meas.out and read in parameter data from meas.asc file (MrProt & YAPS data)
    VB13 = false;
    fprintf('This appears to be pre-VB13 meas.out/meas.asc data\n');
    fprintf('Open %s\n',ascPath);
    fp2 = fopen(ascPath, 'r');
    fprintf('Read MrProt & YAPS\n');
    mrprot = parse_mrprot(fp2);
    fprintf('Close meas.asc\n')
    fclose(fp2);
else
    % this must be >=VB13 data
    VB13 = true;
    fprintf('This appears to be VB13 or newer meas.dat data\n');
    nEvp = fread(fp, 1, 'uint32');  % number of embedded evp files (?)
    % read all of the embedded evp files
    MeasYapsIdx = 0;
    for x=1:nEvp
        EvpName{x} = read_cstr(fp);
        if (strcmp(char(EvpName{x}), 'MeasYaps')), MeasYapsIdx = x; end
        dsize = fread(fp, 1, 'uint32');
        EvpDat{x} = fread(fp, dsize, '*char');
    end
    
    % find the meas.asc part, save it, and parse the mrprotocol
    if (MeasYapsIdx == 0)
        error('meas.asc data not found within meas.dat!')
    end
    tmp_fn = tempname;
    fp3 = fopen(tmp_fn,'w+');
    %fprintf('%s',char(EvpDat{MeasYapsIdx}))
    fwrite(fp3,char(EvpDat{MeasYapsIdx}),'char');
    frewind(fp3);
    mrprot = parse_mrprot(fp3);
    fclose(fp3);
    delete(tmp_fn);
end

% then, the fastest way to do this seems to be to go through meas.out once
% first to read the mdh entries (fixed size), then allocate a chunk of memory
% and go back through again read the image data.  if memory isn't preallocated,
% this takes much, much longer.

fprintf('Reading first block of MDH entries\n');

% set fpos to start of mdh data
fseek(fp, hdrsize, 'bof');

% read mdh data until eof; store pointers for image data
idx = 0;
idx_max = 0;
rawidx = 0;
status = 0;
loop_inc = 256;
mdh = [];
while (status == 0)
    idx = idx + 1;

    mdh.ulDMALength(idx,1)                 = fread(fp,1,'*uint32');
    mdh.lMeasUID(idx,1)                    = fread(fp,1,'*int32');
    mdh.ulScanCounter(idx,1)               = fread(fp,1,'*uint32');
    mdh.ulTimeStamp(idx,1)                 = fread(fp,1,'*uint32');
    mdh.ulPMUTimeStamp(idx,1)              = fread(fp,1,'*uint32');
    mdh.aulEvalInfoMask(idx,:)             = fread(fp,2,'*uint32');
    mdh.ushSamplesInScan(idx,1)            = fread(fp,1,'*uint16');
    mdh.ushUsedChannels(idx,1)             = fread(fp,1,'*uint16');
    %start sLoopCounter
    mdh.ushLine(idx,1)                     = fread(fp,1,'*uint16');
    mdh.ushAcquisition(idx,1)              = fread(fp,1,'*uint16');
    mdh.ushSlice(idx,1)                    = fread(fp,1,'*uint16');
    mdh.ushPartition(idx,1)                = fread(fp,1,'*uint16');
    mdh.ushEcho(idx,1)                     = fread(fp,1,'*uint16');
    mdh.ushPhase(idx,1)                    = fread(fp,1,'*uint16');
    mdh.ushRepetition(idx,1)               = fread(fp,1,'*uint16');
    mdh.ushSet(idx,1)                      = fread(fp,1,'*uint16');
    mdh.ushSeg(idx,1)                      = fread(fp,1,'*uint16');
    mdh.ushIda(idx,1)                      = fread(fp,1,'*uint16');
    mdh.ushIdb(idx,1)                      = fread(fp,1,'*uint16');
    mdh.ushIdc(idx,1)                      = fread(fp,1,'*uint16');
    mdh.ushIdd(idx,1)                      = fread(fp,1,'*uint16');
    mdh.ushIde(idx,1)                      = fread(fp,1,'*uint16');
    %start sCutOffData
    mdh.ushPre(idx,1)                      = fread(fp,1,'*uint16');
    mdh.ushPost(idx,1)                     = fread(fp,1,'*uint16');
    mdh.ushKSpaceCentreColumn(idx,1)       = fread(fp,1,'*uint16');
    mdh.ushDummy(idx,1)                    = fread(fp,1,'*uint16');
    mdh.fReadOutOffcentre(idx,1)           = fread(fp,1,'*float32');
    mdh.ulTimeSinceLastRF(idx,1)           = fread(fp,1,'*uint32');
    mdh.ushKSpaceCentreLineNo(idx,1)       = fread(fp,1,'*uint16');
    mdh.ushKSpaceCentrePartitionNo(idx,1)  = fread(fp,1,'*uint16');
    mdh.aushIceProgramPara(idx,:)          = fread(fp,4,'*uint16');
    mdh.aushFreePara(idx,:)                = fread(fp,4,'*uint16');
    %start sSliceData
    %start sSlicePosVec
    mdh.flSag(idx,1)                       = fread(fp,1,'*float32');
    mdh.flCor(idx,1)                       = fread(fp,1,'*float32');
    mdh.flTra(idx,1)                       = fread(fp,1,'*float32');
    mdh.aflQuaternion(idx,:)               = fread(fp,4,'*float32');
    if (VB13)
        mdh.ulChannelId(idx,1)             = fread(fp,1,'uint16=>uint32');  % now actually ushChannelId
        mdh.ushPTABPosNeg(idx,1)           = fread(fp,1,'*uint16');
    else
        mdh.ulChannelId(idx,1)             = fread(fp,1,'*uint32');
    end

    % store the current file pointer in the index, and skip to the next mdh
    rawidx(idx) = ftell(fp);
    fseek(fp, double(mdh.ushSamplesInScan(idx))*2*4, 'cof');

    % first time through, estimate number of entries and preallocate memory
    if (idx == 255)
        idx_max = idx * ceil(fsize/(rawidx(idx)-hdrsize));
        loop_inc = floor(idx_max/100);
        if (loop_inc > 1024), loop_inc = 1024; end
        fprintf('Estimating %d & preallocating %d MDH entries\n',idx_max,idx*ceil(idx_max/idx));
        fnames = fieldnames(mdh);
        for x=1:size(fnames,1)
            fnamestr = char(fnames(x));
            mdh.(fnamestr) = repmat(mdh.(fnamestr), ceil(idx_max/idx), 1);
        end
        rawidx = repmat(rawidx, 1, ceil(idx_max/idx));
        fprintf('Reading MDH entries: %7d (%3d%%)',idx,round(100*(rawidx(idx)/fsize)));
    end

    % update waitbar periodically
    if (mod(idx,loop_inc) == 0), fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b%7d (%3d%%)',idx,round(100*(rawidx(idx)/fsize))); end
    %fprintf('\nDEBUG: idx = %9d ; rawidx(idx) = %15d ; fsize = %15d',idx,rawidx(idx),fsize);

    % check ending conditions
    if (ftell(fp) >= fsize)
        status = -1;
    end
end
%fprintf('\nDEBUG: done reading MDH\n');
if (idx > 256), fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b%7d (%3d%%)\n',idx,100); end

% truncate mdh array if our estimate was high
if (idx < idx_max)
    fprintf('Estimate was high -- truncating MDH array\n');
    for x=1:size(fnames,1)
        fnamestr = char(fnames(x));
        mdh.(fnamestr) = mdh.(fnamestr)(1:idx,:);
    end
end

% now that we know how many fids we have, and how big they are,
% we can allocate memory for them
if (deOversample == true)
    OSfactor = mrprot.flReadoutOSFactor;
else
    OSfactor = 1.0;
end

fprintf('Allocating memory for raw data (%d x %d complex single array)\n',mdh.ushSamplesInScan(1)/OSfactor,idx);

fid = complex(ones(mdh.ushSamplesInScan(1)/OSfactor,idx,'single'));

tmp = whos('fid');
fprintf('Raw data memory successfully allocated (%.1f MB)\n',tmp.bytes/1048576);

% precompute some of the interpolation parameters if necessary
if (reInterpolate == true)
    % check if we really need to do this
    if (mrprot.alRegridMode(1) == 2)                     % 2 = REGRID_TRAPEZOIDAL
        % build the trapezoidal waveform
        rotrap = ones(1,mrprot.alRegridRampupTime(1)+mrprot.alRegridFlattopTime(1)+mrprot.alRegridRampdownTime(1));
        roramp = 0:1/(mrprot.alRegridRampupTime(1)-1):1;
        rotrap(1:mrprot.alRegridRampupTime(1))= roramp;
        rotrap(mrprot.alRegridRampupTime(1)+mrprot.alRegridFlattopTime(1)+1:end) = fliplr(roramp);

        % cut off the unused parts
        rotrap = rotrap(mrprot.alRegridDelaySamplesTime(1)+1:end);
        rotrap = rotrap(1:mrprot.aflRegridADCDuration(1));

        % integrate
        trapint = zeros(size(rotrap,2),1);
        for z=1:size(rotrap,2)
            trapint(z) = sum(rotrap(1:z));
        end

        % assemble the desired k-space trajectory
        % add a point on the beginning and end since otherwise the
        %     interp1 function goes wacko
        destTraj = 0:sum(rotrap)/(mrprot.alRegridDestSamples(1)+1):sum(rotrap);
    end
end

if ( (reInterpolate == true) && (mrprot.alRegridMode(1) >= 2) )
    fprintf('Reading and interpolating image raw data:   0%%');
elseif (OSfactor > 1.0)
    fprintf('Reading and deoversampling image raw data:   0%%');
else
    fprintf('Reading image raw data:   0%%');
end

% loop through the file again and read in the image data
for x=1:idx
    % set the position in the file
    %fprintf('\nDEBUG: seeking %d',rawidx(x));
    fseek(fp, rawidx(x), 'bof');

    % read in the complex fid data
    nSamples = double(mdh.ushSamplesInScan(x));
    realIdx = 1:2:nSamples*2;
    imagIdx = realIdx + 1;
    trc = fread(fp, nSamples*2, '*float32');
    ctrc = complex(trc(realIdx),trc(imagIdx));

    % reverse EPI lines if desired
    if (doFlip == true)
        %if (findstr(dumpEvalInfoMask(mdh.aulEvalInfoMask(x,1)),'MDH_REFLECT') > 0)
        if (bitget(mdh.aulEvalInfoMask(x,1),25))
            ctrc = rot90(ctrc,2);
        end
    end

    % dc correct if desired
    if (dcCorr > 0.0)
        numCols = size(ctrc,1);
        avgLen = round(numCols/dcCorr);
        if (avgLen < 4), avgLen = 4; end
        samp = [ctrc(1:avgLen); ctrc(numCols-avgLen+1:numCols)];

        rdc = mean(real(samp));
        idc = mean(imag(samp));
        cdc = complex(rdc,idc);
        ctrc = ctrc - cdc;
    end

    % interpolate the data if necessary
    if (reInterpolate == true)
        % check if we really need to do this
        if (mrprot.alRegridMode(1) == 2)                     % 2 = REGRID_TRAPEZOIDAL
            %if (findstr(dumpEvalInfoMask(mdh.aulEvalInfoMask(x,1)),'MDH_ACQEND') > 0)
            if (bitget(mdh.aulEvalInfoMask(x,1),1))
                % skip postprocessing on this one
            else
                % ***** use built-in interpolation functions
                % assemble the actual k-space trajectory for this line
                actualDwell = mrprot.aflRegridADCDuration(1)/nSamples;
                zidx = 1;
                actTraj = zeros(mrprot.aflRegridADCDuration(1)/actualDwell,1);
                for z = 1:actualDwell:mrprot.aflRegridADCDuration(1)
                    actTraj(zidx) = trapint(round(z));
                    zidx = zidx + 1;
                end

                % interpolate
                ctrc = interp1(actTraj,ctrc,destTraj,'linear');
                ctrc = ctrc(2:end-1);
                ctrc = ctrc';
            end
        end
    end

    if (OSfactor > 1.0)
        % de-oversample the data if desired
        ictrc = fftshift(fft(ctrc));
        stpos = nSamples/(OSfactor*2.0);
        ictrc = ictrc(stpos+1:stpos+(nSamples/OSfactor));
        ctrc = ifft(ifftshift(ictrc));
    end
    
    %if (findstr(dumpEvalInfoMask(mdh.aulEvalInfoMask(x,1)),'MDH_ACQEND') > 0)
    if (bitget(mdh.aulEvalInfoMask(x,1),1))
        % don't save the data from the acqend line, since sometimes it has
        % a large (>2000) number of samples and will inflate the entire
        % data array unnecessarily
        % in fact, set SamplesInScan to 0 so as not to confuse the sort
        % routine
        mdh.ushSamplesInScan(x) = 0;
    else
        fid(1:nSamples/OSfactor,x) = ctrc;
    end

    % update waitbar periodically
    if (mod(x,loop_inc) == 0), fprintf('\b\b\b\b%3d%%',ceil(100*x/idx)); end
end
fprintf('\b\b\b\b%3d%%',100);

% clean up and finish
fprintf('\nClose meas.out\n');
fclose(fp);
fprintf('Success!\n\n');





%--------------------------------------------------------------------------
function outstr = read_cstr(fp)
% read null-terminated variable-length string from file

outstr = char(zeros(1,1000));
inchar = char(1);

idx = 1;
while (inchar ~= char(0))
    inchar = fread(fp, 1, '*char');
    outstr(idx) = inchar;
    idx = idx + 1;
end

outstr = c_str(outstr);
