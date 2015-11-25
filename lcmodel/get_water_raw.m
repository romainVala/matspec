function c = get_water_raw(c,lcdir)



for npool = 1:length(c)
  
  pool_dir = fullfile(lcdir,c(npool).pool);

  for nsuj=1:length(c(npool).suj)
    
    fh2o=get_subdir_regex_files(pool_dir, [c(npool).suj{nsuj}(11:end),'.*H2O$']);
    
    if isempty(fh2o)
      keyboard
    end
    
    f=read_raw(char(fh2o));
    
    f=get_water_width(f);
    
    c(npool).water_width(nsuj) = f.water_width;
    c(npool).water_width_no_cor(nsuj) = f.water_width_no_cor;
    c(npool).water_width_lana(nsuj) = f.water_width_lana;
    c(npool).integral_real_fit(nsuj) = f.integral_real_fit ;
    c(npool).integral_real_fit_all(nsuj) = f.integral_real_fit_all ;
    c(npool).integral_fid_abs(nsuj) = f.integral_fid_abs ;
    c(npool).integral_fid_cor_abs(nsuj) = f.integral_fid_cor_abs ;
    c(npool).integral_real(nsuj) = f.integral_real;
    c(npool).integral_real_all(nsuj) = f.integral_real_all;


  end
  
  
end
