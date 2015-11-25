function f=remove_firsts_fid(f,skip)

for k=1:length(f)
  f(k).fid(:,skip)=[];
end
