global Am_file_MM filename Am_final met_list MM_on
Am_file_MM=num2cell(Am_final_MM);
met_list_new=[met_list{1,1} '   ' met_list{2,1} '   ' met_list{3,1} '   ' met_list{4,1}]
fid = fopen([filename '.txt'],'wt');
fprintf(fid,'%s\n',met_list_new)
for i=1:size(Am_final,1);
fprintf(fid,'%5.3f\t %5.3f\t %5.3f\t %5.3f\n ',Am_final(i,:))
end
fclose(fid)