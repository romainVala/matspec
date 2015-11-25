function fi=remove_field_string(fi,fieldn,ind_to_remove)

for k=1:length(fi)
  
  str = getfield(fi(k),fieldn);
  if isnumeric(ind_to_remove)
    
    str(ind_to_remove)='';
    
  else
    [i1,i2] = regexp(str,ind_to_remove);
    str(i1:i2) = '';
  end
  
  
  fi(k) = setfield(fi(k),fieldn,str);
  
end
