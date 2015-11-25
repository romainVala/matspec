function co = remove_big_correlation(c1,seuil)


if ~exist('seuil')
    seuil=-0.5;
end


if iscell(c1)
    for k=1:length(c1)
        co{k} = remove_big_correlation(c1{k},seuil)
    end
    return
end

co=c1;

  for npool = 1:length(c1)

    cormat = c1(npool).cormat;
    met = c1(npool).met;
    
    for nbsuj=1:length(cormat)
        cm = cormat{nbsuj};
        [i,j] = find(cm<seuil);
        
        fprintf('\n for suj %s cor metab are : ',c1(npool).suj{nbsuj})
        
        for nbm = 1:length(i)

            fprintf(' %s <-> %s ',met{i(nbm)}, met{j(nbm)})

            metname = met{i(nbm)};
            
            cmet = getfield(co(npool),metname);       
            cmet(nbsuj) = cmet(nbsuj)*NaN;
            co(npool) = setfield(co(npool),metname,cmet);

	    metname = met{j(nbm)};
            
            cmet = getfield(co(npool),metname);       
            cmet(nbsuj) = cmet(nbsuj)*NaN;
            co(npool) = setfield(co(npool),metname,cmet);

	end
    %keyboard
    end

  end
