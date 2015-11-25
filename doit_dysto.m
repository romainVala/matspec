
rootdir = '/home/romain/data/spectro/PROTO_SPECTRO_DYST/Sujet_dicom';
rawdir = '/home/romain/data/spectro/PROTO_SPECTRO_DYST/LCmodel/All';

control_wc =  {'Sujet01','Sujet02','Sujet03','Sujet04','Sujet05','Sujet07','Sujet08','Sujet10','Sujet11','Sujet14','Sujet15','Sujet22','Sujet37','Sujet38'};

patient_wc = {'Sujet06','Sujet12','Sujet13','Sujet19','Sujet20','Sujet21','Sujet23','Sujet24','Sujet25','Sujet26','Sujet27','Sujet28','Sujet29','Sujet30','Sujet35','Sujet41'};

group = {'control','patient'};

region_wc = {'MC_L$','BG_L$','MC_R$','OCC$','BG_R$','CER$'};

nb_sub_group = 1;

for nbg=1:2
  if nbg==1
    s_dir = get_subdir_regex(rootdir,control_wc);
  else
    s_dir = get_subdir_regex(rootdir,patient_wc);
  end
  
  for nbr=1:length(region_wc)
    dd = get_subdir_regex(s_dir,region_wc(nbr));
  
    f = explore_spectro_data(char(dd));
  
    f = concatenate_fid(f);
  
    par.figure = 0;
    par.mean_line_broadening = 6;
  
    try
      f = processing_MEGA(f,par);
    catch
      fileid=fopen('doit_dysto_error.log','a+')
      fprintf(fileid,'PROBLEM with mega preprosseging for %s region %s \n',group{nbg},region_wc{nbr});
      fclose(fileid);
    end
  
    %%%Writing to LCmodel RAW files
    
    f = remove_field_string(f,'sujet_name',[1:20]);
    f = remove_field_string(f,'sujet_name','_E.$');
    f = remove_field_string(f,'SerDescr','MEGA-PRESS ');
    
    if (~isempty(findstr(region_wc{nbr},'MC_L')) | ~isempty(findstr(region_wc{nbr},'BG_L')))

      [fc{1},fc{2}] = split_fid(average_fid_mega(f));
      
      group_name{1} = [region_wc{nbr}(1:end-1),'_',group{nbg},'_E1'];
      group_name{2} = [region_wc{nbr}(1:end-1),'_',group{nbg},'_E2'];
      
    else
      group_name{1} = [region_wc{nbr}(1:end-1),'_',group{nbg}];
      fc{1} = average_fid_mega(f);
    end
    
    for sg = 1:length(group_name)

      fall(nb_sub_group).group  = average_fid_mega(fc{sg});
      fall(nb_sub_group).region = group_name{sg};

      LC_dir = fullfile(rawdir,group_name{sg});
      if ~exist(LC_dir),mkdir(LC_dir);end
      
      fall(nb_sub_group).lcdir  = LC_dir;
      
      write_fid_to_lcRAW(fc{sg},0,LC_dir);

      nb_sub_group=nb_sub_group+1;
      
    end
    clear group_name fc    
    
  end
end

%correct water peak freq
par.ref_metab = 'water';
par.mean_line_broadening = 1;

for nbg=1:length(fall)
  
  for nsuj=1:length(fall(nbg).group)
    fall(nbg).group(nsuj).water_ref = processing_MEGA(fall(nbg).group(nsuj).water_ref,par);
  end
  
end


for nbg=1:length(fall)
  
  for nsuj=1:length(fall(nbg).group)
    fall(nbg).group(nsuj).water_ref = get_coresponding_water_ref(fall(nbg).group(nsuj));
  end
  
end

%write to lcmodel
pp=write_fid_to_lcRAW;
pp.mega_type='diff_inv';

lcrootdir='/home/romain/data/spectro/PROTO_SPECTRO_DYST/LCmodel/All_mega_inv_wcor';

for nbg=1:length(fall)
  LC_dir = fullfile(lcrootdir,fall(nbg).region);
  
  pp.root_dir = LC_dir;
  if ~exist(LC_dir),mkdir(LC_dir);end

  write_fid_to_lcRAW(fall(nbg).group,pp)
  
end



c=get_re
cm=get_result(d);

load('/servernas/images2/romain/data/spectro/PROTO_SPECTRO_DYST/LCmodel/water_content');

cwc=correct_water_content(cw);

cmc=correct_result(cm,cwc)

cmc = expand_dysto_conc(cmc);


d=get_subdir_regex('/servernas/images2/romain/data/spectro/PROTO_SPECTRO_DYST/lana','.*')
sc = 100/53011 ;
cwl = correct_water_content(cw,100/53011)

clac=correct_result(cla,cwl,{'naa','gaba','glugln','gln','glu','MMnaa','MMgaba','MMglugln','MMgln','MMglu'});


dirok='/home/romain/data/spectro/PROTO_SPECTRO_DYST/LCmodel/All_mega_inv';

for nbg=1:length(fall)
  ind_to_remove = [];
  for nsuj=1:length(fall(nbg).group)
    rawname = [fall(nbg).group(nsuj).sujet_name '_' fall(nbg).group(nsuj).examnumber '_' fall(nbg).group(nsuj).SerDescr ];
    rawname = [nettoie_dir(rawname) '.RAW'];

    if ~exist(fullfile(dirok,fall(nbg).region,rawname))
      fprintf('%s shouldis be removed\n',rawname)
      ind_to_remove(end+1) = nsuj
    end
    
  end
 % fall(nbg).group(ind_to_remove) = '';
  
end



%article figure
load MMok
load ALL_average
MM=average_series_fid(f)

pp.xlim=[0.5 5.5];
pp.mean_line_broadening=1;
pp.ylim=[-2100 21000]  

plot_spectrum(MM,pp)
plot_spectrum(fall(1).group(5),pp)

pp.ylim='auto';      
 
plot_spectrum(fall(1).group(5),pp) %MC

plot_spectrum(fall(6).group(12),pp) %OCC
plot_spectrum(fall(3).group(5),pp)  %BG