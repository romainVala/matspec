function [ fids_cor , phases] = correct_phase(fids,spec_info,bound)


if ~iscell(fids)
  fids = {fids};
end

if ~exist('bound'), bound=[-0.1;0.1];end

f_inf_phase = bound(1); 		% lower bound for zero-phasing the SUM, in ppm
f_sup_phase = bound(2); 		% upper bound for zero-phasing the SUM, in ppm



for nb_ser = 1:length(fids)

  ppm_center = spec_info{nb_ser}.spectrum.ppm_center;  % receiver (4.7 ppm)
  magfield   = spec_info{nb_ser}.spectrum.magfield;	% magnetic field (2.8936 T)
  cenfreq    = spec_info{nb_ser}.spectrum.cenfreq;	% center frequency of acquisition in Hz
  SW_h       = spec_info{nb_ser}.spectrum.SW_h;	% spectral width in Hz
  SW_p       = spec_info{nb_ser}.spectrum.SW_p;	% spectral width in ppm
  np         = spec_info{nb_ser}.spectrum.np;		% number of points
  dw         = spec_info{nb_ser}.spectrum.dw;		% dwell time	
  zero_filling = np;						

  fid_ser = fids{nb_ser};

  i_f_inf_phase=round(-(f_sup_phase-ppm_center)*zero_filling/SW_p+zero_filling/2)+1;
  i_f_sup_phase=round(-(f_inf_phase-ppm_center)*zero_filling/SW_p+zero_filling/2);

  for nb_fid = 1:size(fid_ser,2)
    
    fid = fid_ser(:,nb_fid);
    
    spectrum_fid=fftshift(fft(fid));

    phase_test=(-pi:0.01:pi);

    %integral_imag_0 = abs(sum(imag(exp(1i*phase_test(1))*spectrum_fid(i_f_inf_phase:i_f_sup_phase))));
    integral_imag_0 =  sum(abs(imag(exp(1i*phase_test(1))*spectrum_fid(i_f_inf_phase:i_f_sup_phase))));
    phase_index=1;
  
    for m=1:length(phase_test)
      integral_imag=sum(abs(real(exp(1i*phase_test(m))*spectrum_fid(i_f_inf_phase:i_f_sup_phase))));
      
      integral_neg = sum((real(exp(1i*phase_test(m))*spectrum_fid(i_f_inf_phase:i_f_sup_phase))));
	
      if integral_imag < integral_imag_0 & integral_neg>0; 
	phase_index=m;
	%added rrr
	integral_imag_0 = integral_imag;
      end
    end
		
    phase(nb_fid) = phase_test(phase_index);

    fid_cor(:,nb_fid) = exp(1i*phase(nb_fid))*fid;    

  end
  
  fids_cor{nb_ser} = fid_cor;
  phases{nb_ser} = phase;

    
end
