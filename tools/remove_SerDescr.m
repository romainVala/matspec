function fo=remove_SerDescr(fi,descrp)

fo=fi;

for k=1:length(fi)
  ind = findstr(fi(k).SerDescr,descrp)
  fo(k).SerDescr(ind:(ind+length(descrp)))='';
end
