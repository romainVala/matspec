%This is to allign all the fids to the frequency of the last fid
%input: fid_measN fid_measY
function [Q_NO, Q_YES]=Q_step3(fid_measN,fid_measY)

global sw 
global fid_measN_final fid_measY_final

fid_measN_final=zeros(size(fid_measN));
fid_measY_final=zeros(size(fid_measY));
hold_freq=zeros(size(fid_measN,1));

dimfid=size(fid_measN);
for i=1:dimfid(1);
    i
  
    [fid_out,freq_shift]=AllignFreq(fid_measN(end,:),fid_measN(i,:));
    
    fid_measN_final(i,:)=fid_out;
    holder_freq(i)=freq_shift;
    
    [fid_out,freq_shift]=AllignFreq(fid_measY(end,:),fid_measY(i,:));
    fid_measY_final(i,:)=fid_out;
end

figure;plot(holder_freq);hold
plot(holder_freq,'o');
plot(zeros(size(holder_freq)),'r');
title('freq vs number of scans')
xlabel('number of scans')
ylabel('freq. diff between each scan compared to last (Hz)')

fid_finalN=sum(fid_measN_final,1);
fid_finalY=sum(fid_measY_final,1);

%This step alligns YES and NO spectra, where fid_out is YES;
[fid_out,freq_shiftfinal]=AllignFreq(fid_finalN,fid_finalY);
Q_NO=fid_finalN;
Q_YES=fid_out;

