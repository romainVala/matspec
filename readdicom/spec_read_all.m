function [fid, dcmInfo_arr] = spec_read_all(dn, sortmethod)
% function to read spectroscopy time series data from a
% directory with sequentially named siemens .ima/.dcm files
%   usage: [fid, dcmInfo_arr] = spec_read_all(dn, [sort])
%   arguments dn = filename, [sort 0=Filename/Alphabetical, 1=InstanceNumber]

version = '2021.07.27';

fprintf('spec_read_all.m version %s started\n', version)

if (nargin == 1), sortmethod = 0; end % default to sort by filename alphabetically

fix_unscaled_data = false;   % (old broken ICE program for resolved averages)

ext  = '.dcm';
ext2 = '.DCM';
ext3 = '.ima';
ext4 = '.IMA';
ext5 = '.dic';
ext6 = '.DIC';
found = 0;

files = [dir([dn '/*' ext]) ; dir([dn '/*' ext2]) ; dir([dn '/*' ext3]) ; dir([dn '/*' ext4]); dir([dn '/*' ext5]); dir([dn '/*' ext6])];
[~, sidx] = sort(cellstr(char(files.name)));

% clear out any leading dot files if present
founddotfiles = 0;
for x=1:size(files,1)
    if (files(x).name(1) == '.')
        founddotfiles = founddotfiles + 1;
    elseif (founddotfiles)
        break;
    end
end
if (founddotfiles)
    files = files(founddotfiles+1:end);
end

fprintf('spec_read_all: searching %s\nspec_read_all: found %d candidate filenames\n',dn,size(files,1))
if (size(files,1) < 1)
    error('ERROR: no files found')
end
fprintf('spec_read_all: loading DICOM dictionary\n')
for x=1:size(files,1)
    if (found); fprintf('\b\b\b\b\b\b%-6d',x); end
    idx = sidx(x);
    if (~files(idx).isdir)
        tmp = files(idx).name;
        if (size(tmp,2) > 4)
            if ( strcmpi(tmp(end-3:end),ext) || strcmpi(tmp(end-3:end),ext3) || strcmpi(tmp(end-3:end),ext6) )
                found = found + 1;

                [inFid, inInfo] = spec_read(fullfile(dn,tmp),(found==1));
                if (found == 1)     % first time through, preallocate arrays
                    fprintf('spec_read_all: reading file 1     ')
                    fid = complex(zeros(size(inFid,1),size(files,1)));
                    dcmInfo_arr(size(files,1)) = inInfo; %#ok<AGROW>
                end
                dcmInfo_arr(found) = inInfo; %#ok<AGROW>

                %fix for unscaled data (old broken ICE program)
                if (fix_unscaled_data)
                    if (abs(inFid(1)) < 1e-2)
                        adj = 131072*256/mrprot.lAverages;
                        inFid = complex(real(inFid)*adj,imag(inFid)*-adj);
                    end
                end

                fid(:,found) = inFid;
            end
        end
    end
end

% truncate array if necessary
fid = fid(:,1:found);

if (found > 0)
    fprintf('\nspec_read_all: loaded %d traces\n',found)
else
    error('ERROR: no spectra found!')
end

if (found > 1)
    if (sortmethod == 1)
        fprintf('spec_read_all: sorting spectra by InstanceNumber\n');
        inst = ones(1,found,'uint16');
        for x=1:found
            inst(x) = dcmInfo_arr(x).InstanceNumber;
        end
        if (~isequal(sort(inst), uint16(1:found)))
            error('Invalid sort parameters: InstanceNumber');
        end
        fid(:,inst) = fid;
    elseif (sortmethod)
        error('ERROR: invalid sort method specified!');
    else
        fprintf('spec_read_all: spectra sorted in filename order\n');
    end

end
