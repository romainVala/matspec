anadir='/home/romain/data/spectro/PROTO_SPECTRO_DYST/anat/';
spec_nii_dir = '/home/romain/data/spectro/PROTO_SPECTRO_DYST/fid_pos_nii/';

jobs = {};
log_file='log_coreg.log';

d=dir(fullfile(anadir,'*_E*'));

spm('defaults','FMRI');


for k=1:length(d)

  T2dir = dir(fullfile(anadir,d(k).name,'*T2_TSE*'));

  if length(T2dir)>1
    fprintf(' Sujet %s has %d T2\n',d(k).name,length(T2dir))
  end

  T2dir = fullfile(anadir,d(k).name,T2dir(1).name);
  T2file = dir([T2dir,'/*.img']);
  T2file = fullfile(T2dir,T2file.name);
  
  suj = d(k).name(1:7)
  T1dir = dir(fullfile(anadir,suj,'/*t1mpr*'));
  T1dir = fullfile(anadir,suj,T1dir(1).name)
  T1file = dir([T1dir,'/*.img']);
  T1file = fullfile(T1dir,T1file.name);

  
  spec_nii = dir([spec_nii_dir,d(k).name,'*.nii']);
  spec_nii = char(spec_nii.name);
  spec_nii = [repmat(spec_nii_dir,[size(spec_nii,1),1]),spec_nii];

  if isempty(T2file) | isempty(T1file) | isempty(spec_nii)
    keyboard
  end
  
  
  jobs = do_coregister(T2file,T1file,spec_nii,log_file,jobs);
end
