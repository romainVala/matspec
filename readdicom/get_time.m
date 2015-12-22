function [h,m,s,ms] = get_time(t)

for k=1:length(t)

  h(k) = floor(t(k)/3600);
  mm = t(k)/3600 -h(k);
  m(k) = floor(mm*60);
  ss = mm*60-m(k);
  s(k) = floor(ss*60);
  ms(k) = floor((ss*60-s(k))*1000);
  
end

