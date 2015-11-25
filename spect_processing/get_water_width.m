function [spec_out res] = get_water_width(spec_in,do_plot)

if ~exist('do_plot'), do_plot=1,end

base_line_cor=1;
get_integral = 1;


spec_out=spec_in;

for nbser = 1:length(spec_in)
    
    fid= mean(spec_in(nbser).fid,2);
    info = spec_in(nbser);
    spec = info.spectrum;
    
    resolution1 = spec.spectral_widht/(spec.n_data_points-1);
    xHz = spec.FreqAt0:-resolution1: (spec.FreqAt0 - (spec.n_data_points-1)*resolution1);
    
    
    %lana lineshape correction
    
    sw =  spec.SW_h;
    
    for kk = 1:size(fid,2)
        ywat = transpose(fid(:,kk));
        [mConAmpCor mSPhase mT2used] = LineShapeExtract(ywat,sw);
        fidcor(:,kk) =  transpose(LineShapeCorrect(ywat,mConAmpCor,mSPhase,mT2used,sw,0));
        water_width_lana(kk) = 1/mT2used;
    end
    
    fidcor(isnan(fidcor))=0+i*0;
    
    spectrum_cor  = real(fftshift(fft(fidcor),1));
    
    %base line soustraction
    if base_line_cor
        for kk = 1:size(fid,2)
            spectrum_cor(:,kk) = spectrum_cor(:,kk) - mean(spectrum_cor(200:600,kk));
        end
    end
    
    
    spectrum_orig  = real(fftshift(fft(fid(:,1)),1));
    
    spectrum= real(spectrum_cor);
    
    
    %% define start point
    y0= 0; %min(spectrum);
    A=max(spectrum);
    w=5; %10;
    x0=0;
    
    vStart=[y0,A,w,x0];
    
    if ~exist('nlinfit')
        fprintf('todo : can not fit the water ref without nlinfit fonction')
        vEnd=[0 0 0 0]
    else
        vEnd=nlinfit(xHz',spectrum,@Lorentzian,vStart);
        vEnd_orig=nlinfit(xHz',spectrum_orig,@Lorentzian,vStart);
    end
    
    yEnd = Lorentzian(vEnd,xHz);
    yEnd_orig = Lorentzian(vEnd_orig,xHz);
    
    if (do_plot)
        fprintf(  '%s End:  y0=%f  A=%f  w=%f  x0=%f\n', info.Serie_description,vEnd(1),vEnd(2),vEnd(3),vEnd(4));
        figure
        hold on
        plot(xHz,spectrum_orig)
        plot(xHz,yEnd_orig,'--')
        plot(xHz,spectrum,'g')
        plot(xHz,yEnd,'--g')
        
        legend({'original spectra','lorentzian fit','lana lineshape correction','lorentzian fit'})
    end
    
    spec_out(nbser).water_width =  abs(vEnd(3));
    spec_out(nbser).water_width_no_cor =  abs(vEnd_orig(3));
    
    
    ppm_center = 4.7;
    SW_p       = spec.SW_p;	% spectral width in ppm
    np         = spec.np;		% number of points
    dh = spec.SW_h/np;
    
    f_inf3=2.7; 		%1.7 lower bound for zero-phasing the SUM, in ppm
    f_sup3=6.7; 		%7.7 upper bound for zero-phasing the SUM, in ppm
    
    i_f_inf3=round(-(f_sup3-ppm_center)*np/SW_p+np/2)+1;
    i_f_sup3=round(-(f_inf3-ppm_center)*np/SW_p+np/2);
    
    %  spectrum  = real(fftshift(fft(fid),1));
    
    
    if base_line_cor
        new_scale = mean([yEnd(i_f_inf3) , yEnd(i_f_sup3)]);
        yEnd = yEnd - new_scale;
        
        if do_plot
            plot(xHz,yEnd,'g')
        end
        
        yEnd = yEnd - yEnd(1);
        if do_plot
            plot(xHz,yEnd,'g--')
        end
        
    end
    
    
    spec_out(nbser).water_width_lana = water_width_lana;
    
    if get_integral
        spec_out(nbser).integral_real = sum(real(spectrum_cor(i_f_inf3:i_f_sup3)));
        spec_out(nbser).integral_real_fit = sum(yEnd(i_f_inf3:i_f_sup3));
        spec_out(nbser).integral_real_all = sum(real(spectrum_cor));
        spec_out(nbser).integral_real_fit_all = sum(real(yEnd));
        
        
        y=(log(abs(fid(11:50,:))))';
        xx=0:spec.dw:spec.dw*100;
        x=xx(11:50);
        
        [a,b] = fit_ax_b(x,y);
        
        spec_out(nbser).integral_fid_abs = exp(b);
        
        y=(log(abs(fidcor(11:50,:))))';
        xx=0:spec.dw:spec.dw*100;
        x=xx(11:50);
        
        [a,b] = fit_ax_b(x,y);
        
        spec_out(nbser).integral_fid_cor_abs = exp(b);
    end
    
end
if nargout==2
    
    for nbser=1:length(spec_out)
        
        res.water_width(nbser) = spec_out(nbser).water_width;
        res.water_width_no_cor(nbser) = spec_out(nbser).water_width_no_cor;
        res.water_width_lana(nbser) = spec_out(nbser).water_width_lana;
        res.integral_real(nbser) = spec_out(nbser).integral_real;
        res.integral_real_fit(nbser) = spec_out(nbser).integral_real_fit;
        res.integral_real_all(nbser) = spec_out(nbser).integral_real_all;
        res.integral_real_fit_all(nbser) = spec_out(nbser).integral_real_fit_all;
        res.integral_fid_abs(nbser) = spec_out(nbser).integral_fid_abs;
        res.integral_fid_cor_abs(nbser) = spec_out(nbser).integral_fid_cor_abs;
        
    end
    
end

if 0
    phase_test=(-pi:0.05:pi);
    for m=1:length(phase_test)
        fid_phase = exp(-1i*phase_test(m))*fid;
        spectrum_fid=fftshift(fft(fid_phase),1);
        
        integral_real(m) = sum(real(spectrum_fid(i_f_inf3:i_f_sup3,:)))*dh;
        %  integral_imag(m) = sum(imag(exp(-1i*phase_test(m))*spectrum_fid));
    end
    spec_out(nbser).integral_abs = sum(abs(spectrum_fid))*dh;
    
    [spec_out(nbser).integral_real,ind] = max(integral_real);
    spec_out(nbser).wat_phase = phase_test(ind)/pi*180;
    
end
