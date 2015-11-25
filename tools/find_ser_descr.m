function [found] = find_ser_descr(f,desc,exa)


found=0;

for k=1:length(f)
  
  if findstr(desc,f(k).SerDescr)
    if findstr(exa,f(k).examnumber)
      found=found+1;
    end
  end
  
end  

  