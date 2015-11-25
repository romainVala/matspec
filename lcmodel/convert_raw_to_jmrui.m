function [fid raw_data] = convert_raw_to_jmrui(filename)

if ~exist('filename')
  filename = spm_select([1 inf],'any','select files','',pwd);
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
  fid(k).spectrum.SW_p = fid(k).spectrum.SW_h/fid(k).spectrum.cenfreq ;
  fid(k).spectrum.ppm_center = 4.7;
%  fid(k).spectrum.ppm_center = 4.65;
    
  fid(k).seqname = 'lcRAW';
  fid(k).Serie_description = 'lcRAW';
  
  fclose(fp);
  
  
  ff = fopen(deblank(filename(k,:)));
  go_after('NMID',ff);
  go_after('END',ff);


  s=fscanf(ff,'%f');
  fid(k).fid = complex(s(1:2:end),s(2:2:end));

  fclose(ff);

  [p fid(k).sujet_name] = fileparts(filename(k,:));

  data=s;
  
  jmrui_f = fullfile(p,fid(k).sujet_name);
  rdb_file = [jmrui_f '.txt'];

  disp(sprintf('\n Writing rdb file: %s\n',rdb_file));
  fileid = fopen(rdb_file,'w');
  
  fprintf(fileid,'\nFile Name: %s\n',rdb_file);

  fprintf(fileid,'\nPointsInDataset: %d\n',fid(k).spectrum.np*2);
  fprintf(fileid,'DatasetsInFile: %d\n',size(fid(k).fid,2));
  fprintf(fileid,'SamplingInterval: %E\n',fid(k).spectrum.dw*1000);
  fprintf(fileid,'ZeroOrderPhase: 0\n');
  fprintf(fileid,'BeginTime: 0\n');
  fprintf(fileid,'TransmitterFrequency: %E\n',fid(k).spectrum.cenfreq*1E6);
  fprintf(fileid,'MagneticField: %E\n',fid(k).spectrum.cenfreq/42.576);
  fprintf(fileid,'TypeOfNucleus: Proton\n');
  fprintf(fileid,'NameOfPatient: %s\n', fid(k).sujet_name);
  fprintf(fileid,'DateOfExperiment: 2009.01.01 11:46:19 \n');
  fprintf(fileid,'Spectrometer: TrioTim \n');
  fprintf(fileid,'AdditionalInformation: %s\n\n\n', fid(k).Serie_description);
  fprintf(fileid,'Signal and FFT\n sig(real)\tsig(imag)\tfft(real)\tfft(imag)\n');
  fprintf(fileid,'Signal 1 out of 1 in file\n');

  the_fid = fid(k).fid;
  %  spec  = fftshift(fft(the_fid),1);
  spec  = fft(the_fid)*0;

  for kkk = 1:size(spec,1)
    fprintf(fileid,'%E\t%E\t%E\t%E\n',real(the_fid(kkk)),imag(the_fid(kkk)),real(spec(kkk)),imag(spec(kkk)));
  end
  
  fclose(fileid);
  
  if 0

  h_file=struct('npoints',0,'step',0,'bdelay',0,'fltrest1',zeros(1,10-3),'sfrq',0,'scans',0,'scale',0,'norm',1000,'fltrest2',zeros(1,64-10-4));

  np=size(data,1);
  h_file.npoints = np;
  h_file.step    = 1000./fid(k).spectrum.SW_h;
  h_file.bdelay  = [0] * h_file.step;
  h_file.sfrq = fid(k).spectrum.cenfreq * 1e6;
  h_file.scans = 1;
  h_file.scale = real(max(abs(data)));	


    bdata = reshape(data, 2, h_file.npoints/2, 1*1);   
    hrec = (64 * 4);
    bdrec = (h_file.npoints/2 * 4);	

    
    fwrite(fileid,hrec,'integer*4');
    fwrite(fileid,h_file.npoints,'real*4');
    fwrite(fileid,h_file.step,'real*4');
    fwrite(fileid,h_file.bdelay,'real*4');
    fwrite(fileid,h_file.fltrest1,'real*4');
    fwrite(fileid,h_file.sfrq,'real*4');
    fwrite(fileid,h_file.scans,'real*4');
    fwrite(fileid,h_file.scale,'real*4');
    fwrite(fileid,h_file.norm,'real*4');
    fwrite(fileid,h_file.fltrest2,'real*4');
    fwrite(fileid,hrec,'integer*4');
    fwrite(fileid,bdrec,'integer*4');
    fwrite(fileid,bdata(1,:),'real*4');
    fwrite(fileid,bdrec,'integer*4');
    fwrite(fileid,bdrec,'integer*4');
    fwrite(fileid,bdata(2,:),'real*4');
    fwrite(fileid,bdrec,'integer*4');
    fclose(fileid); 
  end
  
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

