%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Freq + Phase correction + sum of an array of FIDs  %%%%%%%%%%%%%
%%%%		JV    13/12/04                                 %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SUM=add_array_scans(DATA,SW_h,SW_p,ppm_center)

NS=size(DATA,1);
zero_filling=size(DATA,2);

pas_temps=1/SW_h;	% pas (en s) entre 2 points complexes successifs;

f_inf=1.8; % lower bound for the NAA peak, in ppm
f_sup=2.2; % upper bound for the NAA peak, in ppm
f_NAA_ref=2.01;   % reference NAA frequency for frequency and phase correction


f_inf2=2.9; % lower bound for the Cre peak, in ppm
f_sup2=3.1; % upper bound for the Cre peak, in ppm
f_Cre_ref=3.02;

f_inf3=1.9; % lower bound for zero-phasing the SUM, in ppm
f_sup3=4; % upper bound for zero-phasing the SUM, in ppm

i_f_inf=round(-(f_sup-ppm_center)*zero_filling/SW_p+zero_filling/2)+1;
i_f_sup=round(-(f_inf-ppm_center)*zero_filling/SW_p+zero_filling/2);

i_f_inf2=round(-(f_sup2-ppm_center)*zero_filling/SW_p+zero_filling/2)+1;
i_f_sup2=round(-(f_inf2-ppm_center)*zero_filling/SW_p+zero_filling/2);

i_f_inf3=round(-(f_sup3-ppm_center)*zero_filling/SW_p+zero_filling/2)+1;
i_f_sup3=round(-(f_inf3-ppm_center)*zero_filling/SW_p+zero_filling/2);

i_NAA_ref=round(-(f_NAA_ref-ppm_center)*zero_filling/SW_p+zero_filling/2);
i_Cre_ref=round(-(f_Cre_ref-ppm_center)*zero_filling/SW_p+zero_filling/2);

fprintf('Adding scans: processing (be patient...)\n');

h = waitbar(0,'Adding, please wait...');
count=0;

spec_total=zeros(1,zero_filling);
SUM=zeros(1,zero_filling);

for scan=1:NS
    
	fid_metab=squeeze(DATA(scan,:));
            
	spec_metab=fftshift(fft(fid_metab));
    
	spec_total=spec_total+spec_metab;
    
end

spec_total=spec_total/NS;

for scan=1:NS
    
	fid_metab=squeeze(DATA(scan,:));
    
    %% Freq correction
           
        spec_metab=fftshift(fft(fid_metab));
    
        [NAA_mag NAA_freq]=max(abs(spec_metab(i_f_inf:i_f_sup)));
    
	[Cre_mag Cre_freq]=max(abs(spec_metab(i_f_inf2:i_f_sup2)));

	delta_nu=mean([(NAA_freq+i_f_inf-i_NAA_ref)/zero_filling*SW_h (Cre_freq+i_f_inf2-i_Cre_ref)/zero_filling*SW_h]);

	k=(1:1:zero_filling);

	correction(k)=exp(-2*pi*1i*delta_nu*(k-1)*pas_temps);

	fid_metab=fid_metab.*correction;
                
	spec_metab=fftshift(fft(fid_metab));  
 
	%% Phase correction
    
	phi=mean(angle(spec_metab(i_NAA_ref:i_NAA_ref)));
    
	fid_metab=exp(-1i*phi)*fid_metab;
    
	SUM=SUM+fid_metab;
    
	count=count+1;      
	waitbar(count/NS);

end

SUM=SUM/NS;

spectrum_SUM=fftshift(fft(SUM));

phase_test=(-0.5:0.01:0.5);

integral_imag_0=abs(sum(imag(exp(1i*phase_test(1))*spectrum_SUM(i_f_inf3:i_f_sup3))));
phase_index=1;

for m=1:length(phase_test)
	integral_imag=abs(sum(imag(exp(1i*phase_test(m))*spectrum_SUM(i_f_inf3:i_f_sup3))));
	
	if integral_imag<integral_imag_0;
		phase_index=m;
	end
end
		
phase=phase_test(phase_index);

SUM=exp(1i*phase)*SUM;

close(h);

fprintf('Adding scans: OK\n');

f=figure;
figure(f);
hold on;
plot(real(spec_total),'r');
plot(real(fftshift(fft(SUM))));
