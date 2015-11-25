function [f1 f2 ] = split_fid(f)

for k=1:length(f)
  exa = f(k).examnumber;
  
  switch exa
    case {'E1','E3'}
      if ~exist('f1')
	f1(1) = f(k);
      else
	f1(end+1) = f(k);
      end
      
      
    case {'E2','E4'}
      if ~exist('f2')
	f2(1) = f(k);
      else
	f2(end+1) = f(k);
      end

    end
  end
  
    