function do = r_mkdir(d,new_dir)

if isstr(d)
  d = repmat({d},size(new_dir));
end

if isstr(new_dir)
  new_dir = repmat({new_dir},size(d));
end


if any(size(d)-size(new_dir))
  error('rrr \n the 2 cell input must have the same size\n')
end

  
for k=1:length(d)
  do{k} = fullfile(d{k},new_dir{k});
  if ~exist(do{k})
    mkdir(do{k});
  end
  
end  
