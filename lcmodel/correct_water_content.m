function conc = correct_water_content(conc,scale_fact,ttype)

if ~exist('ttype')
  ttype=0;
end

%ttype=0  spectro dystonie
%ttype=1  spectro hypocampus
%ttype=2  spectro 7T gosia

if ~exist('scale_fact')
  scale_fact=1;
end


if ~isfield(conc(1),'fgray')
  fprintf('no field fgray so no correction ...\n');
  return
end


%just a corection for subject which has  csf=1 (because no anat)
for npool = 1:length(conc)
  ind=find(conc(npool).fcsf==1);
  if ~isempty(ind)
    aac = conc(npool).fcsf([1:(ind-1),(ind+1):end]);
    aag = conc(npool).fgray([1:(ind-1),(ind+1):end]);
    aaw = conc(npool).fwhite([1:(ind-1),(ind+1):end]);
    conc(npool).fcsf(ind)= mean(aac);
    conc(npool).fgray(ind)= mean(aag);
    conc(npool).fwhite(ind)= mean(aaw);
    fprintf('WARNING taking mean valu for pool %d suj %d\n',npool,ind)
  end
end


%compute corection factor, 
for npool = 1:length(conc)
  for k = 1:length(conc(npool).fgray)
    
    wc = [conc(npool).fgray(k) conc(npool).fwhite(k) conc(npool).fcsf(k) ];
    watter_fraction = [0.78 0.65 0.97];
%    watter_fraction = [0.83 0.71 1%];
      
    fgm  = wc(1)*watter_fraction(1)/sum(wc.*watter_fraction);
    fwm  = wc(2)*watter_fraction(2)/sum(wc.*watter_fraction);
    fcsf = wc(3)*watter_fraction(3)/sum(wc.*watter_fraction);
        
    if 0
      fgm = wc(1) * 0.81;
      fwm = wc(2) * 0.71;
      fcsf = wc(3);

      fgm  = wc(1)*0.81/sum(wc.*[0.81 0.71 0.97]);
      fwm  = wc(2)*0.71/sum(wc.*[0.81 0.71 0.97]);
      fcsf = wc(3)*0.97/sum(wc.*[0.81 0.71 0.97]);
    end
    
    if ttype==1
      Rgm  = attenuation(1000,70,15000,65);
      Rwm  = attenuation(1000,70,15000,65);
      Rcsf = attenuation(4000,400,15000,65);

    elseif ttype==111
      Rgm  = attenuation(1000,70*1.1,15000,65);
      Rwm  = attenuation(1000,70*1.1,15000,65);
      Rcsf = attenuation(4000,400*1.1,15000,65);
    elseif ttype==115
      Rgm  = attenuation(1000,70*1.5,15000,65);
      Rwm  = attenuation(1000,70*1.5,15000,65);
      Rcsf = attenuation(4000,400*1.5,15000,65);

    elseif ttype==11
      Rgm  = attenuation(1000,110*1.1,15000,65);
      Rwm  = attenuation(1000,79*1.1,15000,65);
      Rcsf = attenuation(4000,400*1.1,15000,65);

      %Rgm  = attenuation(1000,80,15000,65);
      %Rwm  = attenuation(1000,70,15000,65);
      %Rcsf = attenuation(5000,500,15000,65);
    elseif ttype==0
      Rgm  = attenuation(1000,70,3000,68);
      Rwm  = attenuation(1000,70,3000,68);
      Rcsf = attenuation(4000,400,3000,68);
    elseif ttype==3
      Rgm  = attenuation(1000,70,3000,18);
      Rwm  = attenuation(1000,70,3000,18);
      Rcsf = attenuation(4000,400,3000,18);
    elseif ttype==4
      Rgm  = attenuation(1000,70,5000,28);
      Rwm  = attenuation(1000,70,5000,28);
      Rcsf = attenuation(4000,600,5000,28);

    elseif ttype==5   %pierre Giles biosca
      
      Rgm  = attenuation(1000,70,5000,28);
      Rwm  = attenuation(1000,70,5000,28);
      Rcsf = attenuation(4000,600,5000,28);
      fgm=1;fwm=0;fcsf=0;
      Rgm = exp((-28/70));
      watter_fraction = [0.82 0.82 1];

    elseif ttype==2
      
      if findstr( conc(npool).pool,'BG')
	Rgm  = attenuation(1523,41,4500,35);
	Rwm  = attenuation(1523,41,4500,35);
	Rcsf = attenuation(4425,41,4500,35);
	
      elseif findstr( conc(npool).pool,'MC')
%error	Rgm  = attenuation(1530,55,4500,35);
%error	Rwm  = attenuation(2130,50,4500,35);
	Rgm  = attenuation(2132,55,4500,35);
	Rwm  = attenuation(1220,50,4500,35);
	Rcsf = attenuation(4425,141,4500,35);
	
      elseif findstr( conc(npool).pool,'OCC')	
	Rgm  = attenuation(2132,55,4500,35);
	Rwm  = attenuation(1220,50,4500,35);
	Rcsf = attenuation(4425,141,4500,35);

      elseif findstr( conc(npool).pool,'CER')
 
	Rgm  = attenuation(2132,49,4500,35);
	Rwm  = attenuation(1220,49,4500,35);
	Rcsf = attenuation(4425,49,4500,35);
     
      else
	error('unkown region')
      end
      
      %      Rgm  = attenuation(1530,88,4500,35);
      %      Rwm  = attenuation(2130,88,4500,35);
      %      Rcsf = attenuation(4400,400,4500,35);
      %Rwm=Rgm;Rcsf=Rgm;
    else
      error('unkown type')
      
    end

%    conc(npool).corcsf(k) = 1/(1-fcsf);
%    conc(npool).fgm(k)=fgm;    conc(npool).fwm(k)=fwm;    conc(npool).fcsfm(k)=fcsf;
    
    conc(npool).corcsf(k) = 1/(1-wc(3));
    conc(npool).corAttH2o(k) = fgm*Rgm + fwm*Rwm + fcsf*Rcsf;
%    conc(npool).corAttH2o_vol(k) = wc(1)*Rgm + wc(2)*Rwm + wc(3)*Rcsf;
    conc(npool).corWconc(k) = sum( wc .* watter_fraction) ; 
    conc(npool).corScale(k) = scale_fact;
    conc(npool).cor_all(k) = conc(npool).corcsf(k) * conc(npool).corAttH2o(k) * conc(npool).corWconc(k) *  conc(npool).corScale(k) ;
%    conc(npool).cor_all2(k) = conc(npool).corcsf(k) * conc(npool).corAttH2o_vol(k) * conc(npool).corWconc(k) *  conc(npool).corScale(k) ;

    
    
  end
end

if 0
  npool=1;
  
  conc(npool).intrafgray = conc(npool).fgray;
  conc(npool).intrafwhite = conc(npool).fwhite;
  conc(npool).intrafcsf = conc(npool).fcsf;
  for k= 2:3
    conc(npool).fgray(k) = conc(npool).fgray(1);
    conc(npool).fwhite(k) = conc(npool).fwhite(1);
    conc(npool).fcsf(k) = conc(npool).fcsf(1);

    if k==2
      conc(npool).fgray(k+3) = conc(npool).fgray(4);
      conc(npool).fwhite(k+3) = conc(npool).fwhite(4);
      conc(npool).fcsf(k+3) = conc(npool).fcsf(4);
    end
    
    conc(npool).fgray(k+5) = conc(npool).fgray(6);
    conc(npool).fwhite(k+5) = conc(npool).fwhite(6);
    conc(npool).fcsf(k+5) = conc(npool).fcsf(6);
    
  end
  
  
for npool = 2:length(conc)
  conc(npool).intrafgray = conc(npool).fgray;
  conc(npool).intrafwhite = conc(npool).fwhite;
  conc(npool).intrafcsf = conc(npool).fcsf;
  
  for k= 2:3
    conc(npool).fgray(k) = conc(npool).fgray(1);
    conc(npool).fwhite(k) = conc(npool).fwhite(1);
    conc(npool).fcsf(k) = conc(npool).fcsf(1);

    conc(npool).fgray(k+3) = conc(npool).fgray(4);
    conc(npool).fwhite(k+3) = conc(npool).fwhite(4);
    conc(npool).fcsf(k+3) = conc(npool).fcsf(4);
    
    conc(npool).fgray(k+6) = conc(npool).fgray(7);
    conc(npool).fwhite(k+6) = conc(npool).fwhite(7);
    conc(npool).fcsf(k+6) = conc(npool).fcsf(7);
    
  end
  
end

  
end
