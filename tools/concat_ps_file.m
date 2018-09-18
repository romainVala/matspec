function concat_ps_file(d)

cwd=pwd;

for k=1:length(d)
  dd=d{k};
  cd(dd);
  
  [p f] = fileparts(dd);
  [p f] = fileparts(p);
  [p pool] = fileparts(p);

  pool = [pool,'_',f];
  
  
  fps=get_subdir_regex_files(d{k},{'.*PS$','.*ps$'});
  fps=char(fps);
  
  cmdmerge = sprintf('LD_LIBRARY_PATH= ;psmerge -o%s.ps ',pool);
  
  for nbf=1:size(fps,1)
    cmd = sprintf('LD_LIBRARY_PATH= ;psselect -p1 %s suj%d.ps',fps(nbf,:),nbf);
%    cmd = sprintf('psselect -p7 %s suj%d.ps',fps(nbf,:),nbf);
    unix(cmd);
    cmdmerge = sprintf('%s suj%d.ps ',cmdmerge,nbf);

  end
  
  unix(cmdmerge);
  
  cmdpdf = sprintf('LD_LIBRARY_PATH= ps2pdf %s.ps',pool);
  unix(cmdpdf);
  
  for nbf=1:size(fps,1)
    delete(['suj' num2str(nbf) '.ps'])
  end
  
  movefile([pool '.ps'],'../..')
  movefile([pool '.pdf'],'../..')  
  
  char(fps)
  
end

cd(cwd)
