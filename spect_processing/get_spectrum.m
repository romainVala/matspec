function s=get_spectrum(f)

for k=1%1:length(f)
  s =  fftshift(fft(f(k).fid),1);
end

if 0

aa=1:32:256;
az=(32:32:256 )

fid= f.fid;

for kk=1:length(aa)
  f(:,kk) = mean(fid(:,[aa(kk):az(kk)]),2);
end



  spec = f(1).spectrum;
  resolution1 = spec.spectral_widht/(spec.n_data_points-1)/spec.synthesizer_frequency;
  freqat0ppm1 = spec.FreqAt0/spec.synthesizer_frequency+spec.ppm_center;
  %Fppm =  freqat0ppm1:resolution1:freqat0ppm1+(spec.n_data_points-1)*resolution1;
  Fppm =  freqat0ppm1:-resolution1:freqat0ppm1-(spec.n_data_points-1)*resolution1;

  t=[0:spec.dw:(spec.np-1)*spec.dw]';
 
  param.mean_line_broadening = 2;

  
for k=1:length(f)
  
  fid=f(k).fid;
  ns = size(fid,2)/2;
  
  fid1 = fid(:,1:ns);
  fid2 = fid(:,(ns+1):end);

  fdiff = (fid2-fid1).* exp(-t*pi*param.mean_line_broadening);
  
  s(k,:) =  fftshift(fft(fdiff),1);
end



end