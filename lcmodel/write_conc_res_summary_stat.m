function write_conc_res_summary_stat(conc,resname,field_list)

dottest=1;

stdrel=1;

if ~exist('field_list')
  field_list = find_metab_list(conc);
end

fid = fopen(resname,'w+');

npool=1;

fprintf(fid,'\n\n,');
  
for kf = 1:length(field_list)
  fprintf(fid,',%s,%s',field_list{kf},field_list{kf});
end

if isfield(conc,'linewidth')
   fprintf(fid,',lw(NAA),lw(NAA)');
end

if isfield(conc,'water_width')
   fprintf(fid,',lw(H20),lw(H20)');
end

fprintf(fid,'\nvoxel,no subjects');

if stdrel
  stdstr='std/m';
else
  stdstr='std';
end


for kf = 1:length(field_list)
  fprintf(fid,',mean,%s',stdstr);
end

if isfield(conc,'linewidth')
  fprintf(fid,',mean,%s',stdstr);
end
if isfield(conc,'water_width')
  fprintf(fid,',mean,%s',stdstr);
end



for npool = 1:length(conc)

  fprintf(fid,'\n%s,%d',conc(npool).pool,length(conc(npool).suj));
  

  for kf = 1:length(field_list)
    metab = field_list{kf};
    aa = getfield(conc(npool),metab);
    aa(isnan(aa))=[];
    if stdrel
      fprintf(fid,',%0.3f,%0.3f',mean(aa),std(aa,1)/mean(aa));
    else
      fprintf(fid,',%0.3f,%0.3f',mean(aa),std(aa));    
    end
    
  
  end

  if isfield(conc,'linewidth')
    aa = conc(npool).linewidth;
    aa(isnan(aa))=[];
    if stdrel
      fprintf(fid,',%0.3f,%0.3f',mean(aa),std(aa,1)/mean(aa));
    else
      fprintf(fid,',%0.3f,%0.3f',mean(aa),std(aa));
    end
    
  end
  if isfield(conc,'water_width')
    aa = conc(npool).water_width;
    aa(isnan(aa))=[];
    if stdrel
      fprintf(fid,',%0.3f,%0.3f',mean(aa),std(aa,1)/mean(aa));
    else
      fprintf(fid,',%0.3f,%0.3f',mean(aa),std(aa));
    end
  end


end

fprintf(fid,'\n\n\n');
 

if dottest
  
  if length(conc)==16
    conc=expand_dysto_conc(conc);
  end
  
  fprintf(fid,'Region,');
  
  for kf = 1:length(field_list)
    fprintf(fid,',%s,',field_list{kf});
  end

  for npool = 1:length(conc)/2
    n1 = conc(2*npool-1).pool;
    n2 = conc(2*npool).pool;
    
    fprintf(fid,'\n%s/%s,',n1,n2);
    
    for kf = 1:length(field_list)
      y1 = getfield(conc(2*npool-1),field_list{kf});
      y2 = getfield(conc(2*npool),field_list{kf});
 
      y1(isnan(y1))='';      y2(isnan(y2))='';
 
      if isempty(y1)|isempty(y2)
	h=0
      else
	
	[h,p]=ttest2(y1,y2,0.1,'right','unequal');
	
	if isnan(h)
	  h=0;
	else
	  if ~h
	    [h,p]=ttest2(y1,y2,0.1,'left','unequal');
	    if h
	      if p>0.05
		str_senc='<';
	      else
		str_senc='<<';	    
	      end
	    end
	    
	  else
	    if p>0.05
	      str_senc='>';
	    else
	      str_senc='>>';	    
	    end
	  end
 	  
	end
	
     end
      
	
      if h
	fprintf(fid,',%s %f,',str_senc,p);
      else
	fprintf(fid,',,');
      end
      
    end
   
    
  end
  
end

fclose(fid);