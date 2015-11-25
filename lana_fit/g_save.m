%This file saves raw data (GABA and GSH)+reconstrated data from the difference spectroscopy

global filename sfrq sw ywat ymet Q_NO Q_YES newfname y_no y_yes
%1) Extract the filename information
firstfile=filename(1,1)
dotlocation=strfind(firstfile,'_')
%assuming siemens does not change the format naming of ima files, we need
%to take the 5th location of the dots, which is where the acquisition data
%begins
dateSim=firstfile{1,1}(dotlocation{1,1}(4)+1:dotlocation{1,1}(4)+8)

expSim=firstfile{1,1}(dotlocation{1,1}(1)+1:dotlocation{1,1}(1)+3)

newfname=['g_' dateSim '_Exp' expSim '.mat']


    
    
        
save (newfname,'Q_YES', 'Q_NO','ywat','sw','sfrq','y_no','y_yes')
disp('saved data successfully')
    