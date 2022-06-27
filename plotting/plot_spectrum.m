function varargout = plot_spectrum(spec_info,param)

if ~exist('param'), param='';end

if ~isfield(param,'display'),  param.display = 'real';end
if ~isfield(param,'display_var'),  param.display_var = 1; end
if ~isfield(param,'mean_line_broadening'),  param.mean_line_broadening = 0;end

if ~isfield(param,'xlim'), param.xlim='auto';end
if ~isfield(param,'ylim'), param.ylim='auto';end
if ~isfield(param,'diff_y_lim'), param.diff_y_lim='auto';end
if ~isfield(param,'plot_ref_peak'), param.plot_ref_peak = '';end

%  param.x_freq = any;
%  param.plot_ref_peak  ='CRE' plot the bound used for CRE

if ~isfield(param,'same_fig'),  param.same_fig = 0; end
if ~isfield(param,'save_file') , param.save_file='';end
%if ~isfield(param,'mega_disp_sum') ,
param.mega_disp_sum = 0;

if nargin==0
    varargout{1}=param;
    return
end

if length(spec_info)<=3,  all_color=[0 0 1;0 1 0;1 0 0];else  all_color=jet(length(spec_info));end


for nbser = 1:length(spec_info)
    fid= spec_info(nbser).fid;
    
    if isa(fid,'mbsSpectrum')
        sp = fid;
        fid = get(sp,'fid');
    end
    
    info = spec_info(nbser);
    
    spec = info.spectrum;
    resolution1 = spec.spectral_widht/(spec.n_data_points-1)/spec.synthesizer_frequency;
    freqat0ppm1 = spec.FreqAt0/spec.synthesizer_frequency+spec.ppm_center;
    %Fppm =  freqat0ppm1:resolution1:freqat0ppm1+(spec.n_data_points-1)*resolution1;
    Fppm =  freqat0ppm1:-resolution1:freqat0ppm1-(spec.n_data_points-1)*resolution1;
    
    Fppm(2)-Fppm(1)
    
    if isfield(param,'x_freq')
        resolution1 = spec.spectral_widht/(spec.n_data_points-1);
        Fppm = spec.FreqAt0:-resolution1: (spec.FreqAt0 - (spec.n_data_points-1)*resolution1);
    end
    
    if (param.mean_line_broadening)
        t=[0:spec.dw:(spec.np-1)*spec.dw]';
        for k=1:size(fid,2)
            fid(:,k) = fid(:,k) .* exp(-t*pi*param.mean_line_broadening);
        end
    end
    
    
    if ~isempty(findstr(info.seqname,'mega')) | ~isempty(findstr(info.seqname,'mslaser')) | ~isempty(findstr(info.seqname,'_edit'))
        %fid1 = transpose(fid(:,1:(info.Number_of_spec)/2));
        %fid2 = transpose(fid(:,(info.Number_of_spec/2+1):end));
        
        ns = size(fid,2)/2;
        fid1 = fid(:,1:ns);
        fid2 = fid(:,(ns+1):end);
        fid1m = mean(fid1,2);
        fid2m = mean(fid2,2);
        
        %    if (param.mean_line_broadening)
        %      t=[0:spec.dw:(spec.np-1)*spec.dw]';
        %      fid1m = fid1m .* exp(-t*pi*param.mean_line_broadening);
        %      fid2m = fid2m .* exp(-t*pi*param.mean_line_broadening);
        %    end
        
        spec1  = fftshift(fft(fid1),1);
        spec2  = fftshift(fft(fid2),1);
        spec1m = fftshift(fft(fid1m));
        spec2m = fftshift(fft(fid2m));
        
        if (param.mega_disp_sum)
            diffspec  = spec2+spec1;
            diffspecm = spec2m+spec1m;
            
        else
            diffspec  = spec2-spec1;
            diffspecm = spec2m-spec1m;
        end
        
        switch param.display
            case 'real'
                spec1  = real(spec1);	spec2  = real(spec2);
                spec1m = real(spec1m);	spec2m = real(spec2m);
                diffspec = real(diffspec);  diffspecm = real(diffspecm);
            case 'imag'
                spec1  = imag(spec1);	spec2  = imag(spec2);
                spec1m = imag(spec1m);	spec2m = imag(spec2m);
                diffspec = imag(diffspec);  diffspecm = imag(diffspecm);
                
            case 'phase'
                spec1  = angle(spec1);	spec2  = angle(spec2);
                spec1m = angle(spec1m);	spec2m = angle(spec2m);
                diffspec = angle(diffspec);  diffspecm = angle(diffspecm);
                
            case 'abs'
                spec1  = abs(spec1);	spec2  = abs(spec2);
                spec1m = abs(spec1m);	spec2m = abs(spec2m);
                diffspec = abs(diffspec);  diffspecm = abs(diffspecm);
            otherwise
                error ('unknown display type for spectrum')
        end
        
        
        titre = [info.sujet_name,' ',info.examnumber,' ',info.SerDescr];
        ind=findstr(titre,'_') ; titre(ind)='';
        %   if ~info.mega_ws, titre = [titre ' mega_ws off '];end
        if ~info.vapor_ws, titre = [titre ' vapor_ws off '];end
        
        curent_color = [0 0 1];
        switch param.same_fig
            case 0
                figure()
            case 1
                if isfield(param,'arg_give_me_a_new_one')
                    figure(param.arg_give_me_a_new_one);
                else
                    param.arg_give_me_a_new_one=figure();
                end
                
                curent_color = all_color(nbser,:);
                legend_str{nbser} = titre;
                hold on
            case 2
                figure(nbser);
        end
        
        set(gcf,'PaperPosition',[1 1 20 28])  ;
        set(gcf,'Position',[120 250 800 880]);
        
        subplot(3,1,1);
        hold on
        if param.display_var
            hold off;
            plot(Fppm,spec1,'g');
            hold on;
        end
        h1(nbser)=plot(Fppm,spec1m);
        set(h1(nbser),'color',curent_color);
        set(gca,'Xdir','reverse');
        if isnumeric(param.xlim),    set(gca,'Xlim',param.xlim);end
        if isnumeric(param.ylim),    set(gca,'Ylim',param.ylim);end
        if (param.same_fig~=1),   title(titre)    ; end
        
        if ~isempty(param.plot_ref_peak)
            [a b c] = get_peak_bound(param.plot_ref_peak);
            ylim = get(gca,'ylim');
            hold on
            plot([c c],ylim,'k');
        end
        
        subplot(3,1,2)
        hold on
        if param.display_var
            hold off
            plot(Fppm,spec2,'g');
            hold on
        end
        h=plot(Fppm,spec2m);
        set(h,'color',curent_color);
        set(gca,'Xdir','reverse');
        if isnumeric(param.xlim),    set(gca,'Xlim',param.xlim);end
        if isnumeric(param.ylim),    set(gca,'Ylim',param.ylim);end
        
        if ~isempty(param.plot_ref_peak)
            [a b c] = get_peak_bound(param.plot_ref_peak);
            ylim = get(gca,'ylim');
            hold on
            plot([c c],ylim,'k');
        end
        
        subplot(3,1,3)
        hold on
        if param.display_var
            hold off
            plot(Fppm,diffspec,'g');
            hold on
        end
        h=plot(Fppm,diffspecm); h1(nbser)=h;
        set(h,'color',curent_color);
        set(gca,'Xdir','reverse');
        if isnumeric(param.xlim),    set(gca,'Xlim',param.xlim);end
        
        if isnumeric(param.diff_y_lim),    set(gca,'Ylim',param.diff_y_lim);end
        
        
        for k=1:3
            subplot(3,1,k)
            xl=get(gca,'xlim');
            plot(xl,[0 0],'k');
        end
        
        
    else  %normal spectra
        
        %    ns = size(fid,2);
        fidm = mean(fid,2);
        %   fidm = mean(fid(:,1:60),2);
        
        switch param.display
            case 'real'
                spec  = real(fftshift(fft(fid),1));
                specm = real(fftshift(fft(fidm)));
            case 'imag'
                spec  = imag(fftshift(fft(fid),1));
                specm = imag(fftshift(fft(fidm)));
            case 'abs'
                spec  = abs(fftshift(fft(fid),1));
                specm = abs(fftshift(fft(fidm)));
            case 'phase'
                spec  = angle(fftshift(fft(fid),1));
                specm = angle(fftshift(fft(fidm)));
                
        end
        %spec = flipdim(spec,1);
        %specm = flipdim(specm,1);
        
        titre = info.Serie_description;
        ind=findstr(titre,'_') ; titre(ind)='';
        
        curent_color = [0 0 1];
        switch param.same_fig
            case 0
                figure();
            case 1
                if isfield(param,'arg_give_me_a_new_one')
                    figure(param.arg_give_me_a_new_one);
                else
                    param.arg_give_me_a_new_one=figure();
                end
                
                curent_color = all_color(nbser,:);
                legend_str{nbser} = titre;
                hold on
            case 2
                figure(nbser);
        end
        
        if isnumeric(param.xlim),subplot(2,1,1);end
        
        hold on
        if param.display_var,            plot(Fppm,spec,'g');        end
        
        h1(nbser) = plot(Fppm,specm);
        set(h1(nbser),'color',curent_color);
        set(gca,'Xdir','reverse');
        title(titre);
        set(gca,'Xlim',[0 9]);
        
        if isnumeric(param.xlim),
            subplot(2,1,2);
            hold on
            if param.display_var,            plot(Fppm,spec,'g');        end
            
            h1(nbser) = plot(Fppm,specm);
            set(h1(nbser),'color',curent_color);
            
            set(gca,'Xlim',param.xlim);
            
            if isnumeric(param.ylim),    set(gca,'Ylim',param.ylim);end
            set(gca,'Xdir','reverse');
            
        end
        
    end
    
    if ~isempty(param.save_file) & param.same_fig~=1
        %print( gcf, '-dpsc2','-r 100','-append',param.save_file)
        print( gcf, '-djpeg100','-r 300',[param.save_file '_Suj_' num2str(nbser)]);
        %print( gcf,'-depsc', '-tiff','-r 100',[param.save_file ])
        
    end
end

if(param.same_fig==1) %& findstr(info.seqname,'mega')
    
    %  figure(param.arg_give_me_a_new_one)
    %subplot(3,1,1)
    %  legend(h1,legend_str,'Location','NorthWest');
    
    aa=get(gca,'Children');
    
    
    legend(h1,legend_str,'Location','NorthWest');
    %  pos = get(h,'position');  pos(2) = pos(2)/1.6;  set(h,'position',pos)
    
    if ~isempty(param.save_file)
        print( gcf, '-djpeg100','-r 300','-append',[param.save_file '_Suj_all']);
       % print( gcf, '-dpsc2','-append',param.save_file)
    end
    
end



if 0%test different TI this is a copy past memo );
    
    for k=1:length(fid_o);fprintf('%s %s %s \t %d \n',info_o(k).sujet_name,info_o(k).examnumber,info_o(k).SerDescr,info_o(k).Number_of_spec);end
    
    for k=1:length(ff);fprintf('%s %s %s \t %d \n',ii(k).sujet_name,ii(k).examnumber,ii(k).SerDescr,ii(k).Number_of_spec);end
    
    TI=892:10:962
    TI = 872:20:952
    TI=892:10:962
    TI = 932:10:1022
    TI=900:5:945
    TI= 906:10:996
    
    TI=932:10:982
    TI=912:10:962
    TI=902:10:952
    TI=892:10:942
    TI=875:10:945
    TI=875:12:935
    TI=892:10:932
    TI=870:15:930
    TI=822:50:1022
    TI=840:27:975
    
    TI=822:50:1172
    TI=870:30:990
    TI=780:20:860
    TI=730:30:850
    
    TI=912:10:952
    TI=800:10:810
    TI=[730:30:790,800,810,820:30:850]
    
    info = spec_info(1);
    
    spec = info.spectrum;
    resolution1 = spec.spectral_widht/(spec.n_data_points-1)/spec.synthesizer_frequency;
    freqat0ppm1 = spec.FreqAt0/spec.synthesizer_frequency+spec.ppm_center;
    %Fppm =  freqat0ppm1:resolution1:freqat0ppm1+(spec.n_data_points-1)*resolution1;
    Fppm =  freqat0ppm1:-resolution1:freqat0ppm1-(spec.n_data_points-1)*resolution1;
    t=[0:spec.dw:(spec.np-1)*spec.dw]';
    
    
    % ff=fid{1}(:,1:2:20);
    % ff=[fid{1}(:,1:3),fid{2},fid{1}(:,4:5)];
    
    ff=fid(1);
    param.mean_line_broadening=6; inc_sh=0; sh=0;
    
    for k=1:size(ff,2);ffl(:,k) = ff(:,k) .* exp(-t*pi*param.mean_line_broadening);end
    
    specl  = real(fftshift(fft(ffl),1));
    
    figure;
    hold on;  sh=0;
    for k=1:size(specl,2);
        plot(Fppm,specl(:,k)+sh);plot([Fppm(1) Fppm(end)],[sh sh],'g');
        text(Fppm(end),sh,['   TI = ',num2str(TI(k))]);
        sh=sh+inc_sh;
    end;
    set(gca,'Xdir','reverse');
    
    
    ff=fid(1);
    
    ind = (1:16);
    for k=1:10
        ffm(:,k) = mean(ff(:,ind),2);
        ind=ind+16;
    end
    
    %or
    ind =1:10:16;
    for k=1:10
        ffm(:,k) = mean(ff(:,ind),2);
        ind=ind+1;
    end
    
    specm  = real(fftshift(fft(ffm)));
    figure;hold on;for k=1:10;sh=sh+3000; plot(Fppm,specm(:,k)+sh);end;set(gca,'Xdir','reverse');
    
    for k=1:10;ffml(:,k) = ffm(:,k) .* exp(-t*pi*param.mean_line_broadening);end
    specml  = real(fftshift(fft(ffml)));
    figure;hold on;for k=1:10;sh=sh+3000; plot(Fppm,specml(:,k)+sh);end;set(gca,'Xdir','reverse');
    
    
    for k=1:10
        aa(:,k) = exp(-t*pi*k);
    end
    specl  = real(fftshift(fft(aa),1));
    
    for k =1:10
        specl2(:,k) = real(fftshift(fft(squeeze(aa(:,k)))));
    end
    sh=0
    figure;hold on;for k=1:10;sh=sh+1000; plot(Fppm,specl(:,k)+sh);end;set(gca,'Xdir','reverse');
    figure;hold on;for k=1:10;sh=sh+1000; plot(Fppm,specl2(:,k)+sh);end;set(gca,'Xdir','reverse');
    
    
end
