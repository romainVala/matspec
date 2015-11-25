%global sumfidM sumTotalraw
%Step #1: obtain location of second creatine peak and intensity of it. 
%Step #2: obtain rough fit based on absolute intensities
%Input sumfidM sumTotalraw np sw
%Output sumfidM1(alligned database) AmListIni
function [AmListIniD,resnorm,output] = FAllignDiffGM(dcy,sumfidMD1,AmListIni);
global np sw sfrq  ZeroFill XpointsD sumfftIni 
%if isempty(whos('global','np'))
%          global np
%          np = input('Enter length of fid (points(real+imaginary)) \n')
%     end
     
%     if isempty(whos('global','sw'))
%          global sw
%          sw = input('Enter sweep width in Hz \n')
%     end
     
 %    if isempty(whos('global','sfrq'))
 %         global sfrq
 %         sfrq = input('Enter freqcy in Hz per 1 ppm \n')
 %    end

clear AmListIniD
timeD=0:1/sw:(np/2)*1/sw-1/sw;

fftExp=fliplr(fftshift(fft(dcy,ZeroFill)));


sumfftIni1=zeros(1,ZeroFill);
fida=zeros(1,size(sumfidMD1,2));
 PhaseFactor=exp(sqrt(-1)*AmListIni(4,1));
 FirstPoint=AmListIni(5,1);

 for m=1:size(sumfidMD1,1);
 
   
 FreqFactor=exp(sqrt(-1)*2*pi*AmListIni(3,m)*timeD );
    fida=AmListIni(1,m).*sumfidMD1(m,:).*FreqFactor.*PhaseFactor.*exp(-timeD./AmListIni(2,m));
     fida=[fida(1,1)*FirstPoint fida(1,2:end)];
 % FreqFactor=1;
 %    sumfidM1(m,:)=sumfidM1(m,:).*exp(-sqrt(-1)*2*pi*AmListIni(3,1)*timeD);   
     sumfftIni1=sumfftIni1+fliplr(fftshift(fft(fida,ZeroFill)));
     
 end;



figure;plot(real(fftExp));
hold
plot(real(sumfftIni1),'r')


%[XpointsD,YpointsD]=ginput(2);
%XpointsD=round(XpointsD)

XpointsD(1) = 14164;%13873;
XpointsD(2) = 15118;%15615;

ylim = get(gca,'ylim');
plot([XpointsD(1),XpointsD(1)],ylim,'k')
plot([XpointsD(2),XpointsD(2)],ylim,'k')


%now approximate the initial values to initiate AmListStart
%sumfidTemp=abs(fftshift(fft(sum(sumfidMD1,1).*exp(-timeD/0.100))));



%This is the part that does the raw adjustments by fitting the absolute
%value data
%options=optimset('Display','off','MaxFunEvals',1000,'TolX',10^-12,'TolFun',10^-20);

%lsqcurvefit(@FitIni,AmListStartIni,timeD,fliplr(abs(fftshift(fft(dcy)))),[
%1;0.010;0],[10^23;0.400;3 ],options)
%Prepare initial feeding
%AmListStartIni=[ones(1,size(sumfidM,1));0.1*ones(1,size(sumfidM,1));0.0*ones(1,size(sumfidM,1))]



%AmListStartIni=[1 1 10 1 6 5 1 7 2 0.2;
%    0.060*ones(1,size(sumfidMD,1));
%    0.050*ones(1,size(sumfidMD,1));
%    0.0*ones(1,size(sumfidMD,1))];
%AmListStartIni=[5;0.160;0.090;0];
%lowb=[5;0.150; 0.075;-5]
%upperb=[10;0.180;0.100;5]

%AmListStartIni=AmListIni;
%Setting low bound limit
lowb=AmListIni;
lowb(1,:)=0.05*AmListIni(1,1);

lowb(2,:)=AmListIni(2,1)*0.2; 


lowb(3,:)=-10; %freq

lowb(4,:)=AmListIni(4,1)-0.3; %phase
lowb(5,:)=0.9;

%Setting low bound limit
upperb=AmListIni;
upperb(1,:)=6*AmListIni(1,1);
upperb(2,:)=2*AmListIni(2,1);
%upperb(2,:)=1.5*(AmListIni(2,2)+AmListIni(2,3))/2; %This is an average of creatine and choline linewidths

%upperb(3,:)=1.1*AmListIni(3,1);%This is an average of creatine and choline linewidths
%upperb(4,:)=1.1*AmListIni(4,:);
upperb(3,:)=10;
upperb(4,:)=AmListIni(4,1)+0.5; %phase
upperb(5,:)=2;


options=optimset('Display','final','MaxFunEvals',1000,'MaxIter',1000,'TolX',10^-20,'TolFun',10^-20);

%disp('this is low conc')
%lowb(1,:)
%disp('this is high conc')
%upperb(1,:)
%disp('this is low t2')
%lowb(2,:)
%upperb(2,:)

tic
[AmListIniD,resnorm,residual,exitflag,output]=lsqcurvefit(@FitIniDGM,AmListIni,timeD,[real(fftExp(XpointsD(1):XpointsD(2))) imag(fftExp(XpointsD(1):XpointsD(2)))],lowb,upperb,options,sumfidMD1);

%[AmListIniD,resnorm,residual,exitflag,output]=lsqcurvefit(@FitIniD,AmListIni,timeD,real(fftExp(XpointsD(1):XpointsD(2))));



toc

AmListIniD(1,1)
AmListIniD(2,1)

%for i=1:size(sumfidM,1)
%sumfidM1(i,:)=sumfidM1(i,:).*exp(sqrt(-1)*2*pi*AmListIni(3,1).*timeD);
%end;
 PhaseFactor=exp(sqrt(-1)*AmListIniD(4,1));
 
sumfftIni=zeros(1,ZeroFill);
FirstPoint=AmListIniD(5,1);
 
for m=1:size(sumfidMD1,1);
    
   
    FreqFactor=exp(sqrt(-1)*2*pi*AmListIniD(3,m)*timeD );
 % FreqFactor=1;
 %    sumfidM1(m,:)=sumfidM1(m,:).*exp(-sqrt(-1)*2*pi*AmListIni(3,1)*timeD);
 sumfidIni=AmListIniD(1,m).*sumfidMD1(m,:).*FreqFactor.*PhaseFactor.*exp(-timeD./AmListIniD(2,m));
     sumfidIni=[sumfidIni(1)*FirstPoint sumfidIni(2:end)];
 sumfftIni=sumfftIni+fliplr(fftshift(fft(sumfidIni,ZeroFill)));
        
 end;
 

 
%FrequencyScale=(-sw/2:sw/(ZeroFill):sw/2-sw/(ZeroFill))/sfrq-4.65;
%figure;plot(FrequencyScale,real(sumfftIni),'r');hold
%title('Red is database')
%plot(FrequencyScale,real(fliplr(fftshift(fft(dcy,ZeroFill)))),'k')
%hold off





