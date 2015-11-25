function [fid_out,freq_shift]=AllignFreq(fid_orig,fid_allign);

global sw 

if isempty(sw)
    disp('sw is empty')
end


np=2*size(fid_orig,2);

timeD=0:1/sw:(np/2)*1/sw-1/sw;
RtermGau=exp(-(timeD.^2./0.20^2));

%edit off will be the unchanged signal;
ZF=8192*2;
%pt_start=7500;
pt_start=9000;
pt_end=11000;

spec_orig=fliplr(fftshift(fft(fid_orig.*RtermGau,ZF)));
spec_allign=fliplr(fftshift(fft(fid_allign.*RtermGau,ZF)));

spec_diff=spec_allign-spec_orig;

%shift the frequency
freq_Hz=0.005;
spec_allign_star=fliplr(fftshift(fft(fid_allign.*RtermGau.*exp(freq_Hz*sqrt(-1)*2*pi*timeD),ZF)));
%spec_allign_star=circshift(spec_allign,[0 1]) ;%this is right shift, the last point is now first


spec_diff_new=spec_allign_star-spec_orig;

area_orig=sum(abs(spec_diff(1,pt_start:pt_end)),2);
area_new=sum(abs(spec_diff_new(1,pt_start:pt_end)),2);

if area_new<area_orig;
  %  disp('yes, it is the right direction for freq shift');
    freqshift='positive';
    freqshift_done=0;
else
spec_allign_star=fliplr(fftshift(fft(fid_allign.*RtermGau.*exp(-freq_Hz*sqrt(-1)*2*pi*timeD),ZF)));


   % spec_allign_star=circshift(spec_allign,[0 -1]) ;%this is the left shift, the first point is now last
        spec_diff_new=spec_allign_star-spec_orig;
        area_new=sum(abs(spec_diff_new(1,pt_start:pt_end)),2);
        if area_new<area_orig;
        %disp('negative shift is needed');
        freqshift='negative';
        freqshift_done=0;
        else
            freqshift='neutral'
        freqshift_done=1;
        %disp('can not be improved in freq');
           
        end
    
end

if freqshift_done==1;
    fid_out=fid_orig;
   freq_shift=0;
    
   return
end

counter=0;
while freqshift_done == 0;
    
    counter=counter+1;
    
    if  freqshift=='positive';
        
        spec_allign_star=fliplr(fftshift(fft(fid_allign.*RtermGau.*exp(2*freq_Hz*counter*sqrt(-1)*2*pi*timeD),ZF)));
   % spec_allign_star=circshift(spec_allign,[0 1])  ;%this is right shift, the last point is now first
    else
        spec_allign_star=fliplr(fftshift(fft(fid_allign.*RtermGau.*exp(-2*freq_Hz*counter*sqrt(-1)*2*pi*timeD),ZF)));
      % spec_allign_star=circshift(spec_allign,[0 -1])  ;%this is right shift, the last point is now first
    end

    spec_diff_new= spec_allign_star-spec_orig;
    
    area_new=sum(abs(spec_diff_new(1,pt_start:pt_end)),2);
   
    
       if area_new<area_orig;
    
       freqshift_done=0;
       area_orig=area_new; %compare to the improved area
       else
      freqshift_done=1;
      % disp('no more improvement');
       end %end of while

end %end of while

if freqshift=='positive'
freqshift_Hz=2*freq_Hz*counter;
else
    freqshift_Hz=-2*freq_Hz*counter;

end

freqshift_Hz


fid_out=fid_allign.*exp(freqshift_Hz*sqrt(-1)*2*pi*timeD);



freq_shift=freqshift_Hz;







