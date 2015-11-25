 %SELECTION des donnes

rootdir = '/home/romain/data/spectro/tourette/sujet_dicom';

rawdir = '/home/romain/data/spectro/tourette/lcmodel/mega_press';

control_wc = {'t$'};
patient_wc = {'p$'};
%control_wc = {'^2011_0[34].*t$'};
%patient_wc = {'^2011_0[34].*p$'};

group = {'control','patient'};
region_wc = {'press_MCL$','press_STR$','press_Thal$'};

%control_wc = {'2010_02_26_SL_Tourettespectro_106t','2010_04_01_SL_Tourettespectro_108t','2010_03_28_SL_Tourettespectro_107t'};

%patient_wc = {'2010_03_12_SL_Tourettespectro_96p','2010_03_19_SL_Tourettespectro_103p','2010_03_28_SL_Tourettespectro_104p','2010_03_28_SL_Tourettespectro_82p','2010_04_11_SL_Tourettespectro_109p'};

nb_sub_group = 1;

for nbg= 1:2
  if nbg==1
    s_dir = get_subdir_regex(rootdir,control_wc);
  else
    s_dir = get_subdir_regex(rootdir,patient_wc);
  end
  
  for nbr=1:length(region_wc)
    dd = get_subdir_regex(s_dir,region_wc(nbr));
  
    f = explore_spectro_data(char(dd));
  
    par.figure = 0;
    par.mean_line_broadening = 8;
    par.stop_if_warning=1;
  
    fc=f;
    fc(1).phase_cor = 0;    fc(1).freq_cor = 0;    

    for nbsuj=1:length(f)
      try
        fc(nbsuj) = processing_spec(f(nbsuj),par);
      catch
        fileid=fopen('doit_dysto_error.log','a+')
        fprintf(fileid,'PROBLEM with mega preprosseging forsuj %s %s region %s \n',f(nbsuj).sujet_name,group{nbg},region_wc{nbr});
	fclose(fileid);
      end
    end
    
%    fc=processing_spec(f,par)


    
    %%%Writing to LCmodel RAW files
    ff = remove_field_string(fc,'sujet_name',[1:14]);
    ff = remove_field_string(ff,'sujet_name','_E.$');
    
    group_name{1} = nettoie_dir( [ ff(1).SerDescr,'_',group{nbg}])
    
    %plot_spectrum(ff)
    %keyboard
    
    fall(nb_sub_group).group  =  average_fid(ff);
    fall(nb_sub_group).region = group_name{1};

    LC_dir = fullfile(rawdir,group_name{1});
    if ~exist(LC_dir),mkdir(LC_dir);end
      
    fall(nb_sub_group).lcdir  = LC_dir;

    for nsuj=1:length(fall(nb_sub_group).group)
      
      wref = get_coresponding_water_ref(fall(nb_sub_group).group(nsuj));
      parw.ref_metab='water';
      parw.figure = 0;

      wref = processing_spec(wref,parw);
      
      fall(nb_sub_group).group(nsuj).water_ref = wref;
      
    end

    pp=write_fid_to_lcRAW;
%    pp.mega_type='diff_inv';
    %pp.mega_type='first';
    pp.root_dir = LC_dir;

    write_fid_to_lcRAW(fall(nb_sub_group).group,pp)

    nb_sub_group=nb_sub_group+1;

  end
  
end

fprintf('done\n');

return


if 0
  pplot.same_fig=1;pplot.display_var=0;
  rfig='/home/romain/data/spectro/tourette/fig';
  for ngr=1:length(fall)
    pplot.save_file = fullfile(rfig,fall(1).region);
    plot_spectrum(fall(ngr).group,pplot)
  end
   
end

nn=1
for k=1:length(fall)
  for kk=1:length(fall(k).group)
    wref(nn) = fall(k).group(kk).water_ref;
    nn=nn+1;
  end
end

 anadir='/home/romain/data/spectro/tourette/anat';

write_fid_to_nii(wref,anadir);   
%en fait autant les faire tous
dr=get_subdir_regex(pwd,'dicom','.*','ref$');
war = explore_spectro_data(char(dr));
write_fid_to_nii(war,anadir);

%anat corege anat on first anat appy to other
sdir =get_subdir_regex('/home/romain/data/spectro/tourette/anat','oure')
sdir =get_subdir_regex('/home/romain/data/spectro/tourette/anat','^2011_0[34]')


%sdir(4)='' %remove sujet 3bis

jobs={}

 for ns=1:length(sdir)
   ana = get_subdir_regex(sdir(ns),'t1mpr');
   d=dir(sdir{ns}); remo=[];
   for k=1:length(d)
     if ~d(k).isdir,       remo(end+1) =k ;     end
   end
   d(remo) = '';
   
   nser=1;   numref=1;   
   ref =  get_subdir_regex_files(fullfile(sdir{ns},d(3).name),'^s.*img$');   ref=char(ref)
   
   for nser=4:length(d)
     if findstr(d(nser).name,'t1mpr')
       break
     end
   end

   while nser<length(d)
     other={};
     src =get_subdir_regex_files( fullfile(sdir{ns},d(nser).name),'^s.*img$');     src=char(src);
     aa=nser+1;
     for nser=aa:length(d)
       if findstr(d(nser).name,'t1mpr')
	 break
       end
       other(end+1) =get_subdir_regex_files( fullfile(sdir{ns},d(nser).name),{'img$','nii$'} );
     end
     jobs = do_coregister(src,ref,char(other),'',jobs);
   end
 end
 
 %realign epi volumes
 sfonc= get_subdir_regex(sdir,'LOCA$')
 %jobs={};
 pp.logfile='';pp.realign.type = 'mean_only'; pp.realign.to_first=1;
 for k=1:length(sfonc)
   ff=get_subdir_regex_files(sfonc(k),'img$')
   jobs=do_realign(ff,pp,jobs);
 end

 spm_jobman('run',jobs)

 %coreg epi on first anat apply to spectro_ref
 jobs={};
par.wanted_number_of_file=1;
 for ns=1:length(sdir)
   spec = get_subdir_regex(sdir(ns),'_ref$');
   ana =  get_subdir_regex(sdir(ns),'t1mpr.*176$');
   anaf = char(get_subdir_regex_files(ana,'^sSL.*img$',par))

   for kk=1:length(spec)
     [p f] = fileparts(spec{kk});     [p f] = fileparts(p);
     if isempty(str2num(f(4)))
       nuser = str2num(f(2:3));
       numepi = sprintf('^S%.2d',nuser+1);
     else
       nuser = str2num(f(2:4));
       numepi = sprintf('^S%.3d.*LOCA$',nuser+1);
     end
     
     epi = get_subdir_regex(sdir(ns),numepi);
     if isempty(epi)
       error('qsdfkeyboard')
     end
     
     epif = char(get_subdir_regex_files(epi,'^mean.*img$',par));
     specf= char(get_subdir_regex_files(spec(kk),'nii$',par));
          
     jobs = do_coregister(epif,anaf,specf,'',jobs);

   end
 end

 spm_jobman('run',jobs)

 
 
 %get result
 d=get_subdir_regex('/home/romain/data/spectro/tourette/lcmodel/mega_inv','.*','inv$')
 c=get_result(d)

a=get_subdir_regex('/home/romain/data/spectro/tourette/anat/','.*','.*');
sf = get_subdir_regex_files(a,'_ref\.nii$');
write_vol_to_roi(char(sf))



%et on recommence
d=get_subdir_regex(pwd,'.*','LOCA')
df=get_subdir_regex_files(d,'.*')
do_delete(df)

dicdir = '/nasDicom/spm_raw/PROTO_SL_TOURETTE';

for k=1:length(d)
  [p f] = fileparts(d{k});
  [p,f] = fileparts(p);
  [p,s] = fileparts(p);
  
  pdic = fullfile(dicdir,s,f);
  
  if exist(pdic)
    pdic;
    copyfile([pdic '/*'],d{k})
    
  else
    fprintf('%s does not exist\n',pdic)
  end
  
end


%get result
d=get_subdir_regex('/home/romain/data/spectro/tourette/lcmodel/mega_inv','.*','inv$');
dpress=get_subdir_regex('/home/romain/data/spectro/tourette/lcmodel/mega_first','.*','WS');
c=get_result(d)            
cw=get_water_content_tour(c)
cw=correct_water_content(cw,1,3) % 
cc=correct_result(cw);
ccs = remove_big_SD(cc,50);


write_conc_res_to_csv(ccs,'toto.csv')
write_conc_res_summary_gosia_to_csv(ccs,'totoS.csv')

cpres = get_result(dpress);
ccpre = correct_result(cpres,cw);
ccpre= remove_big_SD(ccpre,50);
write_conc_res_to_csv(ccpre,'totop.csv')
write_conc_res_summary_gosia_to_csv(ccpre,'totopS.csv')
