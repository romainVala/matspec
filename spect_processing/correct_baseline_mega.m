function [fo] = correct_baseline_mega(fids,nb_point)
% RETURNS: the integral and centroid of the peak (in ppm)
% nb_point number of points to estimate, from the end of the means spectra

fo = fids
for nbser = 1:length(fids)
    
    fid = fids(nbser).fid;
    info = fids(nbser);
    
    ppm_center = info.spectrum.ppm_center;	% receiver (4.7 ppm)
    SW_p       = info.spectrum.SW_p;	% spectral width in ppm

    spec = info.spectrum;
    resolution1 = spec.spectral_widht/(spec.n_data_points-1)/spec.synthesizer_frequency;
    freqat0ppm1 = spec.FreqAt0/spec.synthesizer_frequency+spec.ppm_center;
    Fppm =  (freqat0ppm1:-resolution1:freqat0ppm1-(spec.n_data_points-1)*resolution1)';
    
    ns = size(fid,2)/2;
    
    fid1 = fid(:,1:ns);
    fid2 = fid(:,(ns+1):end);
    fid1m = mean(fid1,2);
    fid2m = mean(fid2,2);
    
    spec1 = fftshift(fft(fid1));
    spec2 = fftshift(fft(fid2));
    
    spec1m = fftshift(fft(fid1m));
    spec2m = fftshift(fft(fid2m));
    
    spec1 = spec1 -  mean(spec1m(end-nb_point: end));
    
    spec2 = spec2 -  mean(spec2m(end-nb_point: end));
    
    fid1_corected = ifft(ifftshift(spec1));
    fid2_corected = ifft(ifftshift(spec2));
    
    
    fo(nbser).fid = [fid1_corected fid2_corected];
    
    end
end

