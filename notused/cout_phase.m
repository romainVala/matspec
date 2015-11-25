function c=cout_phase(param)

global spec_total fid_metab ppm_center SW_p zero_filling pas_temps
global c

f_inf=1.9; % lower bound for the fit, in ppm
f_sup=3.5; % upper bound for the fit, in ppm

i_f_inf=round(-(f_sup-ppm_center)*zero_filling/SW_p+zero_filling/2)+1;
i_f_sup=round(-(f_inf-ppm_center)*zero_filling/SW_p+zero_filling/2);

phi=param;

fid_p=exp(1i*phi)*fid_metab;

spec=fftshift(fft(fid_p));
        
c=[real(spec(i_f_inf:i_f_sup)-spec_total(i_f_inf:i_f_sup)) imag(spec(i_f_inf:i_f_sup)-spec_total(i_f_inf:i_f_sup))];
