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



%strx=sprintf('Saved in %s',[filename(1:end-4) '.txt']);
%set(handles.edit3_TalkBack,'String',strx);


