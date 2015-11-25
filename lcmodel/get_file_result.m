function [conc]=get_result(file_sel,waterref)

%for 3T data
RESONANCE_FREQ = 123.25; 
%for 7T data
RESONANCE_FREQ = 296.5917; 

if ~exist('waterref')
  waterref=0;
end

root_dir=pwd;

dir_sel=get_parent_path(file_sel);

for npool = 1:length(dir_sel)
  
  %  aa = get_subdir_regex_files(dir_sel{npool},'.*\.COORD');
  F = cellstr(file_sel{npool});
%  F = cellstr(aa{1});
  
 if isempty(dir([dir_sel{npool},'*.RAW']) )
    preproc_subdir=1; %result are in a preproc subdir
  else
    preproc_subdir=0;
  end
  
  [p,f] = fileparts(dir_sel{npool});
  [p,f] = fileparts(p);
  if preproc_subdir, [p,f] = fileparts(p);end

  concpool.pool=f;

  for k = 1:length(F)
    
    result(k) = readcoord(F{k});
  
    %find the watter ref
    if waterref
  
      f=get_coresponding_water_ref(F{k});
      wc = get_coresponding_water_content(F{k});
    end

  
    concpool.suj{k} = result(k).name;

    for kk=1:length(result(k).metabconc)
      nn = result(k).metabconc(kk).name;
      ind = findstr(nn,'+');
      if ~isempty(ind) 
	if ind==1, nn(ind)='';      else   nn(ind) = '_';      end 
      end
 
      ind = findstr(nn,'-');
      if ~isempty(ind) 
	if ind==1, nn(ind)='';      else   nn(ind) = '_';      end 
      end

      nnSD = ['SD',nn];
      
      if isfield(concpool,nn)
	ccc   = getfield(concpool,nn);
	cccSD = getfield(concpool,nnSD);
      else
	ccc = [];
	cccSD = [];
      end
      
      ccc(end+1)   = result(k).metabconc(kk).relconc;
      cccSD(end+1) = result(k).metabconc(kk).SD;
      concpool = setfield(concpool,nn,ccc);
      concpool = setfield(concpool,nnSD,cccSD);
      
    end
    
    concpool.suj{k} = result(k).name;
    
    concpool.phase_cor(k) = result(k).phase_cor;
    concpool.phase1_cor(k) = result(k).phase1_cor;

    concpool.linewidth(k) = result(k).linewidth * RESONANCE_FREQ;    
 
    concpool.SN(k) = result(k).SN;    
    concpool.freq_shift(k) = result(k).data_shift;
    
    if waterref
      concpool.suj_age{k} = f.patient_age;
      concpool.water_phase(k) = f.wat_phase;
      concpool.water_width(k) = f.water_width;

    end
    if exist('wc')
      concpool.fgray(k)  = wc(2);
      concpool.fwhite(k) = wc(3);
      concpool.fcsf(k)   = wc(4);
    end
  
  end
  conc(npool) = concpool;
  
  clear concpool;

  if 1
    ff=fieldnames(conc);
    concpool=conc(1);
    for k=1:length(ff)
      concpool=setfield(concpool,ff{k},[]);
    end
  end
  
end

