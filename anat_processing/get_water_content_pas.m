function c = get_water_content_pas(cmet)

marsbar('on');

pp.verbose=0;

anat_dir = '/servernas/images2/romain/data/spectro/PROTO_U731_CERVELET_TMS/anat';
%suj_dir = get_subdir_regex(anat_dir,'rett')
c=cmet;

for npol = 1:length(cmet)
  
 
  suj = cmet(npol).suj;
  
  for ns = 1:length(suj)
    sujname = suj{ns};

    ii=findstr(sujname,'_');
    sujreg = sujname(1:ii(3)-1);
    serreg = sujname(ii(4)+1:end);
    if strcmp(sujreg(end-1:end),'E1')
      sujreg(end-2:end)=''; sujall=sujreg;
    else
      sujall=sujreg;sujall(end-2:end)='';
    end

    aref = get_subdir_regex(anat_dir,[sujall ],'T2');

    c1 =  get_subdir_regex_files(aref,'^c1.*nii');
    c2 =  get_subdir_regex_files(aref,'^c2.*nii');
    c3 =  get_subdir_regex_files(aref,'^c3.*nii');
    
    if length(c1)~=1
      fprintf('ARGTttttt')
      keyboard
    end
    
    %    spec_dir = get_subdir_regex(anat_dir,sujreg,['MEGA.*' serreg]);
    %rrr added for svs press
    %serreg = ['MEGA_PRESS.*' serreg(end-2:end)];
    spec_dir = get_subdir_regex(anat_dir,[sujreg '$'],[serreg]);

    if length(spec_dir)~=1
      fprintf('ARGTtttttqsdfqsdf')
      keyboard
    end

    dl = get_subdir_regex_files(spec_dir,{'_roi\.mat'},pp) ;
 
    if isempty(dl)
      dl = get_subdir_regex_files(spec_dir,{'nii$'},pp) ;
      write_vol_to_roi(char(dl))
      dl = get_subdir_regex_files(spec_dir,{'_roi\.mat'},pp) ;
      
    end
    
    %rewrite the roi.mat if the nii file has changed
    dli = get_subdir_regex_files(spec_dir,{'nii$'},pp) ;
    dd=dir(dl{1});    ddi=dir(dli{1});
    if (dd.datenum-ddi.datenum)<0
      dl = get_subdir_regex_files(spec_dir,{'nii$'},pp) ;
      write_vol_to_roi(char(dl));
      dl = get_subdir_regex_files(spec_dir,{'_roi\.mat'},pp) ;
      fprintf('writing roi %s\n',dl{1});
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
    
  end  
  
end


