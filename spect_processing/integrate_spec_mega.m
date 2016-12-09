function [spec_integral posppm] = integrate_spec_mega(fids,ppm_bound,par)
% RETURNS: the integral and centroid of the peak (in ppm)

if ~exist('par'), par='';end

if ~isfield(par,'spect'),   par.ref_metab = 'diff'; end %first second
if ~isfield(par,'spect_mod'),   par.spect_mod='abs'; end % or 'real'


for nbser = 1:length(fids)
    
    fid = fids(nbser).fid;
    info = fids(nbser);
    
    spec = info.spectrum;
    resolution1 = spec.spectral_widht/(spec.n_data_points-1)/spec.synthesizer_frequency;
    freqat0ppm1 = spec.FreqAt0/spec.synthesizer_frequency+spec.ppm_center;
    %Fppm =  freqat0ppm1:resolution1:freqat0ppm1+(spec.n_data_points-1)*resolution1;
    Fppm =  (freqat0ppm1:-resolution1:freqat0ppm1-(spec.n_data_points-1)*resolution1)';
    
    ns = size(fid,2)/2;
    
    fid1 = fid(:,1:ns);
    fid2 = fid(:,(ns+1):end);
    fid1m = mean(fid1,2);
    fid2m = mean(fid2,2);
    
    spec1m = fftshift(fft(fid1m));
    spec2m = fftshift(fft(fid2m));
    
    diffspecm = spec2m-spec1m;
    
    switch par.spect_mod
        case 'real'
            diffspecm = real(diffspecm);
        case 'abs'
            diffspecm = abs(diffspecm);
    end
    
    f_sup = ppm_bound(2); f_inf = ppm_bound(1);
    zero_filling=length(diffspecm);
    
    ppm_center = info.spectrum.ppm_center;	% receiver (4.7 ppm)
    SW_p       = info.spectrum.SW_p;	% spectral width in ppm
    
    i_f_METAB_inf=round(-(f_sup-ppm_center)*(zero_filling-1)/SW_p+(zero_filling-1)/2)+1;
    i_f_METAB_sup=round(-(f_inf-ppm_center)*(zero_filling-1)/SW_p+(zero_filling-1)/2)+1;
    
    spec_integral(nbser) = sum(diffspecm(i_f_METAB_inf:i_f_METAB_sup)) / length(diffspecm(i_f_METAB_inf:i_f_METAB_sup));
    
    integralW = sum(diffspecm(i_f_METAB_inf:i_f_METAB_sup) .* Fppm(i_f_METAB_inf:i_f_METAB_sup));
    posppm(nbser) = integralW /  sum(diffspecm(i_f_METAB_inf:i_f_METAB_sup)) ;
    
end


