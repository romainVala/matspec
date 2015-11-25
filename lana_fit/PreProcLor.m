function [water_contrib,output] = PreProcLor(dcy,DiffFreqHz_Main);
global np sfrq  sw waterM1 

np=size(dcy,2)*2;
timeD=0:1/sw:(np/2)*1/sw-1/sw;
waterM=2*exp(sqrt(-1)*(2*pi*sfrq*4.65*timeD));
%DiffFreqHz_Main=789;

waterM1=waterM.*exp(-DiffFreqHz_Main*2.00*pi*timeD*sqrt(-1));


%size(timeD);
%DiffFreqHz_Main;
%These are the starting parameters:1)amplitude, 2) Loren 3) Freq.
%Offset, 4) Phase offset 5) Multiplication of the first point to control
%the baseline
AmListStartIni_wat=[10^5;0.0800;1;0;1];
%for fitting naa water  
AmListStartIni_wat=[10^5;1;1;0;1];

lowb=[AmListStartIni_wat(1)*0.05;
    AmListStartIni_wat(2)*0.1;-AmListStartIni_wat(3)*50;-2*pi;0.1*AmListStartIni_wat(5)];

upperb=[AmListStartIni_wat(1)*10000 ;
    AmListStartIni_wat(2)*5;AmListStartIni_wat(3)*50;2*pi;2*AmListStartIni_wat(5)];

options=optimset('MaxFunEvals',1000,'MaxIter',1000,'TolX',10^-14,'TolFun',10^-14);

%size(timeD)
%size(dcy)
[AmListIni_wat,resnorm, output]=lsqcurvefit(@FitWatLor,AmListStartIni_wat,timeD,real(fliplr(fftshift(fft(dcy,8192*4)))),lowb,upperb,options);


%[AmListIni_wat,resnorm, output]=lsqcurvefit(@FitWat,AmListStartIni_wat,timeD,[real(dcy) imag(dcy)],lowb,upperb,options);
%After obtaining the coefficients, reconstruct the water contribution
%(water_contrib), which is an fid that can be subtracted from "y" time
%domain data
output=AmListIni_wat;

water_contrib=zeros(1,np/2);

AmpFactor=AmListIni_wat(1);
RtermLor=exp(-timeD/AmListIni_wat(2));

FreqFactor=exp(sqrt(-1)*2*pi*AmListIni_wat(3)*timeD );
PhaseFactor=exp(sqrt(-1)*AmListIni_wat(4));
FirstPoint=AmListIni_wat(5);


%waterM=2*exp(sqrt(-1)*(2*pi*sfrq*4.65*timeD));
%DiffFreqHz_Main=789;

%waterM1=waterM.*exp(-DiffFreqHz_Main*2.00*pi*timeD*sqrt(-1));

        

water_contrib=AmpFactor*waterM1.*RtermLor.*FreqFactor.*PhaseFactor;


water_contrib=[water_contrib(1)*FirstPoint water_contrib(2:end)];





