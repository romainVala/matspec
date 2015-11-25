function [Vect_ppm47 spectre_edc spectre_refscan signal]=import_fid_spectro

%function [Vect_ppm47 spectre_edc spectre_refscan signal spectre_edc_all spectre_all]=import_fid_spectro
[FileName,PathName] = uigetfile('*');
tic
pt_file=fopen([PathName FileName],'r');
pt_method=fopen([PathName 'method'],'r');
pt_acqp=fopen([PathName 'acqp'],'r');
pt_refscan=fopen([PathName 'fid.refscan'],'r');
pt_fidorig=fopen([PathName 'fid.orig'],'r');
 pt_fidraw=fopen([PathName 'fid.raw'],'r');
flag_method=0;
flag_acqp=0;

fprintf('Reading parameters...\n');
while flag_method==0 ;
    line=fgetl(pt_method);
    if strmatch('##$PVM_SpecMatrix=( 1 )',line);
        line=fgetl(pt_method);
        Mtx=str2num(line);
        
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

a=fread(pt_file,'int32');
b=fread(pt_fidorig,'int32');
ref=fread(pt_refscan,'int32');
c=fread(pt_fidraw,'int32');
signal=complex(a(1:2:end),a(2:2:end));
signal_orig=complex(b(1:2:end),b(2:2:end));
signal_all=complex(c(1:2:end),c(2:2:end));
refscan=complex(ref(1:2:end),ref(2:2:end));
offset=68;
 for i=1:NA
 spectre_all(:,i)=signal_all(Mtx*(i-1)+(offset+1):Mtx*i);
 spectre_edc_all(:,i)=real(fftshift(fft(spectre_all(:,i)./exp(1i*angle(refscan(offset+1:end))))));
 end
spectre_refscan=fftshift(abs(fft(refscan(offset+1:end))));
spectre_edc=real(fftshift(fft(signal_orig(offset+1:end)./exp(1i*angle(refscan(offset+1:end))))));
spectre_edc_Bruker=real(fftshift(fft(signal(offset+1:end))));

Vect_ppm=-SWppm/2:1/(Mtx-offset)*SWppm:SWppm/2-1/(Mtx-offset)*SWppm;
Vect_ppm47=Vect_ppm+4.7;
figure,
subplot(2,1,1)
plot(Vect_ppm47,spectre_edc_Bruker);
plot(Vect_ppm47,sum(spectre_edc_all,2));
set(gca,'XDir','reverse')
title('Spectrum Eddy Current corrected Bruker');
xlabel('ppm');
subplot(2,1,2)
plot(Vect_ppm47,spectre_edc);
set(gca,'XDir','reverse')
title('Spectrum Eddy Current corrected Mathieu');
xlabel('ppm');

keyboard
toc

