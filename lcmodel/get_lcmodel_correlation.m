function get_lcmodel_correlation(d)

for k=1:length(d)
  
  fps=get_subdir_regex_files(d{k},'.*PRINT$');
  fps = cellstr(char(fps));
  
  for kk=1:length(fps)
  
    fileid=fopen(fps{kk});

    go_after('Correlation',fileid)
    go_after('Correlation',fileid)
    go_after('Glu',fileid)
    go_after('Glu',fileid)
    go_after('Glu',fileid)
    
    l=fgetl(fileid);
    l=str2num(l);
    
    c(kk) = l(end);
    
  end
  
  fprintf('%s\n',d{k})
  c
  clear c
  
end


function go_after(str,fileid)
s=[];
while isempty(findstr(s,str))
    s=fscanf(fileid,'%s',1);
end

function f=find_float_after(str,fileid)

c=[];
while isempty(findstr(c,str))
  c=fscanf(fileid,'%s',1);
end

c(1:length(str))='';

if isempty(c)
  %read the float value
  f = fscanf(fileid,'%f',1);
else
  f = str2num(c)
end
