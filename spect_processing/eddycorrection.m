function fo=eddycorrection_fid(f,fw)


fo=f;

for nf=1:length(f)
  
  fid = f(nf).fid;
  fidw = mean(fw(nf).fid,2);
      
  for k=1:size(fid,2)
    fid(:,k) = fid(:,k) ./ exp(1*i*angle(fidw));
%    fid(:,k) = fid(:,k) - angl
  end
  fo(nf).fid = fid;
  
end
