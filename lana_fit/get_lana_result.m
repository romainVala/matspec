function conc = get_lana_result(dir_sel)

if ~exist('dir_sel')
  dir_sel = spm_select(inf,'dir','select a dirs to get result from','',pwd)
 % s=get_subdir_regex('PROTO_SPECTRO_DYST/LCmodel/Raw',{'pat','control','suj'});
 % dir_sel=get_subdir_regex(s,'basis_MEGA_edit_MM_Gln$');
 dir_sel=cellstr(dir_sel);
 
end

for npool = 1:length(dir_sel)
  [p,f] = fileparts(dir_sel{npool});
  [p,f] = fileparts(p);

  concpool.pool=f;

  aa = get_subdir_regex_files(dir_sel{npool},'.*_E.\.txt');
  F = cellstr(aa{1});
  
  for ns=1:length(F)
    [p,f] = fileparts(F{ns});

    concpool.suj{ns} = f(6:end);
    
    ff=fopen(F{ns});
    l=fgetl(ff); %conc name alway naa glu gaba glut
    
    l=fgetl(ff);    a=str2num(l);
    concpool.naa(ns)  = a(1);
    concpool.glu(ns)  = a(2);
    concpool.gaba(ns) = a(3);
    concpool.gln(ns)  = a(4);
    concpool.glugln(ns)  = a(2)+a(4);
    
    l=fgetl(ff);    a=str2num(l);
    concpool.T2naa(ns)  = 1/a(1);
    concpool.T2glu(ns)  = 1/a(2);
    concpool.T2gaba(ns) = 1/a(3);
    concpool.T2gln(ns)  = 1/a(4);
 
    l=fgetl(ff);    a=str2num(l);
    concpool.phase(ns)  = a(1);

    l=fgetl(ff);    a=str2num(l);
    concpool.factor(ns)  = a(1);

    fclose(ff);
    
    %same thing with the _MM.txt file
    Fmm = fullfile(p,[f,'_MM.txt']);
  
    ff=fopen(Fmm);
    l=fgetl(ff); %conc name alway naa glu gaba glut
    
    l=fgetl(ff);    a=str2num(l);
    concpool.MMnaa(ns)  = a(1);
    concpool.MMglu(ns)  = a(2);
    concpool.MMgaba(ns) = a(3);
    concpool.MMgln(ns)  = a(4);
    concpool.MMglugln(ns)  = a(2)+a(4);
    concpool.water(ns)  = a(5);

    l=fgetl(ff);    a=str2num(l);
    concpool.MMT2naa(ns)  = 1/a(1);
    concpool.MMT2glu(ns)  = 1/a(2);
    concpool.MMT2gaba(ns) = 1/a(3);
    concpool.MMT2gln(ns)  = 1/a(4);
    concpool.T2water(ns)  = 1/a(5);
 
    l=fgetl(ff);    a=str2num(l);
    concpool.MMphase(ns)  = a(1);

    l=fgetl(ff);    a=str2num(l);
    concpool.MMfactor(ns)  = a(1);

    fclose(ff);
  
  end

  conc(npool) = concpool;
  clear concpool;

end
