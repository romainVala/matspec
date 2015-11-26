function [fid_cor phase_cor Frequency_correction] = correct_freq_and_phase_by_correlation(fid,par,info)

global sw H1offset sfrq1H

sw = info.spectrum.SW_h;
sfrq1H = info.spectrum.synthesizer_frequency;
H1offset = info.spectrum.ppm_center;

% B0 correction using cross-correlation (based on Pat Bolan freqAlignXCorr.m)
maxshiftHz = 50;

% apply LB and ZF
dw = 1/sw; t = [0:dw:dw*(length(fid)-1)]';
LB = 5;
GF = 0.15;
sifactor = 10;

[np,nt]=size(fid);
fidzf = complex(zeros(np*(sifactor+1),nt));
fid_cor = complex(zeros(np,nt));

for jcal=1:nt
    fidzf(:,jcal) = [fid(:,jcal).*exp(-t*pi*LB-t.^2/(GF^2)); zeros(np*sifactor,1)];
end


%%%%%%%%%%%%%%%%%%%%%%%%
% FFT and mean
spectfft = fftshift(fft(fidzf,[],1),1);
spect_ref = abs(mean(spectfft,2));

%%%%%%%%%%%%%%%%%%%%%%%%
% Cross-correlation algorithm
fmax = (sw)/2;
f = [fmax:-2*fmax/(length(fidzf)-1):-fmax];
newSR = sw./length(spect_ref);
maxlags = round(maxshiftHz./newSR);
t1 = [0:dw:dw*(length(fidzf)-1)]';
FreqRef = 0;
count = 0;
Frequency_correction = zeros(nt);

if par.do_freq_cor
    
    for ix = 1:nt
        clear spect_use
        spect_use = abs(spectfft(:,ix));
        c = xcorr(spect_ref, spect_use, maxlags);
        
        % Determine frequency shift based on position of max signal
        [maxval,inx] = max(c);
        freqC(ix) = f(inx);
        
        % Frequency shift (in Hz) wrt to first data point
        if (ix==1)
            FreqRef = freqC(1);
        end
        Frequency_correction(ix) = freqC(ix) - FreqRef;
        
        % Correct FIDs with determined frequency shift
        fid_cor(:,ix) = fid(:,ix) .*exp(1i*2*pi*-Frequency_correction(ix)*t);
        %fid_corz(:,ix) = fidzf(:,ix).*exp(1i*2*pi*-Frequency_correction(ix)*t1);
    end
    
else
    fid_cor = fid;
end

spec_total = mean(fftshift(fft(fid_cor),1),2);

if par.do_phase_cor
for scan=1:nt
    
    fid_metab0=squeeze(fid_cor(:,scan));
    fid_metab=fid_metab0;
    
    %% Phase correction
    options=optimset('Display','Off');
    phi=lsqnonlin(@cout_phase,[0],[-pi],[pi],options,transpose(spec_total),transpose(fid_metab));
    %phi=lsqnonlin(@cout_phase,[0],[-pi],[pi],options,spec_total,fid_metab);
    fid_metab=exp(1i*phi).*fid_metab0;
    
    fid_cor(:,scan)=fid_metab;
    phase_cor(scan) = phi;
    %    SUM=SUM+fid_metab;
    
    %    count=count+1;
    %    waitbar(count/NS);
    
end
else
    phase_cor=zeros(1,nt);
end

%do a global freq
if par.correct_to_ref_metab
    
    %make the same lb and zero filling as for correlation
    for jcal=1:nt
        fidzf(:,jcal) = [fid_cor(:,jcal).*exp(-t*pi*LB-t.^2/(GF^2)); zeros(np*sifactor,1)];
    end
    
    %fidm = permute(mean(fid_cor,2),[2 1]);
    fidm = permute(mean(fidzf,2),[2 1]);
    
    ppp=par;ppp.figure=0;
    [summ2 fiddddcor phh fffreq ] = add_array_scans_bis_Cre(fidm,sw,sw/sfrq1H,H1offset,ppp,info);
    Frequency_correction = Frequency_correction + fffreq(1);
    for ix = 1:nt
        
        fid_cor(:,ix) = fid_cor(:,ix) .*exp(1i*2*pi*-fffreq(1)*t);
        
    end
end

if par.figure
    
    f1 = [fmax:-2*fmax/(length(fid)-1):-fmax];
    scale_ppm=f1/(sfrq1H)+H1offset;
    
    
    f=figure;  figure(f);
    subplot(3,1,1)
    
    spectfftori=real(fftshift(fft(fid),1));
    spectfftnew=real(fftshift(fft(fid_cor),1));
    
    hold on;
    plot(scale_ppm,mean(spectfftori,2));
    plot(scale_ppm,mean(spectfftnew,2),'r');
    title([info.sujet_name,'_',info.SerDescr])
    set(gca,'Xdir','reverse');
    subplot(3,1,2)
    plot(Frequency_correction)
    hold on
    %plot([1 length(freq_cor)-2],[freq_cor(end-1),freq_cor(end-1)],'r')
    %plot([1 length(freq_cor)-2],[freq_cor(end),freq_cor(end)],'r')
    
    title([info.sujet_name,'_',info.SerDescr])
    
    
    subplot(3,1,3)
    plot(phase_cor)
end


function c=cout_phase(param,spec_total,fid_metab)

%global spec_total fid_metab ppm_center SW_p zero_filling pas_temps
%global c
global sw H1offset sfrq1H

f_inf=1.9; % lower bound for the fit, in ppm
f_sup=3.5; % upper bound for the fit, in ppm

SW_p=sw/sfrq1H;
zero_filling=size(fid_metab,2);
i_f_inf=round(-(f_sup-H1offset)*zero_filling/SW_p+zero_filling/2)+1;
i_f_sup=round(-(f_inf-H1offset)*zero_filling/SW_p+zero_filling/2);

phi=param;

fid_p=exp(1i*phi)*fid_metab;

spec=fftshift(fft(fid_p));

c=[real(spec(i_f_inf:i_f_sup)-spec_total(i_f_inf:i_f_sup)) imag(spec(i_f_inf:i_f_sup)-spec_total(i_f_inf:i_f_sup))];

return
