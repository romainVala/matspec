function c = get_water_content2()

marsbar('on');


%anat_dir = '/home/romain/data/spectro/hipo/OCC/anat';
%suj_dir = get_subdir_regex(anat_dir,'pilote')

anat_dir = '/home/romain/data/spectro/tourette/anat';
suj_dir = get_subdir_regex(anat_dir,'rett')

for ns = 1:length(suj_dir)
  [p,f]=fileparts(suj_dir{ns}); [p,sujname] = fileparts(p);

%  aref = get_subdir_regex(suj_dir(ns),'t1','seg8');
  aref = get_subdir_regex(suj_dir(ns),'S176$');
  c1 =  get_subdir_regex_files(aref,'^c1.*img');
  c2 =  get_subdir_regex_files(aref,'^c2.*img');
  c3 =  get_subdir_regex_files(aref,'^c3.*img');
  
  ds =  get_subdir_regex(suj_dir(ns),'eja');
  dl = get_subdir_regex_files(ds,{'_roi\.mat'}) ;

  for nbspec = 1:length(dl)
    roi= maroi('load',dl{nbspec});

    y=get_marsy(roi,spm_vol(c1{1}),'mean');    sy(1)=summary_data(y);
    y=get_marsy(roi,spm_vol(c2{1}),'mean');    sy(2)=summary_data(y);
    y=get_marsy(roi,spm_vol(c3{1}),'mean');    sy(3)=summary_data(y);
      
    c(ns).suj{nbspec} = sujname;
    
    c(ns).fgray(nbspec)  = sy(1);
    c(ns).fwhite(nbspec) = sy(2);
    c(ns).fcsf(nbspec)    = sy(3);
      
    ssy = struct(y);
      
    c(ns).roi_seg_size(nbspec) = size(ssy.y_struct.regions{1}.Y,2);
    
  end  
  
end


