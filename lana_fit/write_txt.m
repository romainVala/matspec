global Am_file_MM filename Am_final Am_final_MM met_list MM_on

met_list_new=[met_list{1,1} '   ' met_list{2,1} '   ' met_list{3,1} '   ' met_list{4,1}]

%%newfname=filename(1:end-4);

newfname = ([  fall(nbg).group(nbs).sujet_name,'_',fall(nbg).group(nbs).SerDescr  ,'_',fall(nbg).group(nbs).examnumber ]);

newfname = ['lana_' newfname];

newfname = nettoie_dir(newfname);

dd = fullfile(pwd,fall(nbg).region);
if ~exist(dd)
  mkdir(dd)
end

newfname = fullfile(dd,newfname);
  
%if MM_on==1
    fidmm = fopen([newfname '_MM' '.txt'],'wt');
    Am_final_MM;
    
    fprintf(fidmm,'%s,water\n',met_list_new);
     for i=1:size(Am_final_MM,1);
      fprintf(fidmm,'%5.3f\t %5.3f\t %5.3f\t %5.3f\t %5.3f\n ',Am_final_MM(i,:),output_wat(i));
     end
   fclose(fidmm);
%end

%this is no MM file
    fid = fopen([newfname '.txt'],'wt');

    
     fprintf(fid,'%s\n',met_list_new);
       for i=1:size(Am_final,1);
         fprintf(fid,'%5.3f\t %5.3f\t %5.3f\t %5.3f\n ',Am_final(i,:));
       end
    fclose(fid);

