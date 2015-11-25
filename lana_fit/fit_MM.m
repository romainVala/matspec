% --- Executes on button press in pushbutton_FitMM.
%function pushbutton_FitMM_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_FitMM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global met_fit mm_yes mm_no Am_mm str2 timeD ZeroFill sw sfrq sumfidIniM met_fitg

str2=sprintf('Fitting MM ...')


mm_diff=mm_yes-mm_no;

AmListM=[7;1;0;0;1];

[Am_mm,resnorm,output] = FAllignDiffGM(met_fit,mm_diff,AmListM);



Am_mm

str3=sprintf('Done!');
fprintf('%s\n',str3); %set(handles.edit3_TalkBack,'String',str3);


%Reconstruct
PhaseFactor=exp(sqrt(-1)*Am_mm(4,1));

FreqFactor=exp(sqrt(-1)*2*pi*Am_mm(3,1)*timeD );
FirstPoint=Am_mm(5,1);


sumfidIniM=Am_mm(1,1).*mm_diff.*FreqFactor.*PhaseFactor.*exp(-timeD./Am_mm(2,1));
     sumfidIniM=[sumfidIniM(1,1)*FirstPoint sumfidIniM(1,2:end)];
 
     sumfftIni=fliplr(fftshift(fft(sumfidIniM,ZeroFill)));
     
     
     met_fitg=met_fit-sumfidIniM;
     
     
FrequencyScale=(-sw/2:sw/(ZeroFill):sw/2-sw/(ZeroFill))/sfrq-4.65;

figure;plot(FrequencyScale,real(sum(sumfftIni,1)),'r');hold
plot(FrequencyScale,real(fliplr(fftshift(fft(met_fit,ZeroFill)))),'k')
plot(FrequencyScale,real(fliplr(fftshift(fft(met_fit-sumfidIniM,ZeroFill)))),'b')
title('Red:fitted MM, Blue:GABA-MM')


