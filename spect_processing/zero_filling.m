function fo = zero_filling(f,z)

fo=f;

if z>0

  for nbser = 1:length(f)

    np = f(nbser).spectrum.np * z;
    npadd =  f(nbser).spectrum.np *(z-1);
  
    fo(nbser).fid = [f(nbser).fid ; zeros(npadd,size(f(nbser).fid,2))];
  
    fo(nbser).spectrum.np = np;
    fo(nbser).spectrum.n_data_points = np;

  end
else
  for nbser = 1:length(f)
    newsize = size(f(nbser).fid,1)/(-z);
    fo(nbser).fid = f(nbser).fid(1:newsize,:);
    
    fo(nbser).spectrum.np = newsize;
    fo(nbser).spectrum.n_data_points = newsize;
  
  end
end
