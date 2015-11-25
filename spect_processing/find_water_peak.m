
function wat_ppm = find_watter_peack(fids,spec_info)


f_inf=4.6; % lower bound in ppm
f_sup=4.8; % upper bound in ppm

for nbser = 1:length(fids)

  fid= fids{nbser}(:,1);
  info = spec_info{nbser};
  spec = info.spectrum;
  
  spec_metab=abs(fftshift(fft(fid)));

  ppm_center = spec.ppm_center;
  zero_filling = spec.np;
  SW_p = spec.SW_p;
  SW_h=spec.SW_h;
  
  i_f_inf=round(-(f_sup-ppm_center)*zero_filling/SW_p+zero_filling/2)+1;
  i_f_sup=round(-(f_inf-ppm_center)*zero_filling/SW_p+zero_filling/2);

  
  [v,ind_max] = max(spec_metab(i_f_inf:i_f_sup));
  ind_max = ind_max+i_f_inf-1;
  
  resolution1 = spec.spectral_widht/(spec.n_data_points-1)/spec.synthesizer_frequency;
  freqat0ppm1 = spec.FreqAt0/spec.synthesizer_frequency+4.7;
  Fppm = freqat0ppm1:-resolution1:freqat0ppm1-(spec.n_data_points-1)*resolution1;
  
  wat_ppm(nbser) = Fppm(ind_max);% ppm_center - (ind_max-zero_filling/2) *SW_p/zero_filling;

end