function fo=add_zer_line(f,fac)


lb=2;
lineposition = -4.7; %-4.65;
lineposition = -4.65;%4.65;
  
  
fo =f;
for nf = 1:length(f)

  spec = f(nf).spectrum;
  t=[0:spec.dw:(spec.np-1)*spec.dw]';
  fid = f(nf).fid;

  sfrq = spec.cenfreq;
  ns = size(fid,2)/2;

  if ns<1
    fid2 = fid;
  else
    
    fid1 = fid(:,1:ns);
    fid2 = fid(:,(ns+1):end);
  end
  


  for k=1:size(fid2,2)
    fid2(:,k) = fid2(:,k) + fac*exp(-t*pi*lb).*exp(-1i*2*pi*lineposition*sfrq*t);
%    fid1(:,k) = fid1(:,k)*10;
  end
  
  if ns<1
    fo(nf).fid = fid2;
  else
    fo(nf).fid = [fid1,fid2];
  end
  

end
