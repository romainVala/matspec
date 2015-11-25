function fo = adjust_phase_to_first(fi)

fo = fi;


zero_filling=size(fi(1).fid,1);
NS = size(fi(1).fid,2);
pas_temps=1/fi(1).spectrum.SW_h;	
ppm_center = fi(1).spectrum.ppm_center;
SW_p = fi(1).spectrum.SW_p;

f_METAB_ref = 0.9 ; 

i_METAB_ref=(-(f_METAB_ref-ppm_center)*(zero_filling-1)/SW_p+(zero_filling-1)/2)+1;

fid1 = mean(fi(1).fid(:,1:NS/2),2);
fid2 = mean(fi(1).fid(:,NS/2+1:end),2);

spec1  = fftshift(fft(fid1),1);
spec2  = fftshift(fft(fid2),1);

specdiff = spec2-spec1;

ref_phase =((ceil(i_METAB_ref)-i_METAB_ref)*angle(specdiff(floor(i_METAB_ref))) + (i_METAB_ref - floor(i_METAB_ref))*angle(specdiff(floor(i_METAB_ref))) )/2;


for k=2:length(fi)

  NS = size(fi(k).fid,2);

  fid_metab = fi(k).fid;
  
  fid1 = mean(fi(k).fid(:,1:NS/2),2);
  fid2 = mean(fi(k).fid(:,NS/2+1:end),2);

  spec1  = fftshift(fft(fid1),1);
  spec2  = fftshift(fft(fid2),1);
  
  specdiff = spec2-spec1;
  
  f_phase =((ceil(i_METAB_ref)-i_METAB_ref)*angle(specdiff(floor(i_METAB_ref))) + (i_METAB_ref - floor(i_METAB_ref))*angle(specdiff(ceil(i_METAB_ref))) )/2;

  phi(k) = ref_phase - f_phase;
  
  fo(k).fid = exp(1i*phi(k))*fid_metab;
  
end

figure
plot(-phi)
%keyboard