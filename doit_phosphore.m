 f=explore_spectro_data

 par=plot_spectrum
 par.mean_line_broadening=6

 plot_spectrum(f,par)      

 

 pp=processing_spec       
 
 fc=processing_spec(f,pp)
 
 
 %pour le fonction dans mbspectrum
 
 %1 conversion ver object mbspectrum
 
  sp = mbsSpectrum(f.fid,f);

  %ensuite on peut faire les fonctions de mbspectrum par ex
  
  sp_lb = lineBroaden(sp,par.mean_line_broadening/2);

      
    %[sp, rp] = aph0_FDmaxmin(sp); %bof
    [sp2, rp] = aph0_FDmax(sp);     %ok
    
    %[sp, rp] = aph0(sp, 10); % very bad
    %[sp, rp,np] = aph0_TDopt(sp) % very bad
    %[sp, rp,np] = aph0_TF(sp)

    sp3 = phaseSpecLinear(sp2,0,10)
     
    %pour revenir au structure fid
    
    fc.fid = get(sp,'fid');
  