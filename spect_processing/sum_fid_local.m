function fo = sum_fid_local(fids,nz)
% fid_struc = sum_fid_local(fid_struc,nb)
% this will remplace each spectra by the average of the nb nearest spectra

fo=fids;


for nbser = 1:length(fids)

  fid =  fids(nbser).fid;
  
  num_fid = size(fid,2);
  
  for kf = 1:(num_fid-nz)
    fidn(:,kf) = sum(fid(:,kf:(kf+nz)),2) ./ nz;
  end
  
  fo(nbser).fid = fidn;
  clear fidn;
%  fo{nbser}.Nex = fidn;
  
end



