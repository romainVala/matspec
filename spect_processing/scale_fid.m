function f=scale_fid(f,sc)

for k=1:length(f)
    f(k).fid = f(k).fid.*sc(k);
end
