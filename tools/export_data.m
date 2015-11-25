for k=1:size(P,1)                                         
 [p f] = fileparts(P(k,:))                                  ;
 [p f] = fileparts(p);                                      
 mkdir(fullfile('/home/romain/tmp/MM_for_g',f))                      
 cmd=['!cp -pr '  P(k,:) ' '  fullfile('/home/romain/tmp/MM_for_g',f)];
 eval(cmd)
end
