function fi=change_exam_number(fi)

cur_suj_name = fi(1).sujet_name;
ns=1;

exa = fi(1).examnumber;
exanum = str2num(exa(2));

fi(1).examnumber='N1';

for k=2:length(fi)
  
%  exa = fi(k).examnumber;
%  exanum = str2num(exa(2));
  
  if strcmp(fi(k).sujet_name,cur_suj_name)
    ns=ns+1;
    
  else
    ns = 1;
    cur_suj_name = fi(k).sujet_name;
  end
  
  fi(k).examnumber = ['N' num2str(ns)];

%  if exanum>=2
%    fi(k).sujet_name(end-2:end) = '';
%    keyboard
%  end
  
  
end
