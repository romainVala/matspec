function [ww] = find_ser_descr_watter_width(f,desc,exa)


found=0;
ind=[];
ww=0;

for k=1:length(f)
  
  if findstr(desc,f(k).SerDescr)
    if findstr(exa,f(k).examnumber)
      found=found+1;
      ind(found) = k;
    end
  end
  
end  
  

for k=1:length(ind)
  ww(k) = f(ind(k)).watter_widht;
end

if length(ww)>1;
  fprintf('taking the mean :%0.3f  %0.3f   %0.3f \n',mean(ww),ww(1),ww(2))
end

ww=mean(ww);
