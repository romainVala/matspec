function [fid_cor phase_cor freq_cor] = correct_freq_and_phase_by_max(FID_in,par,info)

SW_h =info.spectrum.SW_h;
SW_p =info.spectrum.SW_p;
ppm_center =info.spectrum.ppm_center;

NS=size(FID_in,1);
%zero_filling=size(FID_in,2);
nb_pts_orig = size(FID_in,2);

pas_temps=1/SW_h;	% pas (en s) entre 2 points complexes successifs;

% apply LB and ZF
dw = 1/SW_h; t = [0:dw:dw*(length(FID_in)-1)];
LB = 5;
GF = 0.15;
sifactor = 10;

[nt,np]=size(FID_in);
fidzf = complex(zeros(nt,np*(sifactor+1)));
fid_cor = complex(zeros(nt,np));

for jcal=1:nt
    fidzf(jcal,:) = [FID_in(jcal,:).*exp(-t*pi*LB-t.^2/(GF^2))  zeros(1,np*sifactor)];
end

zero_filling=size(fidzf,2);


[f_METAB_inf,f_METAB_sup,f_METAB_ref] = get_peak_bound(par);


i_f_METAB_inf=round(-(f_METAB_sup-ppm_center)*(zero_filling-1)/SW_p+(zero_filling-1)/2)+1;
i_f_METAB_sup=round(-(f_METAB_inf-ppm_center)*(zero_filling-1)/SW_p+(zero_filling-1)/2);
i_METAB_ref=(-(f_METAB_ref-ppm_center)*(zero_filling-1)/SW_p+(zero_filling-1)/2)+1;


fprintf('Adding scans: processing (be patient...)\n');

%h = waitbar(0,'Adding, please wait...');

spec_total=zeros(1,nb_pts_orig);
SUM=zeros(1,nb_pts_orig);

for scan=1:NS
    
    fid_metab=squeeze(FID_in(scan,:));
    spec_metab=fftshift(fft(fid_metab));
    spec_total=spec_total+spec_metab;
    
end

spec_total=spec_total/NS;
freq_cor=zeros(NS,1);
phase_cor=zeros(NS,1);

for scan=1:NS
    
    fid_metab=squeeze(FID_in(scan,:));
    
    if (par.mean_line_broadening)
        %t=[0:pas_temps:(zero_filling-1)*pas_temps];
        %fid_metab_lb = fid_metab .* exp(-t*pi*par.mean_line_broadening); %bof .*exp(-t/0.15);
        fid_metab_lb = fidzf(scan,:);
    else
        fid_metab_lb = fid_metab;
        i_f_METAB_inf=round(-(f_METAB_sup-ppm_center)*(nb_pts_orig-1)/SW_p+(nb_pts_orig-1)/2)+1;
        i_f_METAB_sup=round(-(f_METAB_inf-ppm_center)*(nb_pts_orig-1)/SW_p+(nb_pts_orig-1)/2);
        i_METAB_ref=(-(f_METAB_ref-ppm_center)*(nb_pts_orig-1)/SW_p+(nb_pts_orig-1)/2)+1;
        
    end
    
    
    spec_metab=fftshift(fft(fid_metab_lb));
    
    %% Freq correction
    if par.do_freq_cor
        
        switch par.correct_freq_mod
            case 'real'
                [Cre_mag Cre_freq]=max(real(spec_metab(i_f_METAB_inf:i_f_METAB_sup)));
            case 'abs'
                [Cre_mag Cre_freq]=max(abs(spec_metab(i_f_METAB_inf:i_f_METAB_sup)));
        end
        
        %rrr
        if Cre_freq == 1% | Cre_freq >= (i_f_METAB_sup - i_f_METAB_inf +1)
            
            %	  [Cre_mag Cre_freq]=max(abs(spec_metab((i_f_METAB_inf-20):i_f_METAB_sup)));
            %	  delta_nu = (Cre_freq + i_f_METAB_inf -20 - i_METAB_ref)/zero_filling*SW_h;
            
            figure
            plot(real(spec_metab))
            hold on
            plot([i_f_METAB_inf:i_f_METAB_sup],real(spec_metab(i_f_METAB_inf:i_f_METAB_sup)),'r')
            
            %	  figure
            %	   plot(abs(spec_metab))
            %	   hold on
            %	   plot([i_f_METAB_inf:i_f_METAB_sup],abs(spec_metab(i_f_METAB_inf:i_f_METAB_sup)),'r')
            
            if par.stop_if_warning
                error('reaching min peak bound when searching Cre Peack for %s %s %s scan %d',info.sujet_name,info.examnumber,info.SerDescr,scan);
            else
                warning('reaching min peak bound (freq cor) for %s %s %s scan %d',info.sujet_name,info.examnumber,info.SerDescr,scan);
            end
            if ~exist('delta_nu')
                delta_nu=0;
            end
            
        elseif Cre_freq >= i_f_METAB_sup - i_f_METAB_inf - 1
            if par.stop_if_warning
                error('reaching max peak bound when searching Cre Peack for %s %s %s scan %d',info.sujet_name,info.examnumber,info.SerDescr,scan);
            else
                warning('reaching MAX peak bound (freq cor) for %s %s %s scan %d',info.sujet_name,info.examnumber,info.SerDescr,scan);
            end
            
            figure
            plot(real(spec_metab))
            hold on
            plot([i_f_METAB_inf:i_f_METAB_sup],real(spec_metab(i_f_METAB_inf:i_f_METAB_sup)),'g')
            
            
            
        else
            %delta_nu= (Cre_freq-2 + i_f_METAB_inf - i_METAB_ref)/(zero_filling-1)*SW_h;
            %argg I finally change the 2 in 1 because i_METAB_ref=i_METAB_ref+1 (matlab	indexes)
            
            delta_nu= (Cre_freq-1 + i_f_METAB_inf - i_METAB_ref)/(zero_filling-1)*SW_h;
            posmax = Cre_freq + i_f_METAB_inf-1; %matlab indix starting at 1
            
            %	  posppm = 4.7-(posmax-1-(zero_filling-1)/2)*SW_p/(zero_filling-1) ;
            %	  shiftppm = f_METAB_ref -posppm;
        end
        
        k=(1:1:nb_pts_orig);
        
        correction=exp(-2*pi*1i*delta_nu*(k-1)*pas_temps);
        
        fid_metab=fid_metab.*correction;
        
        if (par.mean_line_broadening)
            t=[0:pas_temps:(nb_pts_orig-1)*pas_temps];
            fid_metab_lb = fid_metab;% .* exp(-t*pi*par.mean_line_broadening);
        else
            fid_metab_lb = fid_metab;
        end
        
        freq_cor(scan) = delta_nu;
        
        spec_metab=fftshift(fft(fid_metab_lb));
        
        
        %  else
    end
    
    if par.do_phase_cor
        %% Phase correction
        %do not use the zero filling spectra
        i_METAB_ref_orig=(-(f_METAB_ref-ppm_center)*(nb_pts_orig-1)/SW_p+(nb_pts_orig-1)/2)+1;
        
        %    phi=mean(angle(spec_metab(floor(i_METAB_ref_orig):ceil(i_METAB_ref_orig))));
        phi = ((ceil(i_METAB_ref_orig)-i_METAB_ref_orig)*angle(spec_metab(floor(i_METAB_ref_orig))) + (i_METAB_ref_orig - floor(i_METAB_ref_orig))*angle(spec_metab(ceil(i_METAB_ref_orig))) )/2;
        
        %    phi = angle(spec_metab(round(i_METAB_ref)))
        %	phi=mean(angle(spec_metab(i_f_METAB_inf:i_f_METAB_sup)));
        
        
        
        %AAAAAAAAr changement de signe c'est plus un -phi   rrr le 25/03/09
        fid_metab=exp(-1i*phi)*fid_metab;
        
        phase_cor(scan) = phi;
        
    end
    
    SUM=SUM+fid_metab;
    
    fid_cor(scan,:) = fid_metab;
    
    %  waitbar(scan/NS);
end

freq_cor(end+1) = (i_f_METAB_inf - i_METAB_ref+1)/(zero_filling-1)*SW_h;
freq_cor(end+1) = (i_f_METAB_sup - i_METAB_ref)/(zero_filling-1)*SW_h;


SUM=SUM/NS;


%close(h);

fprintf('Adding scans: OK\n');


if par.figure
    f=figure;  figure(f);
    subplot(3,1,1)
    hold on;
    plot(real(spec_total));
    plot(real(fftshift(fft(SUM))),'r');
    title([info.sujet_name,'_',info.SerDescr])
    
    subplot(3,1,2)
    plot(freq_cor(1:end-2))
    hold on
    %plot([1 length(freq_cor)-2],[freq_cor(end-1),freq_cor(end-1)],'r')
    %plot([1 length(freq_cor)-2],[freq_cor(end),freq_cor(end)],'r')
    
    title([info.sujet_name,'_',info.SerDescr])
    
    subplot(3,1,3)
    plot(phase_cor)
end
