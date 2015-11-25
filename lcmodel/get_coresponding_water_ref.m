function f= get_coresponding_water_ref(rawname)

if isstruct(rawname) % this is a matlab fid struc

  ff = rawname;
  
  name = ff.sujet_name;
  exam = ff.examnumber;
  if strcmp(exam,'E1'), exam='';else exam=['_',exam]; end;
  
  region = [nettoie_dir(ff.SerDescr) '_ref'];

  
  if ~isempty(findstr(ff.SubjectID,'DYSTON')) | ...
    ~isempty(findstr(ff.SubjectID,'yston')) | ...
    ~isempty(findstr(ff.SubjectID,'08.08.29-14:40')) 
    
    dicom_dir='/home/romain/data/spectro/PROTO_SPECTRO_DYST/Sujet_dicom/';
  
  elseif ~isempty(findstr(ff.SubjectID,'ourette')) 
     
    dicom_dir='/home/romain/data/spectro/tourette/sujet_dicom/';
     
    %region = ['PRESS_',region];
    
  else
    warning('do not find the study root dicom dir')
    keyboard
  end
  
  
else  %this is the lcmodel RAW file
  

  if findstr(rawname,'PROTO_SPECTRO_DYST')
    dicom_dir='/home/romain/data/spectro/PROTO_SPECTRO_DYST/Sujet_dicom/';
  elseif findstr(rawname,'/PROTO_U731_CERVELET_TM')
    dicom_dir='/home/romain/data/spectro/PROTO_U731_CERVELET_TMS/';
  elseif findstr(rawname,'PROTO_SCA')
    dicom_dir='/home/romain/data/spectro/PROTO_SCA/';
  elseif findstr(rawname,'tourette')
    dicom_dir='/home/romain/data/spectro/tourette/sujet_dicom/';
  else
    warning('do not find the study')
    keyboard
  end

  [p,f] = fileparts(rawname);

  ind=findstr('Sujet',f);
  
  name=f(1:ind+6);
  exam=f(ind+8:ind+9); if strcmp(exam,'E1'), exam='';else exam=['_',exam]; end;
  region = [f(ind+11:end),'_ref'];

  if strcmp(dicom_dir,'/home/romain/data/spectro/tourette/sujet_dicom/')
    ind=findstr(f,'_E1_');
    name = f(1:ind-1);
    exam='';
    region=['PRESS_' f(ind+4:end) '_ref'];
  end
  

end

dd = dir([dicom_dir,'*',name,exam]);
if length(dd)~=1
  fprintf('warning do not find subject \n');
  keyboard
end
  
dd = fullfile(dicom_dir,dd.name);
sdd = dir([dd,'/*',region]);
if length(sdd)~=1
  fprintf('warning do not find serie \n');
  keyboard
end

sdd= fullfile(dd,sdd.name);


f=explore_spectro_data(sdd);
fid = f.fid(:,1);
%rrr fid = exp(-1i*0.34)* fid;

spectrum_fid=fftshift(fft(fid));

%figure, plot(real(spectrum_fid))

ppm_center = 4.7;
  SW_p       = f.spectrum.SW_p;	% spectral width in ppm
  np         = f.spectrum.np;		% number of points


    f_inf3=1.7; 		% lower bound for zero-phasing the SUM, in ppm
    f_sup3=7.7; 		% upper bound for zero-phasing the SUM, in ppm
    i_f_inf3=round(-(f_sup3-ppm_center)*np/SW_p+np/2)+1;
    i_f_sup3=round(-(f_inf3-ppm_center)*np/SW_p+np/2);


phase_test=(-pi:0.05:pi);
for m=1:length(phase_test)
  fid_phase = exp(-1i*phase_test(m))*fid;
  spectrum_fid=fftshift(fft(fid_phase));

  integral_real(m) = sum(real(spectrum_fid(i_f_inf3:i_f_sup3)));
%  integral_imag(m) = sum(imag(exp(-1i*phase_test(m))*spectrum_fid));
end

f=get_water_width(f);

f.integral_abs = sum(abs(spectrum_fid));
[f.integral_real,ind] = max(integral_real);
f.wat_phase = phase_test(ind)/pi*180;

y=(log(abs(f.fid(11:50,1))))';
xx=0:f.spectrum.dw:f.spectrum.dw*100;
x=xx(11:50);

var_x = repmat ( sum((x-mean(x)).^2)/size(y,2), size(y,1),1);
cv=sum( repmat(x-mean(x),size(y,1),1) .* (y-repmat(mean(y,2),1,size(y,2)) ),2 )/size(y,2);

a=cv./var_x;

b=mean(y)-a*mean(x);

f.integral_abs = exp(b);