function c = get_water_content(cmet,c1,c2,c3,Wat,lesions)
%% c = get_water_content(cmet,c1,c2,c3,Wat,lesions)
%
% Function to extract % of classes from a spectroscopy voxel
% 
% Added lesions (optional) to add a lesions voxel

marsbar('on');

%if ischar(c1),  c1=cellstr(c1);end
%if ischar(c2),  c2=cellstr(c2);end
%if ischar(c3),  c3=cellstr(c3);end
%if ischar(Wat),  Wat=cellstr(Wat);end
dolesions=0;
if exist('lesions','var')
    dolesions=1;
    c4=cellstr(char(lesions));
end

c1=cellstr(char(c1));
c2=cellstr(char(c2));
c3=cellstr(char(c3));

Wat=cellstr(char(Wat));

num_suj = 0;
c=cmet;

for npol = 1:length(cmet)  
 
  suj = cmet(npol).suj;
  
  for ns = 1:length(suj)
    sujname = suj{ns};
    num_suj = num_suj+1;

    dl_in = Wat{num_suj};
    [p,f,ex] = fileparts(dl_in);
    
    if strcmp(ex,'.nii') | strcmp(ex,'.img') | strcmp(ex,'.hdr') 
      dl = fullfile(p,[f '_roi.mat']) ;
      if ~exist(dl)
	write_vol_to_roi(char(dl_in))
      end
    elseif strcmp(ex,'.mat')
      dl=dl_in ;
    else
      error('unexpected spectro volume %s \n it should be eith .nii .img .hdr or roi.mat\n');
    end

    roi= maroi('load',dl);

    y=get_marsy(roi,spm_vol(c1{num_suj}),'mean');    sy(1)=summary_data(y);
    y=get_marsy(roi,spm_vol(c2{num_suj}),'mean');    sy(2)=summary_data(y);
    y=get_marsy(roi,spm_vol(c3{num_suj}),'mean');    sy(3)=summary_data(y);
    c(npol).suj{ns} = sujname;
    
    c(npol).fgray(ns)  = sy(1);
    c(npol).fwhite(ns) = sy(2);
    c(npol).fcsf(ns)    = sy(3);

    
    if dolesions
        y=get_marsy(roi,spm_vol(c4{num_suj}),'mean'); sy(4)=summary_data(y);
        c(npol).fles(ns)    = sy(4);
    end

    ssy = struct(y);
      
    c(npol).roi_seg_size(ns) = size(ssy.y_struct.regions{1}.Y,2);
  end  
  
%  c(npol).water_ref = Wat;
%  c(npol).c1 = c1;
%  c(npol).c2 = c2;
%  c(npol).c3 = c3;
  
  
end


