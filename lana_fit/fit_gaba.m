% --- Executes on button press in pushbutton_FitGABA.
%function pushbutton_FitGABA_Callback(hObject, eventdata, handles)


global met_fit met_fitg db_diff AmList1 Am_gaba Am_gaba_MM T2_fact output_wat MM_on

if isempty(met_fitg)&MM_on==1
    str1=sprintf('Fit MM first, then fit GABA-MM!!!');
    %set(handles.edit2_TalkBack,'String',str1);
    fprintf('%s\n',str1);
end

%global variable define in fit_water.m
%T2_fact=str2double(get(handles.edit_T2fact,'String'));

AmList1(2,:)=output_wat(2,1);
AmList1(2,:)=AmList1(2,:)*T2_fact;

%str1=sprintf('Left-click on both sides of glx and gaba');
%fprintf('%s\n',str1);
%set(handles.edit2_TalkBack,'String',str1);



if ~isempty(met_fitg)&MM_on==1 %actual case of fitting gaba-MM
    
str2=sprintf('Fitting GABA+GLX-MM');
fprintf('%s\n',str2); %set(handles.edit3_TalkBack,'String',str2);

datafit=met_fitg;


else  %fitting gaba+ MM
    
str2=sprintf('Fitting GABA+GLX+MM')
fprintf('%s\n',str2); %set(handles.edit3_TalkBack,'String',str2);

datafit=met_fit;
    
end
    
    
if ~isempty(met_fitg)&MM_on==1 %actual case of fitting gaba-MM
[Am_gaba_MM,resnorm,output] = FAllignDiffG(datafit,db_diff,AmList1,'GABA');
Am_gaba_MM
else
    
[Am_gaba,resnorm,output] = FAllignDiffG(datafit,db_diff,AmList1,'GABA');
end


str3=sprintf('Done Fitting GABA!');
fprintf('%s\n',str3); %set(handles.edit3_TalkBack,'String',str3);


