function write_fid_to_csv(f,file_text)

fid = fopen(file_text,'a+');

fprintf(fid,'\nSujet,Serie,TR,TE,NEX,FOV,dwell,nbpts,mega_ws,vapor_ws');

if isfield(f(1),'water_width')
    fprintf(fid,',water_width,water_integral\n');
else
    fprintf(fid,'\n');
end


for k=1:length(f)
    fprintf(fid,'%s,%s,%d,%d,%d,[%d %d %d],%f,%d,%d,%d',...
        f(k).sujet_name,f(k).ser_dir,f(k).TR,f(k).TE(1),f(k).Nex,...
        f(k).Pos.VoiFOV(1),f(k).Pos.VoiFOV(2),f(k).Pos.VoiFOV(3),...
        f(k).spectrum.dw,f(k).spectrum.np,...
        f(k).mega_ws,f(k).vapor_ws);


if isfield(f(1),'water_width')
    fprintf(fid,',%f,%f\n',f(k).water_width,f(k).integral_fid_cor_abs);
else
    fprintf(fid,'\n');
end


end