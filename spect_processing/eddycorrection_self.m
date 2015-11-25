function fo=eddycorrection_self(f)

fo=f;

for nf=1:length(f)
  
  fid = f(nf).fid;
      
  for k=1:size(fid,2)
    fid(:,k) = fid(:,k) ./ exp(1*i*angle(fid(:,k)));
  end
  fo(nf).fid = fid;
  
end
