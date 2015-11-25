function conc = correct_water_content(conc,par)

%if ~isfield(par,'scale_fact')
%  par.scale_fact=1;
%end
if ~isfield(par,'water_faction')
par.water_fraction = [0.78 0.65 0.97];
%    par.water_fraction = [0.83 0.71 1%];
end

if ~isfield(conc(1),'fgray')
  fprintf('no field fgray so no correction ...\n');
  return
end


%compute corection factor, 
for npool = 1:length(conc)
  for k = 1:length(conc(npool).fgray)
    
    wc = [conc(npool).fgray(k) conc(npool).fwhite(k) conc(npool).fcsf(k) ];
      
    fgm  = wc(1)*par.water_fraction(1)/sum(wc.*par.water_fraction);
    fwm  = wc(2)*par.water_fraction(2)/sum(wc.*par.water_fraction);
    fcsf = wc(3)*par.water_fraction(3)/sum(wc.*par.water_fraction);
        
    if 0
      fgm = wc(1) * 0.81;
      fwm = wc(2) * 0.71;
      fcsf = wc(3);

      fgm  = wc(1)*0.81/sum(wc.*[0.81 0.71 0.97]);
      fwm  = wc(2)*0.71/sum(wc.*[0.81 0.71 0.97]);
      fcsf = wc(3)*0.97/sum(wc.*[0.81 0.71 0.97]);
    end
    
    Rgm  = attenuation(par.gmT1,par.gmT2,par.TR,par.TE);
    Rwm  = attenuation(par.wmT1,par.wmT2,par.TR,par.TE);
    Rcsf  = attenuation(par.csfT1,par.csfT2,par.TR,par.TE);



    %    conc(npool).corcsf(k) = 1/(1-fcsf);
%    conc(npool).fgm(k)=fgm;    conc(npool).fwm(k)=fwm;    conc(npool).fcsfm(k)=fcsf;
    
    conc(npool).corcsf(k) = 1/(1-wc(3));
    if length(Rgm)>1;
        
        conc(npool).corAttH2o(k) = fgm.*Rgm(k) + fwm.*Rwm(k) + fcsf.*Rcsf(k);
    else
        conc(npool).corAttH2o(k) = fgm.*Rgm + fwm.*Rwm + fcsf.*Rcsf;
    end
    %    conc(npool).corAttH2o_vol(k) = wc(1)*Rgm + wc(2)*Rwm + wc(3)*Rcsf;
    conc(npool).corWconc(k) = sum( wc .* par.water_fraction) ; 
    
    if isfield(par,'scale_fact')
      conc(npool).corScale(k) = scale_fact;
    
      conc(npool).cor_all(k) = conc(npool).corcsf(k) * conc(npool).corAttH2o(k) * conc(npool).corWconc(k) *  conc(npool).corScale(k) ;
    else
      conc(npool).cor_all(k) = conc(npool).corcsf(k) * conc(npool).corAttH2o(k) * conc(npool).corWconc(k)  ;
    
    end
    
  end
end

