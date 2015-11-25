function fo = sum_fid(fids,descr)

fo=fids;


for nbser = 1:length(fids)

  fid = fids(nbser).fid;
  ns = size(fid,2)/2
  
  fid1 = fid(:,1:ns);
  fid2 = fid(:,(ns+1):end);
  fid1m = mean(fid1,2);
  fid2m = mean(fid2,2);
  

%  if ~exist('fm1')
%    fm1 = fid1m;
%    fm2 = fid2m;
%  else
%    fm1 = fm1 + fid1m;
%    fm2 = fm2 + fid2m;
%  end 
%  fo(nbser).fid = [fm1,fm2];

  fo(nbser).fid = [fid1m,fid2m];

  if exist('descr')
    fo(nbser).Serie_description=descr;
  end

end


