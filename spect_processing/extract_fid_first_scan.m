function fi = extract_fid_first_scan(fi,NUM)

for nbser = 1:length(fi)

  if size(fi(nbser).fid,2)>NUM
    fi(nbser).fid = fi(nbser).fid(:,NUM);
    fi(nbser).Nex = length(NUM);
  end
  
  
end
