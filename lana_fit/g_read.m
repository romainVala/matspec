function OpenSimTrio_Callback(hObject, eventdata, handles);
% hObject    handle to OpenSimIma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear global filenameIma filename ;

global ymet ywat filename pathname sw NA NR frequency sfrq np DimFile filenameIma InstanceCreationTime SimProt trial1;
    if ischar(pathname)
    [filename,pathname]=uigetfile('*.dic*','Load Sim Data',pathname,'MultiSelect','On');
    
    else
    
    [filename,pathname]=uigetfile('*.dic*','Load Sim Data','MultiSelect','On')
    end
    
   
%directory_name = uigetdir
   if iscell(filename);
         DimFile=size(filename,2)
        % filenameIma{1,DimFile}=zeros(1,DimFile)
         
         
     %   filename=sort(filename);
     
     if strcmp(computer,'PCWIN') %this is to account for the bug in the windows
         disp('this is PCWIN computer, 1st and last files are swapped')
        filename={filename{1,2:end} filename{1,1}};
     else
         disp('this is non windows computer, sorting the files')
         
         filename=sort(filename);
     end
        
         str=sprintf('You are reading in %s spectra',num2str(DimFile));
         disp(str)
         
      %  filenameIma{1,DimFile}=zeros(1,DimFile)
       
         
               for i=1:DimFile;
           
                   filename{1,:};
               

                filenameIma{1,i}=[pathname filename{1,i}];
                info = dicominfo(filenameIma{i});
                
               SizeofData=32768/2;
                %StartofPixel=info.StartOfPixelData;
                BytesToSkip=info.FileSize-SizeofData;
                
                InstanceCreationTime=info.InstanceCreationTime;
                size(InstanceCreationTime,2);
               trial1(i)=str2num(info.InstanceCreationTime(end-6:end));
               
                
                
               %info.Private contains the size of the actual raw data
              
               
                  y(i,:) = spec_read(filenameIma{i},double([SizeofData/4 1]),double(BytesToSkip),'single',1);
                  
                  
               end
              
               [frequency,sw,ws,NA,NR]=readSimParam(filenameIma{1});
               sw=sw/2; %OS takes place 
         
   else
   
filenameIma=[pathname filename];
info = dicominfo(filenameIma);

 SizeofData=32768/2;
                %StartofPixel=info.StartOfPixelData;
                BytesToSkip=info.FileSize-SizeofData;
                
               
%info.Private contains the size of the actual raw data

y = spec_read(filenameIma,double([SizeofData/4 1]),double(BytesToSkip),'single',1);

[frequency,sw,ws,NA,NR]=readSimParam(filenameIma);
sw=sw/2;  %OS takes place


end
   np=SizeofData/4;
   sfrq=frequency/10^6;
   
   SimProt.NA=NA;
       
   SimProt.NR=NR+1;

%SimProt.TR=info.Private_0029_1210.RepetitionTime;
%SimProt.TE=info.Private_0029_1210.EchoTime;
SimProt.sw=sw;

if strcmp(computer,'PCWIN')
findslash1=strfind(pathname,'\');
else
    findslash1=strfind(pathname,'/');
end
    
SimProt.ExpName=info.Filename(findslash1(end-1)+1:findslash1(end)-1);
SimProt.Date=info.InstanceCreationDate;

if strfind(SimProt.ExpName,'ref')
    ywat=y;
else
   
   ymet=y;
    
end

disp('...all done')







   