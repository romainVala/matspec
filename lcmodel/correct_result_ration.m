function co=correct_result_ration(ci,field_change,field_ref,scale_fac)

if ~exist('scale_fac')
  scale_fac=1;
end

if isempty(field_change)
  field_change = find_metab_list(ci);
end

for npool = 1:length(ci)
  cpool = ci(npool);
  
  cref = getfield(cpool,field_ref);
  
  for k=1:length(field_change)
    cc = getfield(cpool,field_change{k});
    cc = cc./cref * scale_fac;
    cpool = setfield(cpool,field_change{k},cc);
  end
  co(npool) = cpool;
end
