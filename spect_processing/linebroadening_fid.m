function fo=linebroadening_fid(f,lb)


fo=f;

for nf=1:length(f)
  
  spec = f(nf).spectrum;
  fid = f(nf).fid;

  t=[0:spec.dw:(spec.np-1)*spec.dw]';
    
  for k=1:size(fid,2)
    fid(:,k) = fid(:,k) .* exp(-t*pi*lb);
  end
  fo(nf).fid = fid;
  
end