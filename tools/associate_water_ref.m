function fi = associate_water_ref(fi,wfi)

if nargin==2
  for k=1:length(fi)
    
  end
  
else
  if length(fi)~=length(wfi)
    error('you must provide %d water reference',length(fi))
  end
  fi(k).water_ref = wfi(k);
end
