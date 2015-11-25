function wc = get_coresponding_water_content(rawname)

if findstr(rawname,'PROTO_SPECTRO_DYST')
  anat_dir='/home/romain/data/spectro/PROTO_SPECTRO_DYST/anat';
  roi_dir='/home/romain/data/spectro/PROTO_SPECTRO_DYST/fid_pos_nii';

  preproc_subdir='vbm5';
  anatdir_wc = '*t1mpr*';
%elseif findstr(rawname,'/PROTO_U731_CERVELET_TM')

elseif findstr(rawname,'PROTO_SCA')
  anat_dir='/home/romain/data/spectro/PROTO_SCA/anat';
  roi_dir='/home/romain/data/spectro/PROTO_SCA/roi_nii_again';

  preproc_subdir='';
  anatdir_wc = '*T1W';

elseif findstr(rawname,'PROTO_U731_CERVELET_TMS')
  anat_dir='/home/romain/data/spectro/PROTO_U731_CERVELET_TMS/anat';
  roi_dir='/home/romain/data/spectro/PROTO_U731_CERVELET_TMS/fid_nii';

  preproc_subdir='segSPM5';
  anatdir_wc = '*t1mpr*';

elseif findstr(rawname,'tourette')
  anat_dir='/home/romain/data/spectro/tourette/anat';
  preproc_subdir='';
  anatdir_wc ='176$';
  
else
  warning('do not find the study')
  keyboard
end
  
[p,f] = fileparts(rawname);

if strcmp(anat_dir,'/home/romain/data/spectro/tourette/anat')
  
  ind=findstr(f,'_E1_');
  name = f(1:ind-1);
  exam='';
  region=['PRESS_' f(ind+4:end) '_ref'];
  
  anadir = get_subdir_regex(anat_dir,name,anatdir_wc);
  c1 = char(get_subdir_regex_files(anadir,'^c1.*img$'));
  c2 = char(get_subdir_regex_files(anadir,'^c2.*img$'));
  c3 = char(get_subdir_regex_files(anadir,'^c3.*img$'));
  
  roidir = get_subdir_regex(anat_dir,name,region);
  
  roif = char(get_subdir_regex_files(roidir,'mat$'))
  
  roi= maroi('load',roif);
      
else

    ind=findstr('Sujet',f);
    if isempty(ind)
        ind = findstr('SUJET',f)
        if strfind(f,'SUJET03')
        name=f(1:ind+6);        exam=['_',f(ind+8:ind+9)];        region = [f(ind+11:end)];    
        else
        name=f(1:ind(1)+6);    exam=['_',f(ind+8:ind+9)];region = [f(ind(2)+19:end-4)];
        end
    else
        name=f(1:ind+6);
        exam=['_',f(ind+8:ind+9)];
        region = [f(ind+11:end)];
    end
  suj = name
  
  rp = [suj,exam,'_',region,'_roi.mat'];
  
  if strcmp(suj,'Sujet08')
    wc=[0.7846 1 1 1];
    warning ('arrge find the anat')
    return
  end
  
    
  sujdir=fullfile(anat_dir,suj);
  
  anadir = dir([sujdir,filesep,anatdir_wc ]);
  anadir = fullfile(sujdir,anadir.name,preproc_subdir);
  
  c1 = dir([anadir,filesep,'c1*.img']);    c1 = fullfile(anadir,c1.name);
  c2 = dir([anadir,filesep,'c2*.img']);    c2 = fullfile(anadir,c2.name);
  c3 = dir([anadir,filesep,'c3*.img']);    c3 = fullfile(anadir,c3.name);

  if strfind(anat_dir,'_SCA')
      roidir = get_subdir_regex(roi_dir,suj,region); roidir=roidir{1};
      roifil = get_subdir_regex_files(roidir,'.mat$')
      roi= maroi('load',roifil{1});
  else
      roidir=roi_dir;
      roi= maroi('load',fullfile(roidir,rp));
  end

  %roi= maroi('load',fullfile(roidir,rp));
  %keyboard
end

y=get_marsy(roi,spm_vol(c1),'mean');    sy(1)=summary_data(y);
y=get_marsy(roi,spm_vol(c2),'mean');    sy(2)=summary_data(y);
y=get_marsy(roi,spm_vol(c3),'mean');    sy(3)=summary_data(y);

    
wc = sum(sy.*[0.83 0.71 1]);
wc=[wc sy];
