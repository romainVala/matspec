function [fid, dcmInfo_arr] = spec_read_all(dn)
% function to read spectroscopy time series data from a
% directory with sequentially named siemens .ima/.dcm files

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

fprintf('searching %s\nfound %d candidate filenames\n',dn,size(files,1))
if (size(files,1) < 1)
    error('ERROR: no files found')
end
fprintf('loading DICOM dictionary\n')
for x=1:size(files,1)
    if (found); fprintf('\b\b\b\b\b\b%-6d',x); end
    idx = sidx(x);
    if (~files(idx).isdir)
        tmp = files(idx).name;
        if (size(tmp,2) > 4)
            if ( strcmpi(tmp(end-3:end),ext) || strcmpi(tmp(end-3:end),ext3) || strcmpi(tmp(end-3:end),ext6) )
                found = found + 1;

                [inFid, inInfo] = spec_read(fullfile(dn,tmp));
                if (found == 1)     % first time through, preallocate arrays
                    fprintf('reading file 1     ')
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
    fprintf('\ndone: loaded %d traces\n',found)
else
    error('ERROR: no spectra found!')
end
