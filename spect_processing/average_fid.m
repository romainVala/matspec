function fi = average_fid(fi,descr)

for nbser = 1:length(fi)
  fi(nbser).fid =sum( fi(nbser).fid,2)./(size(fi(nbser).fid,2));
end
