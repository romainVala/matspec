
% --- Executes on button press in pushbutton_FitNAA.
% function pushbutton_FitNAA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_FitNAA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global met_fit db_diff AmList1 Am_naa str2

%str1=sprintf('Click on both sides of NAA only')
% fprintf('%s\n',str1); %set(handles.edit2_TalkBack,'String',str1);

str2=sprintf('Fitting NAA singlet ...')
 fprintf('%s\n',str2); %set(handles.edit3_TalkBack,'String',str2);

[Am_naa,resnorm,output] = FAllignDiffG(met_fit,db_diff,AmList1,'NAA');



Am_naa;

str3=sprintf('Done fitting NAA!');
fprintf('%s\n',str3); %set(handles.edit3_TalkBack,'String',str3);

