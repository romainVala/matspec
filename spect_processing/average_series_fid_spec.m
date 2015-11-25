function fo = average_series_fid_spec(fids)

fo=fids(1);



for nbser = 1:length(fids)

  fid = fids(nbser).fid;

  fid1m = mean(fid,2);

  if ~exist('fm1')
    fm1 = fid1m;
  else
    fm1 = fm1 + fid1m;
  end 

end

fo(1).fid = [fm1] ./ nbser;
  
if exist('descr')
  fo(nbser).Serie_description=descr;
end
