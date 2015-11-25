function fo = sum_fid(fids,descr)

fo=fids;


for nbser = 1:length(fids)

  fo(nbser).fid =sum( fids(nbser).fid,2);
end
