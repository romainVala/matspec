function [fid_cor] = processing_MEGA_bis(fids,par)


%same as processing_MEGA

if ~exist('par'), par='';end

if ~isfield(par,'ref_metab'),   par.ref_metab = 'CRE_SMALL2'; end
if ~isfield(par,'correct_freq_mod'),   par.correct_freq_mod='real'; end % or 'abs'

%if ~isfield(par,'')

if ~isfield(par,'do_freq_cor'), par.do_freq_cor=1;     end
if ~isfield(par,'do_phase_cor'), par.do_phase_cor=1;     end
if ~isfield(par,'figure'), par.figure=1;     end

if ~isfield(par,'mean_line_broadening'),par.mean_line_broadening=0;end

switch par.correct_freq_mod
  case 'real'
    bAbsMode=0;
  case 'abs'
    bAbsMode=1;
  otherwise
    error('invalid corre t_freq_mod');
end

fid_cor = fids;

for nb_ser = 1:length(fids)

  
  sp = mbsSpectrum(fids(nb_ser).fid,fids(nb_ser));

  if (par.mean_line_broadening)
    sp_lb = lineBroaden(sp,par.mean_line_broadening/2);
  else
    sp_lb=sp;
  end
  
  %[sp1,sp2] = split(sp);
  
  if par.do_freq_cor
    
    zf = 1       ;  % (zero filing multiple)
  
    [limleft, limright, ppmref] = get_peak_bound(par.ref_metab);
  
    [sp_lb, shiftppm] = referenceSpec(sp_lb,limright,limleft, ppmref,bAbsMode, zf);
  
    sp = shiftSpec(sp, shiftppm);
    
    fid_cor(nb_ser).freq_cor = shiftppm * get(sp,'sfrq');
  
  end
%keyboard
  if par.do_phase_cor
    
    %[sp, rp] = aph0_FDmaxmin(sp); %bof
    [sp, rp] = aph0_FDmax(sp);     %ok
    
    %[sp, rp] = aph0(sp, 10); % very bad
    %[sp, rp,np] = aph0_TDopt(sp) % very bad
    %[sp, rp,np] = aph0_TF(sp)

    
    fid_cor(nb_ser).phase_cor = rp;

  end
  
  fid_cor(nb_ser).fid = get(sp,'fid');
  
  %  [sp1,sp2] = split(sp_cor);
  %  spdiff = average(sp2)-average(sp1);
  %  dif_fids{nb_ser} = get(spdiff,'fid');
  

end
