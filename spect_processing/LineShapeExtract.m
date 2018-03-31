function [mConAmpCor mSPhase mT2used] = LineShapeExtract(fid,sw)
% Provides amp and phase corrections from water only signal
% ASSUMES APODIZATION USED FIRST (Dataa first point has been halved) *******
% Checks for excessive corrections 

% Assumes files already added (or a single file)containing only water
% FID data is dcy; sw known in Hz
dcy=fid;

% Set any parameters (lwfact for narrower metab lines,
% aCorrMax for maximum amplitude correction)
lwfact = 1.2;
aCorrMax = 2.0 ;

% Time points
t = (1/sw)*(0:length(dcy)-1) ;

% Work with absolute mode to obtain T2 estimate
% Fits to beginning and end of FID (absolute mode)

% Restore first data point for Dataa
Dataa = abs(dcy) ;
%Dataa(1) = 2*Dataa(1) ;
Dataa(1) = Dataa(1) ;

% Filter FID to minimize noise
Dataa = sgolayfilt(sgolayfilt(Dataa,3,15),3,13) ;

% Set regions to fit (Skip first 10 pts)
mMax1 = Dataa(11) ;
mMin1 = 2*mMax1/3 +  mMax1/10 ;
mMax2 = mMax1/3 ;
mMin2 = mMax1/6 ;

% Find value for first T2 (=p(1))
index_mMin1 = find(Dataa > mMin1);
mExp1=Dataa(11:index_mMin1(end));
timeFit1=t(11:index_mMin1(end));

y = log(mExp1) ;
x = timeFit1 ;
p = polyfit(x,y,1) ;

clear x y 
 % x = lsqcurvefit(@(x,timeFit1)x(1)*exp(-timeFit1/x(2)),[mMax1 0.100],timeFit1,mExp1)

 % Find value for first T2 (=x(2))
index_mMin2a=find(Dataa > mMin2);
index_mMin2b=find(Dataa < mMax2);
mExp2=Dataa(index_mMin2b(1):index_mMin2a(end));


timeFit2=t(index_mMin2b(1):index_mMin2a(end));
if length(mExp2)>40
    mExp2=mExp2(1:40);
    timeFit2=timeFit2(1:40);
end

% Find value for second T2 (=q(1))
y = log(mExp2) ;
x = timeFit2 ;
q = polyfit(x,y,1) ;

clear x y 

%Now obtain T2 value to use
mT21 = -1/p(1) ;
mT22 = -1/q(1) ;


%find noise by Lana
%start
%noisereg=mean(Dataa(end-200:end))
%a=find(Dataa>5*noisereg);

%y = log(Dataa) ;
%x = t ;
%z = polyfit(x(1:a(end)),y(1:a(end)),1) ;
%a(end)
%mT2=1/z(1)
%end of lana

mk = mT21/mT22 ;
mexp = 1 - mk ;
if mT21 > mT22
    mT2used = lwfact*mT21;
else
    mT2used = lwfact*mT22*mk.^mexp; 
end


% *********************************

% Divide ideal into actual to obtain amplitude correction (mConAmpCor)
% Phase correction is just negative of dcy phase (mSPhase)

mSideal= exp(-t/mT2used) ;
aMs = max(Dataa) ;
mConAmpCor = aMs*mSideal./Dataa  ;

% ***********************************************************
% ***********************************************************



% Print linewidth associated with mT2used
mT2used;
linewidth = 1/(pi*mT2used) ;


mSPhase = unwrap(-angle(dcy)) ;

% Filter amp and phase, and limit amp
mConAmpCor=sgolayfilt(sgolayfilt(mConAmpCor,5,11),4,9) ;
mSPhase=sgolayfilt(mSPhase,3,9);

npts1=size(t) ;
npts2=1.4*(1:1:npts1(2))/npts1(2);
mExpMul=exp(-npts2.^12) ;

mConAmpCor = mConAmpCor.*mExpMul ;


% UNCOMMENT BELOW FOR PLOTS to check routine ********************

% figure ; plot(t, Dataa,'k') ;
% hold on ;
% plot(t, real(dcy),'b');
% plot(t, imag(dcy), 'r');
% title('Magnitude (black), Real (blue), and Imag (red) FIDs') ;
% 
% figure; plot(timeFit1,abs(mExp1)); 
% hold ;
% plot(timeFit1,exp(p(2))*exp(-timeFit1/mT21),'r') ;
% title(['T2 = ' num2str(mT21) ';  T2used = ' num2str(mT2used)]) ;
% 
% figure; plot(timeFit2,abs(mExp2)); 
% hold ;
% plot(timeFit2,exp(q(2))*exp(-timeFit2/mT22),'r') ;
% title(['T2 = ' num2str(mT22) ';  T2used = ' num2str(mT2used)]) ;
% 
% figure; plot(mConAmpCor) ;
% title('Amplitude Correction') ;
% 
% figure; plot(mSPhase) ;
% title('Phase Correction') ;

% **************************************************


clear timeFit1 timeFit2 Dataa


% End of routine
