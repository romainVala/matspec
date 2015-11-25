function fo = sum_fid_local2(fids,nz)

fo=fids;


for nbser = 1:length(fids)

  fid =  fids(nbser).fid;
  
  num_fid = size(fid,2);
  
  for kf = 1:nz:num_fid
    fidn(:,(kf-1)/nz + 1) = sum(fid(:,kf:(kf+nz-1)),2) ./ nz;
  end
  
  fo(nbser).fid = fidn;
  clear fidn;
%  fo{nbser}.Nex = fidn;

end



