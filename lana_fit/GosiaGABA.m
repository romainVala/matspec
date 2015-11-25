function varargout = GosiaGABA(varargin)
% GOSIAGABA M-file for GosiaGABA.fig
%      GOSIAGABA, by itself, creates a new GOSIAGABA or raises the existing
%      singleton*.
%
%      H = GOSIAGABA returns the handle to a new GOSIAGABA or the handle to
%      the existing singleton*.
%
%      GOSIAGABA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GOSIAGABA.M with the given input arguments.
%
%      GOSIAGABA('Property','Value',...) creates a new GOSIAGABA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GosiaGABA_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GosiaGABA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GosiaGABA

% Last Modified by GUIDE v2.5 20-Jun-2009 12:32:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GosiaGABA_OpeningFcn, ...
                   'gui_OutputFcn',  @GosiaGABA_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before GosiaGABA is made visible.
function GosiaGABA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GosiaGABA (see VARARGIN)

% Choose default command line output for GosiaGABA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using GosiaGABA.


% UIWAIT makes GosiaGABA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GosiaGABA_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)





% --------------------------------------------------------------------
function Open_Trio_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Open_Trio_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename
g_read


% --- Executes on button press in pushbutton_spec1.
function pushbutton_spec1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_spec1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ymet y_no1 y_yes1
ymet_total1=ymet;
y_no1=ymet_total1(1:32,:);
y_yes1=ymet_total1(33:end,:);
set(handles.radiobutton1,'value',1)



% --- Executes on button press in pushbutton_spec2.
function pushbutton_spec2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_spec2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ymet y_no2 y_yes2
ymet_total2=ymet;
y_no2=ymet_total2(1:32,:);
y_yes2=ymet_total2(33:end,:);
set(handles.radiobutton2,'value',1)


% --- Executes on button press in pushbutton_spec3.
function pushbutton_spec3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_spec3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ymet y_no3 y_yes3
ymet_total3=ymet;
y_no3=ymet_total3(1:32,:);
y_yes3=ymet_total3(33:end,:);
set(handles.radiobutton3,'value',1)



% --- Executes on button press in pushbutton_spec4.
function pushbutton_spec4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_spec4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ymet y_no4 y_yes4
ymet_total4=ymet;
y_no4=ymet_total4(1:32,:);
y_yes4=ymet_total4(33:end,:);
set(handles.radiobutton4,'value',1)



% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1




rd1=get(handles.radiobutton1,'value')


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3

rd2=get(handles.radiobutton2,'value')


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
rd3=get(handles.radiobutton3,'value')

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

rd4=get(handles.radiobutton4,'value')

% Hint: get(hObject,'Value') returns toggle state of radiobutton4




% --- Executes on button press in pushbutton_Comb.
function pushbutton_Comb_Callback(hObject, eventdata, handles)

global y_no3 y_yes3 y_yes1 y_no1 y_yes2 y_no2 y_yes4 y_no4 newfname y_no y_yes
% hObject    handle to pushbutton_Comb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
y_no=[y_no1; y_no2; y_no3; y_no4];
y_yes=[y_yes1; y_yes2; y_yes3; y_yes4];

%Step 3: alligns the data (relative to the last fid in "edit off") and sums it up, producing the final
%fid files Q_NO, Q_YES









function Edit_TalkBack_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_TalkBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_TalkBack as text
%        str2double(get(hObject,'String')) returns contents of Edit_TalkBack as a double


% --- Executes during object creation, after setting all properties.
function Edit_TalkBack_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_TalkBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton_Save.
function pushbutton_Save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

g_save
str=sprintf('Saved in %s',newfname)
set(handles.Edit_TalkBack,'String',str);





% --- Executes on button press in pushbutton_LoadData.
function pushbutton_LoadData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_LoadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename pathname MM_on
[filename,pathname]=uigetfile('*.mat','Load Matlab Data');

if filename ~=0
    %Open the input file
    
   % s1=['cd' ' ' pathname]
   % eval(s1)
    sometext=['load' ' ' filename];
    eval(sometext);
end
 
MM_on=0
set(handles.checkbox_MM,'value',MM_on)


% --- Executes on button press in pushbutton_Clear.
function pushbutton_Clear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%str4=sprintf(' ');
%set(handles.edit_TalkBack,'String',str4);
set(handles.radiobutton4,'value',0)
set(handles.radiobutton3,'value',0)
set(handles.radiobutton2,'value',0)
set(handles.radiobutton1,'value',0)
clear 
clear global

% --- Executes on button press in pushbutton_LoadBasis.
function pushbutton_LoadBasis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_LoadBasis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global db_off db_on met_list mm_no mm_yes mm_spec_info
load gabadb
met_list




% --- Executes on button press in pushbutton_RefDec.
function pushbutton_RefDec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_RefDec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

g_total2;




% --- Executes on button press in pushbutton_FitWat.
function pushbutton_FitWat_Callback(hObject, eventdata, handles)
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

lowbT2=AmList1(2,1)*0.8;
ubT2=AmList1(2,1)*3;

str_t2=num2str(lowbT2);
str_t2u=num2str(ubT2);

str_t2w=num2str(AmList1(2,1));


set(handles.edit_T2lowb,'String',str_t2(1:5));
set(handles.editT2highb,'String',str_t2u(1:5));
set(handles.editT2wat,'String',str_t2w(1:5));
set(handles.edit_T2fact,'String',num2str(1));

% --- Executes on button press in pushbutton_AllignMetBasis.
function pushbutton_AllignMetBasis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_AllignMetBasis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_FitGABA.
function pushbutton_FitGABA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_FitGABA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global met_fit met_fitg db_diff AmList1 Am_gaba Am_gaba_MM T2_fact output_wat MM_on

if isempty(met_fitg)&MM_on==1
    str1=sprintf('Fit MM first, then fit GABA-MM!!!')
    set(handles.edit2_TalkBack,'String',str1);
end

T2_fact=str2double(get(handles.edit_T2fact,'String'));
AmList1(2,:)=output_wat(2,1);
AmList1(2,:)=AmList1(2,:)*T2_fact;

str1=sprintf('Left-click on both sides of glx and gaba')
set(handles.edit2_TalkBack,'String',str1);



if ~isempty(met_fitg)&MM_on==1 %actual case of fitting gaba-MM
    
str2=sprintf('Fitting GABA+GLX-MM')
set(handles.edit3_TalkBack,'String',str2);

datafit=met_fitg;


else  %fitting gaba+ MM
    
    str2=sprintf('Fitting GABA+GLX+MM')
set(handles.edit3_TalkBack,'String',str2);

datafit=met_fit;
    
end
    
   


    
    
if ~isempty(met_fitg)&MM_on==1 %actual case of fitting gaba-MM
[Am_gaba_MM,resnorm,output] = FAllignDiffG(datafit,db_diff,AmList1);
Am_gaba_MM
else
    
[Am_gaba,resnorm,output] = FAllignDiffG(datafit,db_diff,AmList1);
end


str3=sprintf('Done Fitting GABA!');
set(handles.edit3_TalkBack,'String',str3);

str4=sprintf(' ');
set(handles.edit2_TalkBack,'String',str4);


% --- Executes on button press in pushbutton_FitNAA.
function pushbutton_FitNAA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_FitNAA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global met_fit db_diff AmList1 Am_naa str2

str1=sprintf('Click on both sides of NAA only')
set(handles.edit2_TalkBack,'String',str1);

str2=sprintf('Fitting NAA singlet ...')
set(handles.edit3_TalkBack,'String',str2);

[Am_naa,resnorm,output] = FAllignDiffG(met_fit,db_diff,AmList1);



Am_naa;

str3=sprintf('Done fitting NAA!');
set(handles.edit3_TalkBack,'String',str3);

str4=sprintf(' ');
set(handles.edit2_TalkBack,'String',str4);



% --- Executes on button press in pushbutton_Excel.
function pushbutton_Excel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Excel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Am_naa Am_gaba Am_gaba_MM met_list filename output_wat  MM_on 
global Am_file Am_file_MM db_diff Am_final_MM  Am_final

NumberofMet=size(met_list,1)
Am_final=[Am_naa(:,1) Am_gaba(:,2:NumberofMet)];
Am_final(5,1)=Am_gaba(5,1)
Am_file=num2cell(Am_final);

firsttime=[met_list';Am_file]  %this is results of GABA+MM


if MM_on==1
Am_final_MM=[Am_naa(:,1) Am_gaba_MM(:,2:NumberofMet)]
Am_final_MM(5,1)=Am_gaba_MM(5,1)
Am_file_MM=num2cell(Am_final_MM);
secondtime=[met_list';Am_file_MM]  %this is results of GABA-MM
%xlswrite([filename '_fitted' '.xls'],secondtime,'gaba_minus_MM');
end



write_txt
%xlswrite([filename '_fitted' '.xls'],firsttime,'gaba_plus_MM');
%xlswrite([filename '_fitted' '.xls'],[output_wat],'water_ref');




strx=sprintf('Saved in %s',[filename(1:end-4) '.txt']);
set(handles.edit3_TalkBack,'String',strx);















function edit2_TalkBack_Callback(hObject, eventdata, handles)
% hObject    handle to edit2_TalkBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2_TalkBack as text
%        str2double(get(hObject,'String')) returns contents of edit2_TalkBack as a double


% --- Executes during object creation, after setting all properties.
function edit2_TalkBack_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2_TalkBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit3_TalkBack_Callback(hObject, eventdata, handles)
% hObject    handle to edit3_TalkBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3_TalkBack as text
%        str2double(get(hObject,'String')) returns contents of edit3_TalkBack as a double


% --- Executes during object creation, after setting all properties.
function edit3_TalkBack_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3_TalkBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton_Allign.
function pushbutton_Allign_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Allign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global y_no y_yes Q_NO Q_YES
[Q_NO, Q_YES]=Q_step3(y_no,y_yes)





function edit_T2lowb_Callback(hObject, eventdata, handles)
% hObject    handle to edit_T2lowb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_T2lowb as text
%        str2double(get(hObject,'String')) returns contents of edit_T2lowb as a double


% --- Executes during object creation, after setting all properties.
function edit_T2lowb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_T2lowb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editT2highb_Callback(hObject, eventdata, handles)
% hObject    handle to editT2highb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editT2highb as text
%        str2double(get(hObject,'String')) returns contents of editT2highb as a double


% --- Executes during object creation, after setting all properties.
function editT2highb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editT2highb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function editT2wat_Callback(hObject, eventdata, handles)
% hObject    handle to editT2wat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editT2wat as text
%        str2double(get(hObject,'String')) returns contents of editT2wat as a double


% --- Executes during object creation, after setting all properties.
function editT2wat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editT2wat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_T2fact_Callback(hObject, eventdata, handles)
% hObject    handle to edit_T2fact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_T2fact as text
%        str2double(get(hObject,'String')) returns contents of edit_T2fact as a double


% --- Executes during object creation, after setting all properties.
function edit_T2fact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_T2fact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton_FitMM.
function pushbutton_FitMM_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_FitMM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global met_fit mm_yes mm_no Am_mm str2 timeD ZeroFill sw sfrq sumfidIniM met_fitg

str1=sprintf('Click on both sides of MM only')
set(handles.edit2_TalkBack,'String',str1);

str2=sprintf('Fitting MM ...')
set(handles.edit3_TalkBack,'String',str2);

mm_diff=mm_yes-mm_no;

AmListM=[7;1;0;0;1];

[Am_mm,resnorm,output] = FAllignDiffGM(met_fit,mm_diff,AmListM);



Am_mm

str3=sprintf('Done!');
set(handles.edit3_TalkBack,'String',str3);

str4=sprintf(' ');
set(handles.edit2_TalkBack,'String',str4);
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







% --- Executes on button press in checkbox_MM.
function checkbox_MM_Callback(hObject, eventdata, handles)
global MM_on
% hObject    handle to checkbox_MM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_MM
%MM_on=get(handles.checkbox_MM,'value')
%set(handles.checkbox_MM,'value',MM_on)
MM_on=get(handles.checkbox_MM,'value')
set(handles.checkbox_MM,'value',MM_on)




% --- Executes on button press in pushbutton_DisplayResults.
function pushbutton_DisplayResults_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DisplayResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global db_diff Am_final_MM  Am_final
global ZeroFill  met_fit met_fitg timeD sw sfrq

%This is for gaba+MM
AmList=Am_final
dcy=met_fit;
sumfidMD1=db_diff;
PhaseFactor=exp(sqrt(-1)*AmList(4,1));
sumfidIni=zeros(size(sumfidMD1,1),size(dcy,2));
sumfftIni=zeros(size(sumfidMD1,1),ZeroFill);
FirstPoint=AmList(5,1);
 
for m=1:size(sumfidMD1,1);
    
   
    FreqFactor=exp(sqrt(-1)*2*pi*AmList(3,m)*timeD );
 % FreqFactor=1;
 %    sumfidM1(m,:)=sumfidM1(m,:).*exp(-sqrt(-1)*2*pi*AmListIni(3,1)*timeD);
     sumfidIni(m,:)=AmList(1,m).*sumfidMD1(m,:).*FreqFactor.*PhaseFactor.*exp(-timeD./AmList(2,m));
     sumfidIni(m,:)=[sumfidIni(m,1)*FirstPoint sumfidIni(m,2:end)];
 
     sumfftIni(m,:)=fliplr(fftshift(fft(sumfidIni(m,:),ZeroFill)));
        
 end;
 %end the gaba+MM
 
 %begin gaba-MM
 
 %This is for gaba+MM
AmList=Am_final_MM;

sumfidMD1=db_diff;
PhaseFactor=exp(sqrt(-1)*AmList(4,1));
sumfidIni=zeros(size(sumfidMD1,1),size(dcy,2));
sumfftIni_M=zeros(size(sumfidMD1,1),ZeroFill);
FirstPoint=AmList(5,1);
 
for m=1:size(sumfidMD1,1);
    
   
    FreqFactor=exp(sqrt(-1)*2*pi*AmList(3,m)*timeD );
 % FreqFactor=1;
 %    sumfidM1(m,:)=sumfidM1(m,:).*exp(-sqrt(-1)*2*pi*AmListIni(3,1)*timeD);
     sumfidIni(m,:)=AmList(1,m).*sumfidMD1(m,:).*FreqFactor.*PhaseFactor.*exp(-timeD./AmList(2,m));
     sumfidIni(m,:)=[sumfidIni(m,1)*FirstPoint sumfidIni(m,2:end)];
 
     sumfftIni_M(m,:)=fliplr(fftshift(fft(sumfidIni(m,:),ZeroFill)));
        
 end;
 

 
FrequencyScale=(-sw/2:sw/(ZeroFill):sw/2-sw/(ZeroFill))/sfrq-4.65;


figure;plot(FrequencyScale,real(sum(sumfftIni,1)),'r');hold
plot(FrequencyScale,real(fliplr(fftshift(fft(met_fit,ZeroFill)))),'k')
title('Red is fit, Black is the raw data+MM')

figure;plot(FrequencyScale,real(sum(sumfftIni_M,1)),'r');hold
plot(FrequencyScale,real(fliplr(fftshift(fft(met_fitg,ZeroFill)))),'k')
title('Red is fit, Black is the raw data-MM')


