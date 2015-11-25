%load data
%Step1:
%load g_20081028_ExpS10.mat
%load gabadb
%F_out: met_noc, met_yesc, wat_refc

global ywat Q_NO Q_YES sw sfrq met_noc met_yesc wat_refc timeD y_yes y_no

if isempty(Q_NO)
    disp('I am not alligned')
    Q_NO=sum(y_no,1);
    Q_YES=sum(y_yes,1);
end

np=size(Q_NO,2)*2;
timeD=0:1/sw:(np/2)*1/sw-1/sw;

%Convert the lineshape to Lor:
%Step2:
[mConAmpCor mSPhase mT2used] = LineShapeExtract(ywat(1,:),sw);
met_noc = LineShapeCorrect(Q_NO,mConAmpCor,mSPhase,mT2used,sw,0);
met_yesc = LineShapeCorrect(Q_YES,mConAmpCor,mSPhase,mT2used,sw,0);
wat_refc = LineShapeCorrect(ywat(1,:),mConAmpCor,mSPhase,mT2used,sw,0);


RtermLor=exp(-timeD/0.15);

met_noc=met_noc.*RtermLor;
met_yesc=met_yesc.*RtermLor;
wat_refc=wat_refc.*RtermLor;

figure;
%plot(real(fliplr(fftshift(fft(met_noc,8192*8)))));hold
%plot(real(fliplr(fftshift(fft(met_yesc,8192*8)))),'r');
plot(real(fliplr(fftshift(fft((met_yesc-met_noc),8192*8)))),'k');
%plot(real(fliplr(fftshift(fft(wat_refc,8192*8)))),'g');
title('edit on (red) edit off (blue) difference (black)')