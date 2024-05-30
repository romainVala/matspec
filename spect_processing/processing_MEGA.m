function [spec_cor] = processing_MEGA(fid_struct,par)
%function [dif_fids fid_cor phase_cor freq_cor] = processing_MEGA(spec_info,par)
% see the help in processing_spec, the same struct par is used with the
% same option
%
% Romain (Oct 2007) : change the input parameters, to take a cell array of fid and
% written by Malgorzata Marjanska with help from Julien Valette and Eddie Auerbach
% september 17, 2007


if ~exist('par'), par='';end

if ~isfield(par,'ref_metab'),   par.ref_metab = 'CRE_SMALL2'; end
if ~isfield(par,'correct_freq_mod'),   par.correct_freq_mod='real'; end % or 'abs'
if ~isfield(par,'method'), par.method = 'max';end % max or correlation
if ~isfield(par,'correlation_bound'), par.correlation_bound = '';end % max or correlation

%if ~isfield(par,'')

if ~isfield(par,'do_freq_cor'), par.do_freq_cor=1;     end
if ~isfield(par,'do_phase_cor'), par.do_phase_cor=1;     end
if ~isfield(par,'correct_to_ref_metab'),par.correct_to_ref_metab =1; end

if ~isfield(par,'correct_diff_phase'),par.correct_diff_phase =0; end

if ~isfield(par,'mega_separate_edit'), par.mega_separate_edit = 0; end  %if 0 process edit and editoff in one step otherwise process each separatly
if ~isfield(par,'figure'), par.figure=1;     end

if ~isfield(par,'process_diff_only'), par.process_diff_only=0;     end

if ~isfield(par,'mean_line_broadening'),par.mean_line_broadening=0;end %%%voir ligne 120!!!

if ~isfield(par,'stop_if_warning'),par.stop_if_warning=0;end %%%voir ligne 120!!!

if nargin==0
    spec_cor=par;
    return
end

flag_toolbox = 'n';

spec_cor = fid_struct;

for nb_spec = 1:length(fid_struct)
    
    ppm_center = fid_struct(nb_spec).spectrum.ppm_center;	% receiver (4.7 ppm)
    magfield   = fid_struct(nb_spec).spectrum.magfield;	% magnetic field (2.8936 T)
    cenfreq    = fid_struct(nb_spec).spectrum.cenfreq;	% center frequency of acquisition in Hz
    SW_h       = fid_struct(nb_spec).spectrum.SW_h;	% spectral width in Hz
    SW_p       = fid_struct(nb_spec).spectrum.SW_p;	% spectral width in ppm
    np         = fid_struct(nb_spec).spectrum.np;		% number of points
    dw         = fid_struct(nb_spec).spectrum.dw;		% dwell time
    zero_filling = np;
    
    fid = fid_struct(nb_spec).fid;
    
    size_mid = size(fid,2)/2;
    %  fid2 = transpose(fid(:,1:size_mid));
    %  fid3 = transpose(fid(:,size_mid+1:end));
    fid2 = permute(fid(:,1:size_mid),[2 1]);
    fid3 = permute(fid(:,size_mid+1:end),[2 1]);

    %used if mega_separate_edit == 0
    fidall = permute(fid(:,1:size(fid,2)),[2 1]); %fb

    % performing frequency and phase correction
    
    switch par.method
        case 'max'
            if (par.process_diff_only)
                
                [sum2 fid2_cor phase_cor1 freq_cor1 ] = add_array_scans_bis_Cre((fid3-fid2),SW_h,SW_p,ppm_center,par,fid_struct(nb_spec));
                
                
                pas_temps=1/SW_h;	% pas (en s) entre 2 points complexes successifs;
                zero_filling=size(fid2,2);
                
                k=(1:1:zero_filling);
                
                
                for nss= 1:size(fid2,1)
                    correction = exp(-2*pi*1i*freq_cor1(nss)*(k-1)*pas_temps);
                    fid2(nss,:) = fid2(nss,:) .* correction;
                    fid3(nss,:) = fid3(nss,:) .* correction;
                    
                end
                spec_cor(nb_spec).fid =  [permute(fid2,[2 1]) permute(fid3,[2 1])];
                
                
            else
                if par.mega_separate_edit
                    
                    [sum2 fid2_cor phase_cor1 freq_cor1 ] = add_array_scans_bis_Cre(fid2,SW_h,SW_p,ppm_center,par,fid_struct(nb_spec));
                    [sum3 fid3_cor phase_cor2 freq_cor2 ] = add_array_scans_bis_Cre(fid3,SW_h,SW_p,ppm_center,par,fid_struct(nb_spec));
                    %    fid_cor(nb_spec) = [transpose(fid2_cor) transpose(fid3_cor)];
                    
                    spec_cor(nb_spec).fid = [permute(fid2_cor,[2 1]) permute(fid3_cor,[2 1])];
                else %all in one
                    [sumall fidall_cor phase_cor freq_cor ] = add_array_scans_bis_Cre(fidall,SW_h,SW_p,ppm_center,par,fid_struct(nb_spec)); %fb

                    spec_cor(nb_spec).fid = [permute(fidall_cor,[2 1])]; %fb
                    
                    fidall_cor = [permute(fidall_cor,[2 1])]; %fb
                    
                    fid2_cor = fidall_cor(:,1:size_mid); %fb
                    fid3_cor = fidall_cor(:,size_mid+1:end); %fb
                    
                    sum2=permute(sum(fid2_cor, 2),[2 1]);    sum3=permute(sum(fid3_cor, 2),[2 1]);

                end
            end
            
        case 'correlation'
            if par.mega_separate_edit
                
                [fid2_cor phase_cor1 freq_cor1 ] = correct_freq_and_phase_by_correlation(permute(fid2,[2 1]),par,fid_struct(nb_spec));
                [fid3_cor phase_cor2 freq_cor2 ] = correct_freq_and_phase_by_correlation(permute(fid3,[2 1]),par,fid_struct(nb_spec));
                spec_cor(nb_spec).fid = [fid2_cor , fid3_cor];
                sum2=permute(sum(fid2_cor,2),[2 1]);sum3=permute(sum(fid3_cor,2),[2 1]);
            
            else
                
                [fidall_cor phase_cor freq_cor ] = correct_freq_and_phase_by_correlation(permute(fidall,[2 1]),par,fid_struct(nb_spec)); %fb
                spec_cor(nb_spec).fid = [fidall_cor]; %fb
                
                fid2_cor = fidall_cor(:,1:size_mid); %fb
                fid3_cor = fidall_cor(:,size_mid+1:end); %fb
                
                sum2=permute(sum(fid2_cor,2),[2 1]);    sum3=permute(sum(fid3_cor,2),[2 1]);

            end
    end
    
    if par.mega_separate_edit
        
        spec_cor(nb_spec).phase_cor = [phase_cor1', phase_cor2'];
        spec_cor(nb_spec).freq_cor =  [freq_cor1(1:end-2)', freq_cor2(1:end-2)'];
        spec_cor(nb_spec).max_freq_shift = max(spec_cor(nb_spec).freq_cor) -min(spec_cor(nb_spec).freq_cor);
    else
        spec_cor(nb_spec).phase_cor = [phase_cor'];
        spec_cor(nb_spec).freq_cor =  [freq_cor(1:end-2)'];
        spec_cor(nb_spec).max_freq_shift = max(spec_cor(nb_spec).freq_cor) -min(spec_cor(nb_spec).freq_cor);
        
    end
    
    if par.correct_diff_phase 		% correction of phase of difference spectrum
        dif_fid=sum3-sum2;
         dif_fid0 = dif_fid;
         
        f_inf3=0; 		% lower bound for zero-phasing the SUM, in ppm
        f_sup3=4; 		% upper bound for zero-phasing the SUM, in ppm
        i_f_inf3=round(-(f_sup3-ppm_center)*zero_filling/SW_p+zero_filling/2)+1;
        i_f_sup3=round(-(f_inf3-ppm_center)*zero_filling/SW_p+zero_filling/2);
        
        spectrum_dif_fid=fftshift(fft(dif_fid));
        
        phase_test=(-0.5:0.01:0.5);
        phase_test=(-1.0:0.01:1.0);
        
        integral_imag_0=abs(sum(imag(exp(1i*phase_test(1))*spectrum_dif_fid(i_f_inf3:i_f_sup3))));
        phase_index=1;
        
        for m=1:length(phase_test)
            integral_imag=abs(sum(imag(exp(1i*phase_test(m))*spectrum_dif_fid(i_f_inf3:i_f_sup3))));
            
            if integral_imag<integral_imag_0;
                phase_index=m;
                integral_imag_0=integral_imag;
            end
        end
        
        phase=phase_test(phase_index)
        
        dif_fid=exp(1i*phase)*dif_fid;
        
        if (par.figure)
            figure;  hold on
            plot(real(fftshift(fft(dif_fid))),'r');	% plots final spectrum without any line broadening
            plot(real(fftshift(fft(dif_fid0))));	% plots final spectrum without any line broadening
        end
        
        pphase = -phase*180/pi;
        spec_cor = change_phase(spec_cor,pphase);
    
    else
        
        dif_fid=sum3-sum2;
        dif_fid0 = dif_fid;
        
        % saving spectra in .mat, . RAW formats and displaying spectra for inspection
        %eval(['save ' file_name ' dif_fid sum2 sum3']);
        
        lb=2;							% lb= 2 Hz
        
        t=[0:dw:(np-1)*dw];
        dif_fid_lb=dif_fid.*exp(-t*pi*lb);
        if (par.figure)
            
            figure
            plot(real(fftshift(fft(dif_fid_lb))));				% plots final spectrum with lb = 2 Hz
        end
    end
    
    %%%%%%%%   LC MODEL
    %  rp=0;								% zero order phase correction - LCModel
    %  lp=0;								% first order phase correction - LCModel
    
    %  dif_fid_lc = transpose(dif_fid);
    %  dif_fid_lc = [real(dif_fid) imag(dif_fid)];
    
    %  keyboard
    %  file_name = nettoie_dir(spec_info(nb_spec).Serie_description);
    
    %  createrawfile_mm_3T_CENIR('./',file_name,dif_fid,cenfreq,np,dw,rp,lp);
    
    
end



