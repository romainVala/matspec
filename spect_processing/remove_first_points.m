function fo = remove_first_points(fi,numberofpoints)

if ~exist('numberofpoints')
  numberofpoints=1;
end

fo = fi;

for nbs = 1:length(fi)
  fo(nbs).fid = fi(nbs).fid(numberofpoints+1:end,:);
  
  fo(nbs).spectrum.np = fo(nbs).spectrum.np -numberofpoints;
  fo(nbs).spectrum.n_data_points = fo(nbs).spectrum.n_data_points -numberofpoints;
  
end
