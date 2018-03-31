function fid_corr = LineShapeCorrect(fid,mConAmpCor,mSPhase,mT2used,sw,traf_flag)
% Applies amp and phase corrections to fid from water only signal
% Also applies traf filter to fid

% Assumes files already added (or a single file)
% FID data is dcy
% Amplitude corr is mConAmpCor; phase correction (to be added)is mSPhase

clear j
dcy=fid;

% Set any parameters 
t2e = mT2used ;

% FIRST APPLY AMP AND PHASE CORRECTIONS ************
% Work with absolute mode
Dataa = abs(dcy) ;
Dataa(1) = 2*Dataa(1) ;
size(mConAmpCor);
% Amp corrrection
Dataa = Dataa.*mConAmpCor ;

% Phase correction
Phasea = angle(dcy) + mSPhase ;

% Corrected data
dcy = Dataa.*exp(sqrt(-1)*Phasea) ;

% *********************************

% NOW APPLY TRAF FILTER FROM ROUTINE TRAF_GM
if traf_flag==1
%    disp('performing traf filter')
siglen = length(dcy) ;
traffilter = traf_gm(siglen, t2e,sw) ;

realdcy = (dcy.*real(traffilter) + fliplr(dcy.*real(traffilter))) ;
imagdcy = (dcy.*imag(traffilter) - fliplr(dcy.*imag(traffilter))) ;
dcy = 1/2*(realdcy + imagdcy) ;
end

% Halve first pt prior to FT
%dcy(1) = dcy(1)/2 ;


fid_corr=dcy;


% realfid=fliplr(mSDataFT.*real(traffilter))+mSDataFT.*real(traffilter);
% imagfid=mSDataFT.*imag(traffilter)-fliplr(mSDataFT.*imag(traffilter));


% UNCOMMENT BELOW FOR PLOTS FROM THIS ROUTINE ************************



% *************************************************************

% End of routine
