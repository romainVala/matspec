function co = remove_big_SD(c1,seuil)

if iscell(c1)
    for k=1:length(c1)
        co{k} = remove_big_SD(c1{k},seuil)
    end
    return
end

  field_list = fieldnames(c1);
  co=c1;
  
  for npool = 1:length(c1)
    
    for nf=1:length(field_list)
      ind = findstr(field_list{nf},'SD');
      if ind
	cSD = getfield(c1(npool),field_list{nf});
	
	metname = field_list{nf}(3:end);
	cmet = getfield(c1(npool),metname);
	
	indrem = find(cSD>seuil);
	
	%if length(indrem)>=(length(cSD)/2)
	%  indrem = 1:length(cSD);
	%end
	
	cSD(indrem) = cSD(indrem)*NaN;
	cmet(indrem) = cmet(indrem)*NaN;

	%co(npool) = setfield(co(npool),field_list{nf},cSD);
	co(npool) = setfield(co(npool),metname,cmet);	  
      
      end
      
      
 %     cc = cc .* c2(npool).cor_all;
  %    c1(npool)  = setfield(c1(npool),field_list{nf},cc);
    end
  end


end
