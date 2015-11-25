function co=expand_dysto_conc(c,contract)

if ~exist('contract')
  contract=0;
end

if contract
  co = c;
  co([1:2;11:12]) = '';
else
  co = [c(1),c(3),c(1:8),c(9),c(11),c(9:end)] ;
end