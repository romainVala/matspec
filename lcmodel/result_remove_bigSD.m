function co = result_remove_bigSD(c,seuil)

metname = find_metab_list(fieldnames(c));

co=c;

for nf=1:length(metname)
  
  for npool = 1:length(c)
  
    sdname = ['SD' metname{nf}];
    
    ysd = getfield(c(npool),sdname);
    
    if mean(ysd)>seuil
      co = rmfield(co,sdname);
      co = rmfield(co,metname{nf});    
      break
    end
    
  end
  
end
