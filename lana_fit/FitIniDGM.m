function sumfftIni = FitIniDGM(AmListIni,timeD,sumfidMD1);
global   sw  XpointsD ZeroFill
global ExpSpecStart ExpSpecEnd 
np=size(timeD,2)*2;




if isempty(sumfidMD1)
    disp('database is empty, use sumfidM=FcreateDBFID function')
    return
end


%NEED TO ENTER NUMBER OF METABOLITES
NumberofMet=size(sumfidMD1,1);
%NEED TO ENTER NUMBER OF LOOP ITERATIONS


%Reshape database
%Am is each metabolite concentration
%AmList1 is the list of the intensities for each metabolite (maybe taken
%from literature of relative ratios). Need to know the order of metabolites
%in the database. 
%[glu mI Naa cre cho gln tau naag scyllo pk000]
%AmList=[3 1 3 2 0.5 0.5 0.2 0.2 0.2 1];

%AmList1=[1 0.7 1.0 0.7 0.25 0.1 0.1 0.05 1]
%tau=0:1/sw:TauDimSize*(1/sw)-1/sw;
%AmList=[3.75 3;1 0.040]

sumFidIni=zeros(1,size(sumfidMD1,2));
sumfftIni=zeros(1,ZeroFill);
FirstPoint=AmListIni(5,1);


    for m=1:NumberofMet;
        FreqFactor=exp(sqrt(-1)*2*pi*AmListIni(3,m)*timeD );
        
    
        sumFidIni=AmListIni(1,m).*exp(sqrt(-1)*AmListIni(4,1)).*sumfidMD1(m,:).*exp(-timeD./AmListIni(2,m)).*FreqFactor;
        sumFidIni=[sumFidIni(1,1)*FirstPoint sumFidIni(1,2:end)];
        sumfftIni=sumfftIni+(fliplr(fftshift(fft(sumFidIni,ZeroFill))));
       % sumfftIni=sumfftIni+real(fliplr(fftshift(fft ( AmListIni(1,m).*exp(sqrt(-1)*AmListIni(4,1)).*sumfidMD1(m,:).*exp(-timeD./AmListIni(2,m)).*FreqFactor,ZeroFill) ))); %.*exp(-sqrt(-1)*2*pi*AmListIni(3,1)*timeD
   % sumfftF(k,:)=sumfftF(k,:)+fliplr(fftshift(fft(AmList(1,m).*sumfidDB(newindex,:).*exp(-timeD/AmList(2,NumberofMet)))));
    end;
  
    
    
    sumfftIni=[real(sumfftIni(XpointsD(1):XpointsD(2))) imag(sumfftIni(XpointsD(1):XpointsD(2)))] ;
    
%BaseLinePoint=sumfftIni(1,end);
    

   
%This is the part that reduces the spectrum to just metabolites
%sumfftF=sumfftF(:,ExpSpecStart:ExpSpecEnd);
%dim1=size(sumfftF);
%This part makes it identical to aexp and makes it one spectrum with
%dimensions of (30-5)
%sumFid=reshape(real(sumfftF)',[dim1(1)*dim1(2) 1]);

 