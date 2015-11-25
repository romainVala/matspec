%global sumfidM sumTotalraw
%Step #1: obtain location of second creatine peak and intensity of it. 
%Step #2: obtain rough fit based on absolute intensities
%Input sumfidM sumTotalraw np sw
%Output sumfidM1(alligned database) AmListIni
function [DiffFreqHz_Main] = FAllignLorG(dcy,sumfidM);
global np sw sfrq sumfidM1 ZeroFill timeD ExpSpecStart ExpSpecEnd PhaseAll FreqAll sumfftIni AmListStartIni
if isempty(whos('global','np'))
          global np
          np = input('Enter length of fid (points(real+imaginary)) \n')
     end
     
     if isempty(whos('global','sw'))
          global sw
          sw = input('Enter sweep width in Hz \n')
     end
     
     if isempty(whos('global','sfrq'))
          global sfrq
          sfrq = input('Enter freqcy in Hz per 1 ppm \n')
     end
%RefFreq=3.027

%RefFreq=8.446

%RefFreq=3.769

RefFreq=2.008;
%ZeroFill=np*2;
ZeroFill=8192*2;

%PhaseAll is 1, when the same phase, phi is imposed on all the metabolites,
%PhaseAll is 0, when each metabolite has its own phase

np=size(dcy,2)*2;
timeD=0:1/sw:(np/2)*1/sw-1/sw;
FrequencyScale=(-sw/2:sw/ZeroFill:sw/2-sw/ZeroFill)/sfrq-4.69;

fftExp=fftshift(fft(dcy,ZeroFill));
%figure;plot(abs(fftExp));
%[Xpoints,Ypoints]=ginput(2);
%Xpoints=round(Xpoints);
Xpoints(1)=1;
Xpoints(2)=ZeroFill/4;
%CrInt= absolute intensity of the reference peak, CrFreq -location in
%points of the reference
CrInt=max(  abs(fftExp(Xpoints(1):Xpoints(2))));

CrFreq=find(abs(fftExp)==CrInt);

%This portion assignes the spectral limits of fitting
PointsPerPpm=ZeroFill*sfrq/sw;

%Enter fitting limits in ppm
LimitBeginPPM=1;
LimitEndPPM=4;

ExpRef=ZeroFill-CrFreq;
ExpSpecStart=round(ExpRef-PointsPerPpm*(LimitEndPPM-RefFreq)); %these are the points
ExpSpecEnd=round(ExpRef-PointsPerPpm*(LimitBeginPPM-RefFreq));


%point of reference (Cr, second peak) in the the database
pointCrDB=floor(ZeroFill*sfrq*RefFreq/sw)+ZeroFill/2;

%DiffFreqHz=round((sw/ZeroFill)*717);
DiffFreqHz_Main=round((sw/ZeroFill)*(pointCrDB-CrFreq));





