function c1 = correct_result(c1,c2,field_list,fielnamcor)

divide=0;

if ~exist('c2')
  c2=c1;
end

if ~exist('fielnamcor')
  fielnamcor = 'cor_all';
end

correct_only_with_mean=0;

if iscell(c1)
    for k=1:length(c1)
        field_list = find_metab_list(fieldnames(c1{k}));
        c1{k} = correct_result(c1{k},c2,field_list,fielnamcor);
    end
    return
end

if ~exist('field_list')
      field_list = find_metab_list(fieldnames(c1));
end

if isnumeric(c2)
  scalfac =c2;
  for npool = 1:length(c1)
    for nf=1:length(field_list)
    
      metname = field_list{nf};
      
      cmet = getfield(c1(npool),metname);
      cc = cmet .* scalfac;
      c1(npool)  = setfield(c1(npool),metname,cc);
      
    end
  end

else

  for npool = 1:length(c1)
    for nf=1:length(field_list)
    
      metname = field_list{nf};
      
      cmet = getfield(c1(npool),metname);
      
      ccor = getfield(c2(npool),fielnamcor);
      
      if correct_only_with_mean
	cc = cmet .* mean(ccor);
      else
	if divide
	  cc = cmet ./ ccor;
	else
	  cc = cmet .* ccor;
	end
	
      end
      
      c1(npool)  = setfield(c1(npool),metname,cc);
    end
  end

end


if 0
  
  %scale 
 field_list = fieldnames(c1);
 field_list(1:2)=[];

 scalfac = 100/135;
 
 for npool = 1:length(c1)
   for nf=1:length(field_list)
    
     sdname = field_list{nf};
     ind = findstr(field_list{nf},'SD');
    
     if ind
       metname = sdname;
       metname(ind:ind+1)='';
      
       cmet = getfield(c1(npool),metname);
       cc = cmet .* scalfac;
       c1(npool)  = setfield(c1(npool),metname,cc);
      
     end
   end
 end

  
  %remove NAA
  
  field_list = fieldnames(c1);
  co=c1;
  
  for npool = 1:length(c1)
    
    for nf=1:length(field_list)
      ind = findstr(field_list{nf},'SD');
      if ind
	cSD = getfield(c1(npool),field_list{nf});
	
	metname = field_list{nf}(3:end);
	cmet = getfield(c1(npool),metname);
	
	indrem = find(cSD>25);
	
	cSD(indrem) = cSD(indrem)*NaN;
	cmet(indrem) = cmet(indrem)*NaN;

	co(npool) = setfield(co(npool),field_list{nf},cSD);
	co(npool) = setfield(co(npool),metname,cmet);	  
      
      end
      
      
 %     cc = cc .* c2(npool).cor_all;
  %    c1(npool)  = setfield(c1(npool),field_list{nf},cc);
    end
  end


end
