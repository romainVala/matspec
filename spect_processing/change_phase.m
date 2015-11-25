function fo = change_phase (fi,phi)


fo = fi;

for nb_ser = 1:length(fi)


  fid = fi(nb_ser).fid;

  for k=1:size(fid,2)
    ff(:,k) = exp(-1i*phi*pi/180)*fid(:,k);
  end

  fo(nb_ser).fid = ff;

end