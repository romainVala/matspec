function c = get_water_content()

marsbar('on');


anat_dir = '/home/romain/data/spectro/hipo/repro_study/anat';

aref =  get_subdir_regex(anat_dir,'HIPO_..$','t1mpr','seg8');

c1 =  get_subdir_regex_files(aref,'^c1.*img');
c2 =  get_subdir_regex_files(aref,'^c2.*img');
c3 =  get_subdir_regex_files(aref,'^c3.*img');

if 0 % convert nii pos to roi
  d = get_subdir_regex(anat_dir,'HIPO');
  ds =  get_subdir_regex(d,'laser');
  dl = get_subdir_regex_files(ds,{'laser.*nii'}) ;
  write_vol_to_roi(char(dl))
end


d{1} = get_subdir_regex(anat_dir,'HIPO_..$');
d{2} = get_subdir_regex(anat_dir,'HIPO_.._E2$');
d{3} = get_subdir_regex(anat_dir,'HIPO_.._E3$');


for ns = 1:length(d{1})

  c(ns).pool = sprintf('REPRO_HIPO_%.2d',ns);
  nbspec = 0;
  
  for nbses=1:3

    ds =  get_subdir_regex(d{nbses}(ns),'laser');
    dl = get_subdir_regex_files(ds,{'_roi\.mat'}) ;
    
    for ndl = 1:length(dl)
      roi= maroi('load',dl{ndl});
      
      if nbses==1 & ndl==1 
	roi1=roi;
	maroi('classdata','spacebase',mars_space(c1{ns}));
	roi_interp = roi1&roi;

      else
	roi_interp = roi1&roi;
      end
      if ndl==1 
	roi2=roi;
	roi_interp2 = roi2&roi;
      else
	roi_interp2 = roi2&roi;
      end
       
      y=get_marsy(roi,spm_vol(c1{ns}),'mean');    sy(1)=summary_data(y);
      y=get_marsy(roi,spm_vol(c2{ns}),'mean');    sy(2)=summary_data(y);
      y=get_marsy(roi,spm_vol(c3{ns}),'mean');    sy(3)=summary_data(y);
      
      nbspec=nbspec+1;
      
      c(ns).suj{nbspec} = sprintf('REPRO_HIPO_%.2d_E%dN%d',ns,nbses,ndl);
      
      c(ns).fgray(nbspec)  = sy(1);
      c(ns).fwhite(nbspec) = sy(2);
      c(ns).fcsf(nbspec)    = sy(3);
      
      ssy = struct(y);
      
      c(ns).roi_seg_size(nbspec) = size(ssy.y_struct.regions{1}.Y,2);
%rrr do not know why it does not work      c(ns).roi_raw_size(nbspec) = volume(roi);

      if nbses==1 & ndl==1 
	ref_interp1_size = size(ssy.y_struct.regions{1}.Y,2);
      end
      
      if ndl==1
	ref_interp2_size = size(ssy.y_struct.regions{1}.Y,2);
      end
      c(ns).roi_interp1_size(nbspec) = volume(roi_interp);
      c(ns).roi_interp1_rel(nbspec) = volume(roi_interp)./ref_interp1_size;
      c(ns).roi_interp2_size(nbspec) = volume(roi_interp2);
      c(ns).roi_interp2_rel(nbspec) = volume(roi_interp2)./ref_interp2_size;
      
    end
    
  end
%  keyboard
  
end

