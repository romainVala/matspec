function c=cout_nu(param)

global spec_total fid_metab ppm_center SW_p zero_filling pas_temps
global c

f_inf=1.9; % lower bound for the fit, in ppm
f_sup=3.5; % upper bound for the fit, in ppm

i_f_inf=round(-(f_sup-ppm_center)*zero_filling/SW_p+zero_filling/2)+1;
i_f_sup=round(-(f_inf-ppm_center)*zero_filling/SW_p+zero_filling/2);

lb=4;

factor=param(1);
delta_nu=param(2);

k=(1:1:zero_filling);

correction(k)=factor*exp((2*pi*1i*delta_nu-lb)*(k-1)*pas_temps);

fid_shift=fid_metab.*correction;

spec_shift=fftshift(fft(fid_shift));

c=[abs(spec_shift(i_f_inf:i_f_sup))-abs(spec_total(i_f_inf:i_f_sup))];
