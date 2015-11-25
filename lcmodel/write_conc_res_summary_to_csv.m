function write_conc_res_summary_to_csv(conc,fid,field_list,std_abs)

if ~exist('std_abs')
  std_abs=0;
end


fprintf(fid,'\n\n')

npool=1;
if isfield(conc(1),'suj_age')
  fprintf(fid,'%s,Age',conc(npool).pool);
else
  fprintf(fid,'%s',conc(npool).pool);
end
  
for kf = 1:length(field_list)
  if ~strcmp(field_list{kf},'suj_age')
    fprintf(fid,',%s',field_list{kf});
  end
end

for npool = 1:length(conc)
  if npool>1
    fprintf(fid,'%s',conc(npool).pool);
  end
 
  %print the mean
  fprintf(fid,'\nmean');
%  if isfield(conc(1),'suj_age'),fprintf(fid,',');end
  if isfield(conc(1),'suj_age'),
    aa = conc(npool).suj_age;
    sa=str2num(cell2mat(aa'));

    fprintf(fid,',%0.1f',mean(sa));
  end

  for kf = 1:length(field_list)
    if ~strcmp(field_list{kf},'suj_age')
      aa = getfield(conc(npool),field_list{kf});
      if isnumeric(aa)
	aa(isnan(aa))=[];
	fprintf(fid,',%0.3f',mean(aa));
      else
	fprintf(fid,',');
      end
      
    end
  end

  if std_abs
    %print the std
    fprintf(fid,'\nstd');
    
    %  if isfield(conc(1),'suj_age'),fprintf(fid,',');end
    if isfield(conc(1),'suj_age')
      fprintf(fid,',%0.1f',std(sa));
    end


    for kf = 1:length(field_list)
      if ~strcmp(field_list{kf},'suj_age')
	aa = getfield(conc(npool),field_list{kf});
	if isnumeric(aa)
	  aa(isnan(aa))=[];
	  fprintf(fid,',%0.3f',std(aa));
	else
	  fprintf(fid,',');
	end
      end
    end
  end
  

%print the std/mean
  fprintf(fid,'\nstd/mean');
 
%  if isfield(conc(1),'suj_age'),fprintf(fid,',');end
  if isfield(conc(1),'suj_age')
        fprintf(fid,',%0.1f',std(sa)./mean(sa));
  end


  for kf = 1:length(field_list)
    if ~strcmp(field_list{kf},'suj_age')
      aa = getfield(conc(npool),field_list{kf});
      if isnumeric(aa)
	aa(isnan(aa))=[];
	fprintf(fid,',%0.3f',std(aa)./mean(aa));
      else
	fprintf(fid,',');
      end
    end
  end

  
  fprintf(fid,'\n');
  
end

fprintf(fid,'\n\n\n');
 