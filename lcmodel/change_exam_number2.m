function fi=change_exam_number(fi)

cur_suj_name = fi(1).sujet_name;
ns=1;

exa = fi(1).examnumber;
exanum = str2num(exa(2));

fi(1).examnumber='E1N1';
fi(1).sujet_name(1:19)='';
  
for k=2:length(fi)
  
  exa = fi(k).examnumber;
  exanum = str2num(exa(2));
  
  if strcmp(fi(k).sujet_name,cur_suj_name)
    ns=ns+1;
    
  else
    ns = 1;
    cur_suj_name = fi(k).sujet_name;
  end
  
  fi(k).examnumber = [exa 'N' num2str(ns)];


  if exanum>=2
    fi(k).sujet_name(end-2:end) = '';
%    keyboard
  end
  fi(k).sujet_name(1:19)='';
  
end


if 0
  %split fids met

  for nbser = 1:length(fids)
    
    fo(2 * nbser -1 ) = fids(nbser);
    fo(2 * nbser -1 ).fid = fids(nbser).fid(:,1:126); 
    
    fo(2 * nbser) = fids(nbser);
    fo(2 * nbser).fid = fids(nbser).fid(:,127:252); 
    
    
  end
  
  %split water
  for k =1:6
    
    ff((k-1)*6+1).water_ref = w((k-1)*3 +1);
    ff((k-1)*6+2).water_ref = w((k-1)*3 +1);
    ff((k-1)*6+3).water_ref = w((k-1)*3 +1);
    ff((k-1)*6+4).water_ref = w((k-1)*3 +2);
    ff((k-1)*6+5).water_ref = w((k-1)*3 +2);
    ff((k-1)*6+6).water_ref = w((k-1)*3 +3);    
    
  end
 
  ff(37).water_ref = w(19);
  ff(38).water_ref = w(19);
  ff(39).water_ref = w(19);
  ff(40).water_ref = w(20);

  for k = 8:30
    ff((k-1)*6-1).water_ref = w((k-1)*3 );
    ff((k-1)*6).water_ref = w((k-1)*3 );
    ff((k-1)*6+1).water_ref = w((k-1)*3 );
    ff((k-1)*6+2).water_ref = w((k-1)*3 +1);
    ff((k-1)*6+3).water_ref = w((k-1)*3 +1);
    ff((k-1)*6+4).water_ref = w((k-1)*3 +2);    
   
  end
  
 
  for ns = 1:length(c)
    %    cc(ns) = c(ns);
    if ns==1
    
      cc(ns).fcsf(1) = c(ns).fcsf(1);
      cc(ns).fcsf(2) = c(ns).fcsf(1);
      cc(ns).fcsf(3) = c(ns).fcsf(1);
      cc(ns).fcsf(4) = c(ns).fcsf(2);
      cc(ns).fcsf(5) = c(ns).fcsf(2);
      cc(ns).fcsf(6) = c(ns).fcsf(3);

      cc(ns).fcsf(7) = c(ns).fcsf(4);
      cc(ns).fcsf(8) = c(ns).fcsf(4);
      cc(ns).fcsf(9) = c(ns).fcsf(4);
      cc(ns).fcsf(10) = c(ns).fcsf(5);
   
      cc(ns).fcsf(11) = c(ns).fcsf(6);
      cc(ns).fcsf(12) = c(ns).fcsf(6);
      cc(ns).fcsf(13) = c(ns).fcsf(6);
      cc(ns).fcsf(14) = c(ns).fcsf(7);
      cc(ns).fcsf(15) = c(ns).fcsf(7);
      cc(ns).fcsf(16) = c(ns).fcsf(8);
     
    else
      for k=1:3
	cc(ns).fcsf((k-1)*6 +1) = c(ns).fcsf((k-1)*3 +1);
	cc(ns).fcsf((k-1)*6 +2) = c(ns).fcsf((k-1)*3 +1);
	cc(ns).fcsf((k-1)*6 +3) = c(ns).fcsf((k-1)*3 +1);
	cc(ns).fcsf((k-1)*6 +4) = c(ns).fcsf((k-1)*3 +2);
	cc(ns).fcsf((k-1)*6 +5) = c(ns).fcsf((k-1)*3 +2);
	cc(ns).fcsf((k-1)*6 +6) = c(ns).fcsf((k-1)*3 +3);
      end
    end
    
  end
  
end
