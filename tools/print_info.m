function print_info(fid,filename)

fp = fopen(filename,'w');

suj=char(fid.sujet_name);
[suj,ind]=sortrows(suj);
fid=fid(ind);
[B,I,J] = unique(suj,'rows');

fprintf(fp,'Patient_name,iscompleted,numSer,MC L,MC R, BG L , BG R , OCC , OCC MM , CER , MC L E2 , MC R E2 , BG L E2 , BG R E2 \n');  

for k=1:size(B,1) 
  ff = fid(J==k);
  
  sf(1)=      find_ser_descr(ff,'MC L','E1E3');
  sf(2)=      find_ser_descr(ff,'MC R','E1E3');
  sf(3)=      find_ser_descr(ff,'BG L','E1E3');
  sf(4)=      find_ser_descr(ff,'BG R','E1E3');

  sf(5)=     find_ser_descr(ff,'OCC ref','E1E3E2E4');
  sf(6)=     find_ser_descr(ff,'MMref','E1E3E3E4');
  sf(7)=      find_ser_descr(ff,'CER','E1E3E2E4');
  
  sf(8)=      find_ser_descr(ff,'MC L','E2E4');
  sf(9)=      find_ser_descr(ff,'MC R','E2E4');
  sf(10)=      find_ser_descr(ff,'BG L','E2E4');
  sf(11)=      find_ser_descr(ff,'BG R','E4E4');  

  if sf(6)==0; sf(6) = find_ser_descr(ff,'MM ref','E1E3E4E2');end
  
  iscompleted = find_ser_descr(ff,'ref','E4');
    
  fprintf(fp,'%s,%d,%d,',ff(1).sujet_name,iscompleted,length(ff));
  
  if length(ff)~=sum(sf)
    warning('missing Series')
    ff(1).sujet_name
    c=char(ff.SerDescr);
    cc=char(ff.examnumber);
    [c,cc]
  end

  
  fprintf(fp,'%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n',sf(1),sf(2),sf(3),sf(4),sf(5),sf(6),sf(7),sf(8),sf(9),sf(10),sf(11));

end
  
if 0

fprintf(fp,'Patient_name,date,Exam num,Series_description,water linewidth\n');



for k=1:size(B,1) 
  ff = fid(J==k);

  fprintf(fp,'%s,%s,%s,%s,%f\n',ff(1).sujet_name,ff(1).studydate,ff(1).examnumber,ff(1).SerDescr,ff(1).watter_widht);

  for kk=2:length(ff)
    fprintf(fp,' , %s ,%s ,%s ,%f\n',ff(kk).studydate,ff(kk).examnumber,ff(kk).SerDescr,ff(kk).watter_widht);
  
  end
end

end

fclose(fp);