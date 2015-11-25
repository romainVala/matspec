function fo = sum_fid_local_mega(fids,nz)
% fid_struc = sum_fid_local(fid_struc,nb)
% this will remplace each spectra by the average of the nb nearest spectra


fo=fids;


for nbser = 1:length(fids)

  
  fid = fids(nbser).fid;
  ns = size(fid,2)/2
  
  fid1 = fid(:,1:ns);
  fid2 = fid(:,(ns+1):end);

  ff = fids(nbser);
  ff.fid = fid1;  
  fo1 = sum_fid_local(ff,nz);
  
  ff = fids(nbser);
  ff.fid = fid2;  
  fo2 = sum_fid_local(ff,nz);
  
  fo(nbser) = fids(nbser);
  fo(nbser).fid =[fo1.fid,fo2.fid];


end



