function c=concat_conc(c1,c2,prefix)

if ~exist('prefix')
  prefix=''
end

if length(c1)~=length(c2)
  error('differenct pool number')
end

for npool = 1:length(c1)
  
  cc = c1(npool);
  
%  for kk=1:length(cc.suj)
%    if ~strcmp(cc.suj{kk},c2(npool).suj{kk})
%      fprintf('arrrgggg')
%      keyboard
%    end
%  end
  
  
  name = fieldnames(c2(npool));
  name(1:2)='';
  
  for k=1:length(name)
    val = getfield(c2(npool),name{k});
    cc = setfield(cc,[ name{k},prefix],val);
  end

  c(npool) = cc;

  
end
