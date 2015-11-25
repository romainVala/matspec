function fids = import_dangerplot(ffi)

if ~exist('ffi')
    ffi = get_subdir_regex_files();
end

% if ~exist('fi')
%   P = spm_select([1 Inf],'dir','Select directories where dangerplot files are stored')
%
%   fi = get_subdir_regex_files(P,'.*\.dpt$');
%   fi = cellstr(char(fi));
% end
%
%
% if iscell(fi)
%
%     for kk=1:length(fi)
%         fid(kk) = import_dangerplot(fi{kk});
%     end
%
%     return
% end


%[FileName,PathName] = uigetfile('*');

for nbf = 1:length(ffi)
    fi = ffi{nbf};
    [PathName,FileName] = fileparts(fi);
    
    dpt_file=fopen(fi,'r');
    
    [pp sername] = fileparts(PathName);
    
    read_fid=0;
    fprintf('Reading parameters...\n');
    while read_fid==0 ;
        line=fgetl(dpt_file);
        
        if strfind(line,'Real_FID')
            read_fid=1;
            
        elseif strfind(line,'Number_of_points')
            nbpts = str2num(line(17:end));
            
        elseif strfind(line,'Sampling_frequency')
            sfreq = str2num(line(19:end));
            
        elseif strfind(line,'Transmitter_frequency')
            tfreq = str2num(line(22:end));
            
        elseif strfind(line,'Echo_time')
            TE = str2num(line(10:end));
            
        elseif strfind(line,'Phi0')
            Phi0 = str2num(line(5:end));
            
        end
    end
    
    nn=1;
    line = fgetl(dpt_file);
    
    while ischar(line)
        aa = str2num(line);
        fidc(nn) = complex(aa(1),aa(2));
        nn=nn+1;
        line = fgetl(dpt_file);
    end
    
    
    fid.spectrum.cenfreq = tfreq*1E-6;
    fid.spectrum.np  = nbpts;
    fid.spectrum.spectral_widht = sfreq;
    fid.spectrum.dw = 1/fid.spectrum.spectral_widht;
    
    fid.spectrum.n_data_points = fid.spectrum.np;
    fid.spectrum.synthesizer_frequency = fid.spectrum.cenfreq;
    fid.spectrum.FreqAt0 = fid.spectrum.spectral_widht/2;
    fid.spectrum.SW_h = fid.spectrum.spectral_widht ;
    fid.spectrum.SW_p = fid.spectrum.SW_h/fid.spectrum.cenfreq
    fid.spectrum.ppm_center = 4.7;
    fid.spectrum.Nex = '?';
    fid.TE = TE;
    fid.TR = '?';
    
    fid.fid = transpose(fidc);
    fid.seqname ='?';
    fid.Serie_description= [ sername ];
    fid.SerDescr=fid.Serie_description;
    fid.sujet_name = 'tt';
    fid.examnumber = 1;
    fid.vapor_ws=1;
    fid.mega_ws=0;
    fids(nbf) = fid;
    
end

%transform to mega acquisition
kk=1;
for nbf=1:2:length(fids)
    fo(kk) = fids(nbf);
    
    fo(kk).fid = [fids(nbf).fid , fids(nbf+1).fid];
    fo(kk).seqname = 'megapress';
    kk = kk + 1;
end

fids = fo;