%function pushbutton_FitWat_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_FitWat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global wat_refc met_noc met_yesc db_on db_off sfrq sw timeD
global db_diff met_fit AmList1 output_wat met_list

[water_contrib1,output_wat] = PreProcLor(wat_refc,sfrq*4.68);
figure;plot(real(fliplr(fftshift(fft(wat_refc,8192*4)))),'k');hold
plot(real(fliplr(fftshift(fft(water_contrib1,8192*4)))),'r');

%Step 2: Allign met.spectra with database
[DiffFreqHz_Main] = FAllignLorG(met_noc,db_off);

%DiffFreqHz_Main=-(sfrq*4.68)+output_wat(3)

for i=1:size(db_off,1)
    db_off_c(i,:)=db_off(i,:).*exp(-DiffFreqHz_Main*2.00*pi*timeD*sqrt(-1));
    db_on_c(i,:)=db_on(i,:).*exp(-DiffFreqHz_Main*2.00*pi*timeD*sqrt(-1));
end;

db_diff=db_on_c-db_off_c;
met_fit=met_yesc-met_noc;

MetSig10=(output_wat(1)*128*10*10^-3)/30;

NumberofMet=size(met_list,1);
AmList1=[output_wat output_wat output_wat output_wat]; %Needs to be repeated as NumberofMet

AmList1(1,1)=MetSig10*1.4;%this is naa
AmList1(1,2)=MetSig10*1.0; %this is glu
AmList1(1,3)=MetSig10*0.3; %this is gaba
AmList1(1,4)=MetSig10*0.2; %this is gln

AmList1(2,:)=output_wat(2,1);

%lowbT2=AmList1(2,1)*0.8;
%ubT2=AmList1(2,1)*3;

%str_t2=num2str(lowbT2);
%str_t2u=num2str(ubT2);

%str_t2w=num2str(AmList1(2,1));


%global T2lowb T2highb T2wat T2_fact 

%T2lowb = str2double(str_t2(1:5));
%T2highb = str2double(str_t2u(1:5));
%T2wat   = str2double(str_t2w(1:5));
%T2_fact =1.2;
