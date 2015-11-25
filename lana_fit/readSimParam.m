function [frequency,sw,ws,NA,NR]= readSimParam(filename)
%if need to create ascii file uncomment the text below
%FileOut=[filename '.txt']
fid=fopen(filename,'r','l');
%fid1 = fopen(FileOut,'w');
m=0;
k=[];
ppp='ASCCONV BEGIN';
ppp1='ASCCONV END';
pppName='sRXSPEC.alDwellTime';
pppName1='sTXSPEC.asNucleusInfo[0].lFrequency';
pppName2='sPrepPulses.ucWaterSat';    
pppName3='lAverages';
pppName4='lRepetitions';
NR=0;

while 1
   
    tline = fgetl(fid);
%    if (strcmp(line,ppp))
           m=strfind(tline, ppp);
           if m;
               positionm = ftell(fid);
 %positionm tells when ascii data describing acquisition parameters begin              
           %  if ~ischar(tline), 
                  while isempty(k);
                   
                  tline = fgets(fid);
                  
                
                k=strfind(tline, ppp1);
                  
                  
 %              fprintf(fid1,'%5.150s',tline);
                  
                 
                          if ~isempty(k)
                              positionk = ftell(fid);
%positionk tells when ascii file ends
%                            fclose(fid1); 
                             return
                          end  
                            
                          
                          %new portion that finds the value of dwell  
                                    if (strcmp(tline(1:30),pppName1(1:30)));
                           
                                          m=strfind(tline, '=');
                                             frequency=str2num(tline(m+1:end));
                            
                         
                                    end
                       
                                     if (strcmp(tline(1:18),pppName(1:18)));
                              
                                         m=strfind(tline, '=');
                                         dwelltime=str2num(tline(m+1:end));
                                         sw=1/dwelltime*10^9;
                         
                                     end
                                     if (strcmp(tline(1:18),pppName2(1:18)));
                              
                                         m=strfind(tline, '=');
                                   %      ws=str2num(tline(m+1:end))
                                         ws=(tline(m+1:end));
                                         ws=str2num(ws(4));
                                         
                         
                                     end
                                     
                                      if (strcmp(tline(1:9),pppName3(1:9)));
                           
                                          m=strfind(tline, '=');
                                             NA=str2num(tline(m+1:end));
                            
                         
                                      end
                                    
                                       if (strcmp(tline(1:10),pppName4(1:10)));
                           
                                          m=strfind(tline, '=');
                                             NR=str2num(tline(m+1:end));
                            
                         
                                    end
                                      
                          
                  end
           
           end
 
end
%if isempty(NR)
%    NR=1;
%end    

fclose(fid);
