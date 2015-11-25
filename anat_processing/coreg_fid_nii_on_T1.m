
%root_dir = '/servernas/images2/romain/data/spectro/hipo/repro_study/fid_pos_nii';
anat_dir = '/home/romain/data/spectro/hipo/repro_study/anat';

coreg_inter=0;

if coreg_inter

jobs = {};
log_file='log_coreg.log';

d1 = get_subdir_regex(anat_dir,'HIPO_..$');

for nbses=1:2
  if nbses==1
    d2 = get_subdir_regex(anat_dir,'HIPO_.._E2$');
  else
    d2 = get_subdir_regex(anat_dir,'HIPO_.._E3$');    
  end
  
  for ns=1:length(d1)
    a1 = get_subdir_regex(d1(ns),'t1mpr');
    a2 = get_subdir_regex(d2(ns),'t1mpr');
    a3 = get_subdir_regex(d2(ns),{'epse','laser'});
    
    sa1 = get_subdir_regex_files(a1,'^sSL.*img'); sa1=char(sa1);
    sa2 = get_subdir_regex_files(a2,'^sSL.*img'); sa2=char(sa2);
    sa3 = get_subdir_regex_files(a3,{'^sSL.*img','laser.*nii'}); sa3=char(sa3);
    
    jobs = do_coregister(sa2,sa1,sa3,log_file,jobs);
    
  end
end

%spm_jobman('interactive',jobs);

%jname=fullfile(anat_dir,'coreg_session.xml');
%savexml(jname,'jobs');

spm_jobman('run',jobs);


else
  jobs = {};

  d = get_subdir_regex(anat_dir,'HIPO');
  for ns=1:length(d)
    ds =  get_subdir_regex(d(ns),'laser');
    de =  get_subdir_regex(d(ns),'epse');
    
    fds = get_subdir_regex_files(ds,{'laser.*nii'}) 
    fde = get_subdir_regex_files(de,{'^sSL.*img'})
    
    %old version (coreg to first)
    %    for nf=2:length(fds)
    %      jobs = do_coregister(fde{nf},fde{1},fds{nf},'',jobs)
    %    end
 
    for nf=1:length(fds)
      jobs = do_coregister(fde{nf+1},fde{1},fds{nf},'',jobs);
    end
 
  end  
  
  
end
