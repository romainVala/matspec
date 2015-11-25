function sumFidIni_w = FitWatLor(AmListIni,timeD);

global  sw waterM1 sfrq



np=size(timeD,2)*2;



sumFidIni_w=zeros(1,np/2);

RtermLor=exp(-timeD/AmListIni(2));

FreqFactor=exp(sqrt(-1)*2*pi*AmListIni(3)*timeD );
PhaseFactor=exp(sqrt(-1)*AmListIni(4));
FirstPoint=AmListIni(5);


   
        
%sumFidIni_w=real(fliplr(fftshift(fft ( AmListIni(1).*waterM1.*RtermLor.*RtermGau.*FreqFactor.*PhaseFactor) ))); %.*exp(-sqrt(-1)*2*pi*AmListIni(3,1)*timeD
   % sumfftF(k,:)=sumfftF(k,:)+fliplr(fftshift(fft(AmList(1,m).*sumfidDB(newindex,:).*exp(-timeD/AmList(2,NumberofMet)))));
 % sumFidIni_w1=real(AmListIni(1).*waterM1.*RtermLor.*RtermGau.*FreqFactor.*PhaseFactor) ;
 % sumFidIni_w2=imag(AmListIni(1).*waterM1.*RtermLor.*RtermGau.*FreqFactor.*PhaseFactor) ;
 % sumFidIni_w=[sumFidIni_w1 sumFidIni_w2 ];
  
sumFidIni_w=real(fliplr(fftshift(fft ( AmListIni(1).*waterM1.*RtermLor.*FreqFactor.*PhaseFactor,8192*4) )));
%sumFidIni_w=real(fliplr(fftshift(fft ( AmListIni(1).*waterM1.*RtermLor.*RtermGau.*FreqFactor.*PhaseFactor) )));
 sumFidIni_w=[sumFidIni_w(1)*FirstPoint sumFidIni_w(2:end)];