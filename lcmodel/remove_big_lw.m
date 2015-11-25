function co = remove_big_lw(c1)

  field_list = fieldnames(c1);
  co=c1;
  
  for npool = 1:length(c1)
    
    nlw = c1(npool).linewidth;
    seuil = mean(nlw) + 2 * std(nlw);
    
    indrem1 = find(nlw>seuil);

    nlw = c1(npool).water_width;
    seuil2 = mean(nlw) + 2 * std(nlw);
    
    indrem2 = find(nlw>seuil2);
    
    indrem = unique([indrem1 indrem2]);
%    if indrem1&indrem2
%      keyboard
%    end
    
    if indrem
      fprintf('\nremoving %d subject for pool %s',length(indrem),c1(npool).pool)
      for kk=1:length(indrem)
	fprintf(' %s ',c1(npool).suj{indrem(kk)})
      end
      
      
      for nf=1:length(field_list)
	cf = getfield(c1(npool),field_list{nf});
	
	if iscell(cf) | isnumeric(cf)
	  cf(indrem)='';
	  co(npool) = setfield(co(npool),field_list{nf},cf);
	end
	
      
      end
      
    end
  end

