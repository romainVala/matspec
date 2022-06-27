function [fid, dcmInfo] = spec_read(dn, debug)
% function to read spectroscopy data from siemens dicom .ima/.dcm files
%   usage: [fid, dcmInfo] = spec_read(dn)
%   arguments dn = filename

version = '2021.07.27';

if (nargin == 1), debug = false; end

dcmInfo = dicominfo(dn);

% R2006b dicominfo() now reads the spectroscopy data as a private field
% in this case, startofpixeldata is not supplied, so test for that

found_data = 0;
is_conj = false;
if isfield(dcmInfo,'StartOfPixelData')
    % this is old dicominfo, so we have to read pixel data ourselves
    if (debug), fprintf('spec_read: version %s reading old style pixel data\n', version); end
    found_data = -101;
    startpos = double(dcmInfo.StartOfPixelData);
    endpos = double(dcmInfo.FileSize);

    fp = fopen(dn,'r','ieee-le');
    fseek(fp,startpos,'bof');

    dcmData = [];
    while (ftell(fp) < endpos)
        id = fread(fp,2,'*uint16');
        id_str = sprintf('Data_%s_%s',dec2hex(id(1),4),dec2hex(id(2),4));
        vr = fread(fp,2,'uint8=>char')';

        switch (vr)
            case {'OB','OW','SQ','UN'}
                % explicit VR with 32-bit length if first two bytes are 0
                % otherwise implicit vr with 32-bit length
                ln = fread(fp,1,'uint16');
                if (ln == 0)
                    ln = fread(fp,1,'uint32');
                else
                    fseek(fp,-2,'cof');
                    ln = fread(fp,1,'uint32');
                end
            case {'AE','AS','CS','DA','DS','DT','FD','FL','IS','LO','LT',...
                    'PN','SH','SL','SS','ST','TM','UI','US','UT','QQ'}
                % explicit vr with 16-bit length
                ln = fread(fp,1,'uint16');
            otherwise
                % implicit vr with 32-bit length
                ln = fread(fp,1,'uint32');
        end
        
        if (strcmp(id_str,'Data_7FE1_1010'))
            % this is the spectro raw data, which is singles
            dcmData.(id_str) = fread(fp,ln/4,'*float32');
        else
            % otherwise, assume uint8's
            dcmData.(id_str) = fread(fp,ln,'*uint8');
        end
    end
    fclose(fp);

    if isfield(dcmData,'Data_7FE1_0010')
        found_data = -102;
        data_ver = char(dcmData.Data_7FE1_0010)';
        if (strcmp(deblank(data_ver),'SIEMENS CSA NON-IMAGE'))
            raw = dcmData.Data_7FE1_1010;
            found_data = 1;
        end
    end
elseif isfield(dcmInfo,'Private_7fe1_10xx_Creator')
    % this is new dicominfo, so the pixels are already in dcmInfo (yay)
    % but we must convert uint8 to single/float32 (boo)
    if (debug), fprintf('spec_read: version %s reading new style pixel data\n', version); end
    found_data = -201;
    data_ver = char(dcmInfo.Private_7fe1_10xx_Creator);
    if (strcmp(deblank(data_ver),'SIEMENS CSA NON-IMAGE'))
        raw = dcmInfo.Private_7fe1_1010;
        np = size(raw,1) / 4;
        
        % dump unit8 data to a temp file
        tmp_fn = tempname;
        % open it using little endian ordering, so this should work on any machine
        fp = fopen(tmp_fn,'w+','ieee-le');
        fwrite(fp,raw);
        frewind(fp);
        raw = fread(fp,np,'*float32');
        fclose(fp);
        delete(tmp_fn);
        found_data = 1;
    end
elseif isfield(dcmInfo,'SpectroscopyData')
    % this is DICOM spectroscopy format
    if (debug), fprintf('spec_read: version %s reading DICOM spectroscopy format data (conj)\n', version); end
    found_data = -301;
    if isfield(dcmInfo,'MRSpectroscopyAcquisitionType')
        found_data = -302;
        acq_type = char(dcmInfo.MRSpectroscopyAcquisitionType);
        if (strcmp(deblank(acq_type),'SINGLE_VOXEL'))
            found_data = -303;
            if isfield(dcmInfo,'DataRepresentation')
                found_data = -304;
                data_type = char(dcmInfo.DataRepresentation);
                if (strcmp(deblank(data_type),'COMPLEX'))
                    found_data = -305;
                    if isfield(dcmInfo,'SignalDomainColumns')
                        found_data = -306;
                        col_type = char(dcmInfo.SignalDomainColumns);
                        if (strcmp(deblank(col_type),'TIME'))
                            raw = dcmInfo.SpectroscopyData;
                            found_data = 1;
                            is_conj = true; % stored as complex conjugate
                            if isfield(dcmInfo,'NumberOfFrames')
                                raw = reshape(raw,dcmInfo.DataPointColumns.*2,dcmInfo.NumberOfFrames);
                                fid = conj(complex(raw(1:2:end,:),-raw(2:2:end,:))) ; 
                                return
                            end
                            
                        end
                    end
                end
            end
        end
    end   
end

if (found_data ~= 1), error('spec_read version %s ERROR: Spectroscopy raw data not found (code %d)!', version, found_data); end

if (is_conj)
    fid = complex(raw(1:2:end),-raw(2:2:end));
else
    fid = complex(raw(1:2:end),raw(2:2:end));
end
