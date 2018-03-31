function write_result_to_csv(conc,resname,field_list)

if ~iscell(conc)
    conc={conc};
end


if ~exist('field_list')
    field_list = fieldnames(conc{1});
end


fid = fopen(resname,'a+');
nbline=0;
while fgetl(fid)~=-1
    nbline=nbline+1;
end


for npool = 1:length(conc{1})
    
    f1 = getfield(conc{1}(npool),field_list{1});
    
    nbsuj = length(f1);
    
    for nbs = 1:nbsuj
        
        if mod(nbline,40)==0
            %print the header
            if length(conc)>1 %multiple model
                for kn = 1:length(field_list)
                    for kmod=1:length(conc)
                        fprintf(fid,'%s,',conc{kmod}(1).model_name);
                    end
                end
                fprintf(fid,'\n');
            end
            
            for kn = 1:length(field_list)
                for kmod=1:length(conc)
                    fprintf(fid,'%s,',field_list{kn});
                end
            end
            fprintf(fid,'\n');
        end
        nbline = nbline+1;
        
        for kn = 1:length(field_list)
            for kmod=1:length(conc)
                if ~isfield(conc{kmod}(npool),field_list{kn})
                    clear aa;aa{nbs}='';
                else
                    aa = getfield(conc{kmod}(npool),field_list{kn});
                end
                if iscell(aa)
                    fprintf(fid,'%s,',aa{nbs});
                elseif isstruct(aa)
                else
                    fprintf(fid,'%f,',aa(nbs));
                end
            end
        end
        fprintf(fid,'\n');
    end
    
    fprintf(fid,'\n');
end


fclose(fid);
