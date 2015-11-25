function cout =  get_all_correlation(conc)

if iscell(conc)
    for k=1:length(conc)
        cout{k} = get_all_correlation(conc{k});
    end
    return
end
      
for npool = 1:length(conc)
    
    aan = getfield(conc(npool),'met');
    
    aa = getfield(conc(npool),'cormat');
    
    
    for nm=1:length(aan)
        for km = nm+1:length(aan)
            corname = sprintf('%s_cor_%s',aan{nm},aan{km});
            
            for ks=1:length(aa)
                cormat = aa{ks};
                thecor(ks) = cormat(km,nm);
            end
            if ~exist('cc','var')
                cc=conc(npool);
            end
            
            cc = setfield(cc,corname,thecor);
            
        end
    end
    
    cout(npool) = cc;
    clear cc
end

