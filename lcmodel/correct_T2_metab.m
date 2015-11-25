function c = correct_T2_metab(c1,metab,typee)

if ~exist('typee'), typee='';end

if iscell(c1)
    for k=1:length(c1)
        c{k} = correct_T2_metab(c1{k},metab,typee)
    end
    return
end

c=c1;


if ~exist('metab')
    
    met = find_metab_list(c1);
    for nbmet=1:length(met)
        c = correct_T2_metab(c,met{nbmet},typee);
    end
    
    return
else
    if iscell(metab)
        %oups
        typee=metab{1};
        clear metab;
    end
    
end


for npool = 1:length(c1)
    
    cmet = getfield(c1(npool),metab);
    
    if ~isempty(typee)
        poolname = typee;
    else
        poolname = c1(npool).pool;
    end
    
    
    switch metab
        case {'NAA','NAAG','NAA_NAAG'}
            
            if findstr(poolname,'BG')
                t2att = 1/exp(-64/221)*1/(1-exp(-3000/1350));
                
            elseif findstr(poolname,'MC')
                t2att = 1/exp(-64/247)*1/(1-exp(-3000/1350));
                
            elseif findstr(poolname,'CER')
                t2att = 1/exp(-64/287)*1/(1-exp(-3000/1350));
                
            elseif findstr(poolname,'C_SEAD')
                t2att = 1/exp(-28/287)*1/(1-exp(-5000/1350));
                
            elseif findstr(poolname,'OCC')
                t2att = 1/exp(-64/301)*1/(1-exp(-3000/1350));
                
            elseif findstr(upper(poolname),'HIPO')
                t2att = 1/exp(-64/325)*1/(1-exp(-3000/1350));
                t2att = 1/exp(-64/324)*1/(1-exp(-3000/1350));
                t2att = 1/exp(-64/(324*1.5))*1/(1-exp(-3000/1350));
                
            else
                error('region %s is not defined',poolname)
            end
            
        case {'PCho','GPC','PCho_GPC'}
            
            if findstr(poolname,'BG')
                t2att = 1/exp(-64/201)*1/(1-exp(-3000/1145));
                
            elseif findstr(poolname,'MC')
                t2att = 1/exp(-64/222)*1/(1-exp(-3000/1145));
                
            elseif findstr(poolname,'CER')
                t2att = 1/exp(-64/287)*1/(1-exp(-3000/1350));
                
            elseif findstr(poolname,'C_SEAD')
                t2att = 1/exp(-28/287)*1/(1-exp(-5000/1350));
                
            elseif findstr(poolname,'OCC')
                t2att = 1/exp(-64/222)*1/(1-exp(-3000/1145));
                
            elseif findstr(upper(poolname),'HIPO')
                t2att = 1/exp(-64/220)*1/(1-exp(-3000/1145));
                t2att = 1/exp(-64/312)*1/(1-exp(-3000/1145));
                t2att = 1/exp(-64/(312*1.5))*1/(1-exp(-3000/1145));
                
            else
                error('region %s is not defined',poolname)
            end
            
        case {'Cr','PCr','Cr_PCr'}
            
            if findstr(poolname,'BG')
                %	t2att = 1/exp(-64/mean([143 112]))*1/(1-exp(-3000/1350));
                t2att = 1/exp(-64/143)*1/(1-exp(-3000/1350));
                
            elseif findstr(poolname,'MC')
                %	t2att = 1/exp(-64/mean([162 121]))*1/(1-exp(-3000/1350));
                t2att = 1/exp(-64/162)*1/(1-exp(-3000/1350));
                
            elseif findstr(poolname,'CER')
                %	t2att = 1/exp(-64/mean([178 134]))*1/(1-exp(-3000/1350));
                t2att = 1/exp(-64/178)*1/(1-exp(-3000/1350));
                
            elseif findstr(poolname,'C_SEAD')
                t2att = 1/exp(-28/178)*1/(1-exp(-5000/1350));
                
            elseif findstr(poolname,'OCC')
                %	t2att = 1/exp(-64/mean([178 127]))*1/(1-exp(-3000/1350));
                t2att = 1/exp(-64/178)*1/(1-exp(-3000/1350));
                
            elseif findstr(upper(poolname),'HIPO')
                t2att = 1/exp(-64/175)*1/(1-exp(-3000/1350));
                t2att = 1/exp(-64/180)*1/(1-exp(-3000/1350));
                t2att = 1/exp(-64/(180*1.5))*1/(1-exp(-3000/1350));
                
            else
                error('region %s is not defined',poolname)
            end
            
        otherwise
            if npool ==1
                fprintf('taking CrCh2 for %s \n',metab)
            end
            
            if findstr(poolname,'BG')
                %	t2att = 1/exp(-64/mean([143 112]))*1/(1-exp(-3000/1000));
                t2att = 1/exp(-64/112)*1/(1-exp(-3000/1000));
                
            elseif findstr(poolname,'MC')
                %	t2att = 1/exp(-64/mean([162 121]))*1/(1-exp(-3000/1000));
                t2att = 1/exp(-64/121)*1/(1-exp(-3000/1000));
                
            elseif findstr(poolname,'CER')
                %	t2att = 1/exp(-64/mean([178 134]))*1/(1-exp(-3000/1000));
                t2att = 1/exp(-64/134)*1/(1-exp(-3000/1000));
                
            elseif findstr(poolname,'C_SEAD')
                t2att = 1/exp(-28/134)*1/(1-exp(-5000/1000));
                
            elseif findstr(poolname,'OCC')
                %	t2att = 1/exp(-64/mean([178 127]))*1/(1-exp(-3000/1000));
                t2att = 1/exp(-64/127)*1/(1-exp(-3000/1000));
                
            elseif findstr(upper(poolname),'HIPO')
                t2att = 1/exp(-64/175)*1/(1-exp(-3000/1350));
                t2att = 1/exp(-64/180)*1/(1-exp(-3000/1350));
                t2att = 1/exp(-64/(180*1.5))*1/(1-exp(-3000/1350));
                
            else
                error('region %s is not defined',poolname)
            end
            
    end
    
    cc = cmet .* t2att;
    
    c(npool)  = setfield(c(npool),metab,cc);
    
end

