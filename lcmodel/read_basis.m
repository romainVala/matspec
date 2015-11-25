function FF = read_basis(filename)

if ~exist('filename')
  filename = spm_select([1 inf],'any','select files','',pwd)
end

for k =1:size(filename,1)

  [p f e]=fileparts(filename(k,:))
  
  file_in = fullfile(p,[f,'.IN']);
  
  if exist(file_in)
    fp = fopen(file_in)
    
    s='qsdf';
    while ~isempty(s)
      s=fscanf(fp,'%s',1);
      if findstr('=',s) 
	try
	  eval(s)
	end
	
      end
    end
    fid(k).spectrum.cenfreq =  HZPPPM;
    fid(k).spectrum.np  =  NUNFIL;
    fid(k).spectrum.dw = DELTAT;

    fclose(fp)
    
    fp = fopen(filename(k,:));

  else
    %arggg
    fp = fopen(filename(k,:));

    %fid(k).spectrum.cenfreq =  find_float_2after('HZPPPM',fp);
    %fid(k).spectrum.dw = find_float_2after('BADELT',fp);
    %fid(k).spectrum.np  = find_float_2after('NDATAB',fp)/2;

try
fff
    fid(k).spectrum.cenfreq =  find_float_after('HZPPPM=',fp);
    fid(k).spectrum.np  = find_float_after('NDATA=',fp)/2;
    fid(k).spectrum.dw = find_float_after('DELTAT==',fp);
catch
    fid(k).spectrum.cenfreq =  find_float_after('HZPPPM=',fp);
    fid(k).spectrum.dw = find_float_after('BADELT=',fp);
    fid(k).spectrum.np  = find_float_after('NDATAB=',fp);


end

  end
  
    fid(k).spectrum.spectral_widht = 1/fid(k).spectrum.dw;
    fid(k).spectrum.n_data_points = fid(k).spectrum.np;
    fid(k).spectrum.synthesizer_frequency = fid(k).spectrum.cenfreq;
    fid(k).spectrum.FreqAt0 = fid(k).spectrum.spectral_widht/2;
    fid(k).spectrum.SW_h = fid(k).spectrum.spectral_widht ;
    fid(k).spectrum.SW_p = fid(k).spectrum.SW_h/fid(k).spectrum.cenfreq 
    fid(k).spectrum.ppm_center = 4.7;
    
    fid(k).seqname = 'lcBASIS';
    fid(k).Serie_description = 'lcBASIS';
  
  go_after('$BASIS',fp)
  
  d=dir(filename(k,:));
  
nbspec=1;
  while ftell(fp)<d.bytes -10

    go_after('$BASIS',fp)
    so=go_after2('METABO',fp)
    go_after('$END',fp)

    s=fscanf(fp,'%f');

    fid(k).fid = complex(s(1:2:end),s(2:2:end));  

    FF(nbspec) = fid;
    
    figure; plot(real(fid(k).fid))
    title(so)
    nbspec=nbspec+1;
  end  
  
  fclose(fp);

  
end

function go_after(str,fileid)
s=[];
while isempty(findstr(s,str))
    s=fscanf(fileid,'%s',1);
    s=upper(s);
end




function so=go_after2(str,fileid)
s=[];
so='';
while 1
    s=fscanf(fileid,'%s',1);
    s=upper(s);

    
    if (findstr(s,str))
      ind = findstr('=',s)
      if ind
	so = s(ind+1:end);
      else
	s=fscanf(fileid,'%s',1);
	so=fscanf(fileid,'%s',1);
      end
      break
    end
    
end

function f=find_float_2after(str,fileid)

c=[];
while isempty(findstr(c,str))
  c=fscanf(fileid,'%s',1);
  c=upper(c);
end

c=fscanf(fileid,'%s',1);

%read the float value
f = fscanf(fileid,'%f',1);



function f=find_float_after(str,fileid)

c=[];
while isempty( strfind(c,str))
  c=fscanf(fileid,'%s',1);
  c=upper(c);
end
cc=c;
c(1:length(str))='';

if isempty(c)
  %read the float value
  f = fscanf(fileid,'%f',1);
else
  f = str2num(c);
end

