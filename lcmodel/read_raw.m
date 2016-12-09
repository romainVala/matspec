function [fid raw_data] = read_raw(filename)

if ~exist('filename')
  filename = spm_select([1 inf],'any','select files','',pwd)
end

for k =1:size(filename,1)

  [pathstr,fname,ext] = fileparts(filename(k,:));

  fp = fopen(fullfile(pathstr,[fname,'.PLOTIN']));

  fid(k).spectrum.cenfreq =  find_float_after('HZPPPM=',fp);
  fid(k).spectrum.np  = find_float_after('NUNFIL=',fp);
  fid(k).spectrum.dw = find_float_after('DELTAT=',fp);
  fid(k).spectrum.spectral_widht = 1/fid(k).spectrum.dw;
  fid(k).spectrum.n_data_points = fid(k).spectrum.np;
  fid(k).spectrum.synthesizer_frequency = fid(k).spectrum.cenfreq;
  fid(k).spectrum.FreqAt0 = fid(k).spectrum.spectral_widht/2;
  fid(k).spectrum.SW_h = fid(k).spectrum.spectral_widht ;
  fid(k).spectrum.SW_p = fid(k).spectrum.SW_h/fid(k).spectrum.cenfreq 
  fid(k).spectrum.ppm_center = 4.7;
  fid(k).spectrum.ppm_center = 4.65;
  fid(k).spectrum.ppm_center = 4.6518;
    
  fid(k).seqname = 'lcRAW';
  fid(k).Serie_description = 'lcRAW';
  
  fclose(fp);
  
  
  ff = fopen(deblank(filename(k,:)))
  go_after('NMID',ff)
  go_after('END',ff)


  s=fscanf(ff,'%f');
  fid(k).fid = complex(s(1:2:end),s(2:2:end));

  fclose(ff)

  [p fid(k).sujet_name] = fileparts(filename(k,:));

  raw_data=s;
end




function go_after(str,fileid)
s=[];
while isempty(findstr(s,str))
    s=fscanf(fileid,'%s',1);
end

function f=find_float_after(str,fileid)

c=[];
while isempty(findstr(c,str))
  c=fscanf(fileid,'%s',1);
end

c(1:length(str))='';

if isempty(c)
  %read the float value
  f = fscanf(fileid,'%f',1);
else
  f = str2num(c);
end

