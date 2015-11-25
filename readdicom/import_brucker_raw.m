function fid = import_brucker_raw(fi)

if ~exist('fi')
fi = get_subdir_regex;
end

if iscell(fi)

%ff = get_subdir_regex_files(fi,'fid$');
ff = get_subdir_regex_files(fi,'fid.raw$',1);

for kk=1:length(ff)
  fid(kk) = import_brucker_raw(ff{kk});
end

return
end

%[FileName,PathName] = uigetfile('*');
[PathName,FileName] = fileparts(fi);
tic
pt_file=fopen(fi,'r');
pt_method=fopen(fullfile(PathName,'method'),'r');
pt_acqp=fopen(fullfile(PathName,'acqp'),'r');
if exist(fullfile(PathName,'fid.refscan'))
    pt_refscan=fopen(fullfile(PathName,'fid.refscan'),'r');
else
    pt_refscan=0;
end
pt_suj = fopen(fullfile(PathName,'..','subject'));

[pp sername] = fileparts(PathName);

flag_method=0;
flag_acqp=0;
flag_suj=0;

fprintf('Reading parameters...\n');
while flag_method==0 ;
    line=fgetl(pt_method);
    if strmatch('##$PVM_SpecMatrix=( 1 )',line);
        line=fgetl(pt_method);
        Mtx=str2num(line);
        
    end
    if strmatch('##$Method=',line);
        Methstr=(strtok(line,'##$Method='));
    end
    if strmatch('##$PVM_EchoTime=',line);
        MethTE=str2num(strtok(line,'##$PVM_EchoTime='));
    end
    if strmatch('##$PVM_RepetitionTime=',line);
        MethTR=str2num(strtok(line,'##$PVM_RepetitionTime='));
    end
    if strmatch('##$PVM_NAverages=',line);
        NA=str2num(strtok(line,'##$PVM_NAverages='));
    end
    if strmatch('##$PVM_SpecSWH=( 1 )',line);
        line=fgetl(pt_method);
        SW=str2num(line);
    end
    if strmatch('##$PVM_SpecSW=( 1 )',line);
        line=fgetl(pt_method);
        SWppm=str2num(line);
    end
    if strmatch('##$PVM_EncNReceivers=',line);
        Nb_Receiver=str2num(strtok(line,'##$PVM_EncNReceivers='));
    end
    
    if strmatch('##END=',line)
        flag_method=1;
    end    
    
    if strmatch('##$PVM_VoxArrSize=',line)        
        VoxSize =  fscanf(pt_method,'%f',3);
        Pos.VoiFOV = VoxSize;
    end
    if strmatch('##$PVM_VoxArrGradOrient=',line)
        Orient = fscanf(pt_method,'%f',9);
        Pos.Voimat = reshape(Orient,[3 3]);
    end
     if strmatch('##$PVM_VoxArrPosition=',line)
         position = fscanf(pt_method,'%f',3);
         Pos.VoiPosition = position;
     end
%    if strmatch('##$PVM_VoxArrCSDisplacement=',line)
%        position = fscanf(pt_method,'%f',3);
%        Pos.VoiPosition = position;
%    end
end

while flag_acqp==0 ;
    line=fgetl(pt_acqp);
    if strmatch('##$BF1=',line);
        freq=str2num(strtok(line,'##$BF1='))*10^6;
    end   
    if strmatch('##END=',line)
        flag_acqp=1;
    end        
    
end

while flag_suj==0 ;
    line=fgetl(pt_suj);
    if strmatch('##$SUBJECT_id',line);
	line=fgetl(pt_suj);
	suj = line(2:end-1)
    end   
    if strmatch('##END=',line)
        flag_suj=1;
    end        
end

 fid.spectrum.cenfreq = freq*1E-6;
 fid.spectrum.np  = Mtx;
 fid.spectrum.spectral_widht = SW;
 fid.spectrum.dw = 1/fid.spectrum.spectral_widht;
 
 fid.spectrum.n_data_points = fid.spectrum.np;
 fid.spectrum.synthesizer_frequency = fid.spectrum.cenfreq;
 fid.spectrum.FreqAt0 = fid.spectrum.spectral_widht/2;
 fid.spectrum.SW_h = fid.spectrum.spectral_widht ;
 fid.spectrum.SW_p = fid.spectrum.SW_h/fid.spectrum.cenfreq 
 fid.spectrum.ppm_center = 4.7;
 fid.spectrum.Nex = NA;
 fid.Pos = Pos;
 fid.TE = MethTE;
 fid.TR = MethTR;
 
 
a=fread(pt_file,'int32');
if pt_refscan
    ref=fread(pt_refscan,'int32');
    %refscan=complex(ref(1:2:end),ref(2:2:end));
    refscan=complex(ref(2:2:end),ref(1:2:end));
end

%signal=complex(a(1:2:end),a(2:2:end));
signal=complex(a(2:2:end),a(1:2:end));

if length(signal)>fid.spectrum.np %this mean single scan are saved
    signal = reshape(signal,[fid.spectrum.np,fid.spectrum.Nex]);
end

%signal = signal*exp(-i*pi/2);


fid.fid = signal;
fid.seqname =sprintf('S%s_%s',sername,Methstr);
fid.Serie_description= ['S' sername Methstr];
fid.SerDescr=fid.Serie_description;
fid.sujet_name = suj;
fid.SubjectID = suj;
fid.examnumber = 'E1';
fid.ser_dir = sername;
fid.water_ref=fid;
fid = change_phase(fid,90);
fid = remove_first_points_fillup(fid,68);

if pt_refscan
    fprintf('doing eddycor')
    fid.water_ref.fid = refscan;
    fid.water_ref = change_phase(fid.water_ref,90);
    fid.water_ref = remove_first_points_fillup(fid.water_ref,68);    

    fid = eddycorrection(fid,fid.water_ref)

end
toc

