function c = get_water_content_tour(cmet)

marsbar('on');

pp.wanted_number_of_file=1;
pp.verbose=0;

anat_dir = '/home/romain/images5/spectro7T/anat';

%c=cmet;

for npol = 1:length(cmet)
  
  c(npol).pool = cmet(npol).pool;
  
  suj = cmet(npol).suj;
  
  for ns = 1:length(suj)
    sujname = suj{ns};
    sujreg = [sujname(4:5) '$'];

    aref = get_subdir_regex(anat_dir,sujreg,'T2_TSE');
    c1 =  get_subdir_regex_files(aref,'^c1.*nii',pp);
    c2 =  get_subdir_regex_files(aref,'^c2.*nii',pp);
    c3 =  get_subdir_regex_files(aref,'^c3.*nii',pp);
    
    indn = findstr(sujname,'NEX');
    sujname(indn:end)='';
    
    spec_dir = get_subdir_regex(anat_dir,sujreg,sujname);

    if length(spec_dir)~=1
      fprintf('ARGE %d\n',ns)
      keyboard
    end
    
    dl = get_subdir_regex_files(spec_dir,{'_roi\.mat'}) ;
 
    if isempty(dl)
      dl = get_subdir_regex_files(spec_dir,{'nii$'}) ;
      write_vol_to_roi(char(dl))
      dl = get_subdir_regex_files(spec_dir,{'_roi\.mat'}) ;
      
    end
 
    if length(dl)~=1
     
      fprintf('aqdqsf')
      keyboard
    end
    
    roi= maroi('load',dl{1});

    y=get_marsy(roi,spm_vol(c1{1}),'mean');    sy(1)=summary_data(y);
    y=get_marsy(roi,spm_vol(c2{1}),'mean');    sy(2)=summary_data(y);
    y=get_marsy(roi,spm_vol(c3{1}),'mean');    sy(3)=summary_data(y);
      
    c(npol).suj{ns} = sujname;
    
    c(npol).fgray(ns)  = sy(1);
    c(npol).fwhite(ns) = sy(2);
    c(npol).fcsf(ns)    = sy(3);
      
    ssy = struct(y);
      
    c(npol).roi_seg_size(ns) = size(ssy.y_struct.regions{1}.Y,2);
    mat = ssy.y_struct.info.VY.mat;    vox= sqrt(sum(mat(1:3,1:3).^2));
    c(npol).roi_seg_size_vol(ns) = prod(vox) .* c(npol).roi_seg_size(ns) /1000;
    
  end  
  
end


