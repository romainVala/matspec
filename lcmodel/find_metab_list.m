function metname = find_metab_list(field_list)

if isstruct(field_list)
  oo = field_list;
  field_list=fieldnames(field_list);
end


k=0;

for nf=1:length(field_list)
  ind = findstr(field_list{nf},'SD');
  if ind
    k=k+1;
    metname{k} = field_list{nf}(3:end);
  end
end
    

if ~exist('metname')
  fprintf('Taking All numeric field in account\n')

  for nf=1:length(field_list)

    aa = getfield(oo(1),field_list{nf});

    if isnumeric(aa)
      k=k+1;
      metname{k} = field_list{nf};
    end
  end

end
