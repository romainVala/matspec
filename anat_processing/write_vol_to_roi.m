function write_vol_to_roi(f)

if ~exist('f')
  f= spm_select([1 Inf],'image','select images','',pwd);
end
vol=spm_vol(f);

for nbvol=1:length(vol)
  roi_fname=[vol(nbvol).fname(1:end-4),'_roi.mat']

  o = maroi_image(struct('vol', vol(nbvol), 'binarize',1,...
			 'func', 'img>0'));
  o = label(o,vol(nbvol).fname(1:end-4));

  o = spm_hold(o,0)
 
  
  saveroi(o, roi_fname);


end
  
  
