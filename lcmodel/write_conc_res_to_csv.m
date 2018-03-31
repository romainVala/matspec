function write_conc_res_to_csv(conc,resname,high_res,field_list,std_abs)
%function write_conc_res_to_csv(conc,resname,high_res,field_list,std_abs)
%conc is the matlab structure to write
%resname the filename to save
%high_res is 0 or 1 if 1 full precision digit will be written
%field_list to select only some field of the struct

if ~exist('high_res','var')
    high_res=1;
end
if ~exist('field_list')
    field_list = fieldnames(conc);
    field_list(1:2)=[];
end

if ~exist('std_abs')
    std_abs=0;
end

if isnumeric(field_list)
    switch field_list
        case 1
            field_list = {'sNAA_NAAG','SDsNAA_NAAG','Cr_PCr','SDCr_PCr','PCho_GPC','SDPCho_GPC','Glu_Gln','SDGlu_Gln','Glu','SDGlu','Ins','SDIns','water_real','water_abs','water_phase','water_width','fgray','fwhite','fcsf','corcsf','corWconc','corScale','cor_all','Glc_Tau','SDGlc_Tau','PCr','SDPCr','Cr','SDCr','GABA','SDGABA','Gln','SDGln','sNAA','SDsNAA','mNAA_NAAG','SDmNAA_NAAG','mNAA','SDmNAA','NAAG','SDNAAG','Mac','SDMac','PE','SDPE','Tau','SDTau','sIns','SDsIns','Lac','SDLac','PCho','SDPCho','GSH','SDGSH','Glc','SDGlc','GPC','SDGPC','Ala','SDAla','Asc','SDAsc','Asp','SDAsp'};
        case 2 % repro
            field_list ={'Glu','SDGlu','Ins','SDIns','NAA','SDNAA','NAA_NAAG','SDNAA_NAAG','Cr_PCr','SDCr_PCr','Glu_Gln','SDGlu_Gln','PCho_GPC','SDPCho_GPC'};
            
        case 3
            field_list ={'mega_GABA','mega_SDGABA','mega_NAA','sNAA_NAAG','mega_SDNAA','SDsNAA_NAAG','mega_GLU_GLN','Glu_Gln','mega_SDGLU_GLN','SDGlu_Gln','Cr_PCr','SDCr_PCr','PCho_GPC','SDPCho_GPC','Ins','SDIns','water_real','water_abs','water_phase','water_width','fgray','fwhite','fcsf','corcsf','corWconc','corScale','cor_all','mega_GLU','mega_SDGLU','mega_GLN','mega_SDGLN','mega_MM','mega_SDMM','phase_cor','mega_phase_cor','phase1_cor','mega_phase1_cor','linewidth','mega_linewidth','SN','mega_SN','freq_shift','mega_freq_shift'};
            
        case 33
            field_list ={'mega_GABA','mega_SDGABA','GABA','SDGABA','mega_NAA','NAA_NAAG','mega_SDNAA','SDNAA_NAAG','mega_GLU_GLN','Glu_Gln','mega_SDGLU_GLN','SDGlu_Gln','Cr_PCr','SDCr_PCr','PCho_GPC','SDPCho_GPC','Ins','SDIns','water_real','water_abs','water_phase','water_width','fgray','fwhite','fcsf','corcsf','corWconc','corScale','cor_all','mega_GLU','mega_SDGLU','mega_GLN','mega_SDGLN','mega_MM','mega_SDMM','phase_cor','mega_phase_cor','phase1_cor','mega_phase1_cor','linewidth','mega_linewidth','SN','mega_SN','freq_shift','mega_freq_shift'};
            
            
            
        case 4
            % field_list = {'NAA','glnNoNAA','mega6NAA','GABA','glnNoGABA','mega6GABA','GLU_GLN','glnNoGLU','mega6GLU','SDNAA','glnNoSDNAA','mega6SDNAA','SDGABA','glnNoSDGABA','mega6SDGABA','SDGLU_GLN','glnNoSDGLU','mega6SDGLU'};
            field_list = {'NAA','glnNoNAA','mega6NAA','GABA','glnNoGABA','mega6GABA','GLU_GLN','glnNoGLU','mega6GLU','water_width','fgray','fwhite','fcsf','corcsf','corWconc','corScale','cor_all','SDNAA','glnNoSDNAA','mega6SDNAA','SDGABA','glnNoSDGABA','mega6SDGABA','SDGLU_GLN','glnNoSDGLU','mega6SDGLU'};
            
        case 5
            field_list={'NAA','sim_ed_NAA','simSS_ed_NAA','SDNAA','sim_SDed_NAA','simSS_SDed_NAA','GABA','sim_ed_GAB','simSS_ed_GAB','SDGABA','sim_SDed_GAB','simSS_SDed_GAB','GLU_GLN','sim_ed_Gln_ed_Glu','simSS_ed_Gln_ed_Glu','SDGLU_GLN','sim_SDed_Gln_ed_Glu','simSS_SDed_Gln_ed_Glu','phase_cor','sim_phase_cor','simSS_phase_cor','phase1_cor','sim_phase1_cor','simSS_phase1_cor','linewidth','sim_linewidth','simSS_linewidth','SN','sim_SN','simSS_SN','freq_shift','sim_freq_shift','simSS_freq_shift'};
            
        case 6
            field_list = {'sNAA_NAAG','simV_sNAA_NAAG','SDsNAA_NAAG','simV_SDsNAA_NAAG','Cr_PCr','simV_Cr_PCr','SDCr_PCr','simV_SDCr_PCr','PCho_GPC','simV_PCho_GPC','SDPCho_GPC','simV_SDPCho_GPC','Glu_Gln','simV_Glu_Gln','SDGlu_Gln','simV_SDGlu_Gln','Glu','simV_Glu','SDGlu','simV_SDGlu','Ins','simV_Ins','SDIns','simV_SDIns','water_real','water_abs','water_phase','water_width','fgray','fwhite','fcsf','corcsf','corWconc','corScale','cor_all','phase_cor','simV_phase_cor','phase1_cor','simV_phase1_cor','linewidth','simV_linewidth','SN','simV_SN','freq_shift','simV_freq_shift'};
        case 7
            field_list = {'NAA_NAAG','simSS_NAA_NAAG','Cr_PCr','simSS_Cr_PCr','PCho','simSS_PCho','Glu_Gln','simSS_Glu_Gln','Glu','simSS_Glu','Ins','simSS_Ins','SDNAA_NAAG','simSS_SDNAA_NAAG','SDCr_PCr','simSS_SDCr_PCr','SDPCho','simSS_SDPCho','SDGlu_Gln','simSS_SDGlu_Gln','SDGlu','simSS_SDGlu','SDIns','simSS_SDIns','water_real','water_abs','water_phase','water_width','fgray','fwhite','fcsf','corcsf','corWconc','corScale','cor_all','phase_cor','simSS_phase_cor','phase1_cor','simSS_phase1_cor','linewidth','simSS_linewidth','SN','simSS_SN','freq_shift','simSS_freq_shift'};
            
    end
end


fid = fopen(resname,'a+');

write_conc_res_summary_to_csv(conc,fid,field_list,std_abs);


for npool = 1:length(conc)
    
    if isfield(conc(1),'suj_age')
        fprintf(fid,'%s,Age',conc(npool).pool);
    else
        fprintf(fid,'%s',conc(npool).pool);
    end
    
    for kf = 1:length(field_list)
        if ~strcmp(field_list{kf},'suj_age')
            if strcmp(field_list{kf},'met'), continue; end
            if strcmp(field_list{kf},'cormat')  
                aa = getfield(conc(npool),'met');   
                
                for nm=1:length(aa)
                    for km = nm+1:length(aa)
                        fprintf(fid,',%s cor %s',aa{nm},aa{km})
                    end
                end
                
            end
              
            fprintf(fid,',%s',field_list{kf});
        end
    end
    
    for k=1:length(conc(npool).suj)
        fprintf(fid,'\n%s',conc(npool).suj{k});
        if isfield(conc(1),'suj_age')
            fprintf(fid,',%s',conc(npool).suj_age{k});
        end
        
        for kf = 1:length(field_list)
            if strcmp(field_list{kf},'met'), continue; end
            
            if ~strcmp(field_list{kf},'suj_age')
                aa = getfield(conc(npool),field_list{kf});
                
                if strcmp(field_list{kf},'cormat')
                    aa = getfield(conc(npool),'cormat');
                    cormat = aa{k};
                    for nm=1:length(cormat)
                        for km = nm+1:length(cormat)
                            fprintf(fid,',%.2f',cormat(km,nm))
                        end
                    end
                end  

                if iscell(aa)
                    if strcmp(field_list{kf},'cormat')
                        cm  = aa{k};
                        
                    else
                        fprintf(fid,',%s',aa{k} );
                    end
                    
                    
                else
                    
                    if length(aa)<length(conc(npool).suj)
                        aa(length(conc(npool).suj)) = NaN;
                        if k==1
                            fprintf('waning field %s is incomplete\n',field_list{kf});
                        end
                    end
                    
                    if isnan(aa(k))
                        fprintf(fid,',');
                    else
                        fprintf(fid,',%0.3f',aa(k) );
                    end
                    
                end %iscell(aa)
                
            end
        end
    end
    
    %print the mean
    fprintf(fid,'\nmean');
    if isfield(conc(1),'suj_age'),
        aa = conc(npool).suj_age;
        sa=str2num(cell2mat(aa'));
        
        fprintf(fid,',%0.1f',mean(sa));
    end
    
    for kf = 1:length(field_list)
        if ~strcmp(field_list{kf},'suj_age')
            aa = getfield(conc(npool),field_list{kf});
            if isnumeric(aa)
                aa(isnan(aa))=[];
                fprintf(fid,',%0.3f',mean(aa));
            else
                fprintf(fid,',');
            end
        end
    end
    
    %print the std
    
    if std_abs
        fprintf(fid,'\nstd');
    else
        fprintf(fid,'\nstd/mean');
    end
    
    if isfield(conc(1),'suj_age')
        if std_abs
            fprintf(fid,',%0.1f',std(sa));
        else
            fprintf(fid,',%0.1f',std(sa)./mean(sa));
        end
    end
    
    for kf = 1:length(field_list)
        if ~strcmp(field_list{kf},'suj_age')
            aa = getfield(conc(npool),field_list{kf});
            if isnumeric(aa)
                aa(isnan(aa))=[];
                if std_abs
                    fprintf(fid,',%0.3f',std(aa));
                else
                    fprintf(fid,',%0.3f',std(aa)./mean(aa));
                end
            else
                fprintf(fid,',');
            end
        end
    end
    
    
    fprintf(fid,'\n\n\n\n');
    
end


fclose(fid);
