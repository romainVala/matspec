function plot_compare_spectrum(fids,fids2,spec_info,param)

if ~exist('param'), param='';end

if ~isfield(param,'display')
  param.display = 'real';
end

if ~isfield(param,'mean_line_broadening')
  param.mean_line_broadening = 0;
end

%  param.xlim = [0 6];
%  param.x_freq = any;
%  param.plot_ref_peak  ='CRE' plot the bound used for CRE

if ~isfield(param,'display_var')
  param.display_var = 1;
end

if ~isfield(param,'same_fig')
  param.same_fig = 0;
end

all_color=jet(length(fids));

for nbser = 1:length(fids)
  fid= fids{nbser};
  ffid= fids2{nbser};
  
  info = spec_info{nbser};
  
  spec = info.spectrum;
  resolution1 = spec.spectral_widht/(spec.n_data_points-1)/spec.synthesizer_frequency;
  freqat0ppm1 = spec.FreqAt0/spec.synthesizer_frequency+4.7;
  %Fppm =  freqat0ppm1:resolution1:freqat0ppm1+(spec.n_data_points-1)*resolution1;
  Fppm =  freqat0ppm1:-resolution1:freqat0ppm1-(spec.n_data_points-1)*resolution1;

  if isfield(param,'x_freq')
    resolution1 = spec.spectral_widht/(spec.n_data_points-1);
    Fppm = spec.FreqAt0:-resolution1: (spec.FreqAt0 - (spec.n_data_points-1)*resolution1);
  end   
   
  if findstr(info.seqname,'mega')
    %fid1 = transpose(fid(:,1:(info.Number_of_spec)/2));
    %fid2 = transpose(fid(:,(info.Number_of_spec/2+1):end));

    ns = size(fid,2)/2;
    fid1 = fid(:,1:ns);
    fid2 = fid(:,(ns+1):end);
    fid1m = mean(fid1,2);
    fid2m = mean(fid2,2);
 
    ns = size(ffid,2)/2;
    ffid1 = ffid(:,1:ns);
    ffid2 = ffid(:,(ns+1):end);
    ffid1m = mean(ffid1,2);
    ffid2m = mean(ffid2,2);

    if (param.mean_line_broadening)
      t=[0:spec.dw:(spec.np-1)*spec.dw]';
      fid1m = fid1m .* exp(-t*pi*param.mean_line_broadening);
      fid2m = fid2m .* exp(-t*pi*param.mean_line_broadening);
      ffid1m = ffid1m .* exp(-t*pi*param.mean_line_broadening);
      ffid2m = ffid2m .* exp(-t*pi*param.mean_line_broadening);
    end

    spec1  = fftshift(fft(fid1),1);
    spec2  = fftshift(fft(fid2),1);
    spec1m = fftshift(fft(fid1m));
    spec2m = fftshift(fft(fid2m));

    sspec1  = fftshift(fft(ffid1),1);
    sspec2  = fftshift(fft(ffid2),1);
    sspec1m = fftshift(fft(ffid1m));
    sspec2m = fftshift(fft(ffid2m));

    switch param.display
      case 'real'
	spec1  = real(spec1);	spec2  = real(spec2);
	spec1m = real(spec1m);	spec2m = real(spec2m);
	sspec1  = real(sspec1);	sspec2  = real(sspec2);
	sspec1m = real(sspec1m);sspec2m = real(sspec2m);
      case 'imag'
 	spec1  = imag(spec1);	spec2  = imag(spec2);
	spec1m = imag(spec1m);	spec2m = imag(spec2m);
 	sspec1  = imag(sspec1);	sspec2  = imag(sspec2);
	sspec1m = imag(sspec1m);	sspec2m = imag(sspec2m);
      case 'phase'
 	spec1  = angle(spec1);	spec2  = angle(spec2);
	spec1m = angle(spec1m);	spec2m = angle(spec2m);
 	sspec1  = angle(sspec1);	sspec2  = angle(sspec2);
	sspec1m = angle(sspec1m);	sspec2m = angle(sspec2m);
      case 'abs'
	spec1  = abs(spec1);	spec2  = abs(spec2);
	spec1m = abs(spec1m);	spec2m = abs(spec2m);
	sspec1  = abs(sspec1);	sspec2  = abs(sspec2);
	sspec1m = abs(sspec1m);	sspec2m = abs(sspec2m);
      otherwise 
	error ('unknown display type for spectrum')
    end

    
    titre = [info.sujet_name,' ',info.examnumber,' ',info.SerDescr];
 %   if ~info.mega_ws, titre = [titre ' mega_ws off '];end
    if ~info.vapor_ws, titre = [titre ' vapor_ws off '];end

    curent_color = [0 0 1];
    switch param.same_fig
      case 0
	figure()
      case 1
	figure(1)
	curent_color = all_color(nbser,:);
	legend_str{nbser} = titre;
	hold on
      case 2
	figure(nbser)
    end

    set(gcf,'PaperPosition',[1 1 20 28])  ;
    set(gcf,'Position',[10 900 800 880])
    
    subplot(4,1,1)
    hold on
    if param.display_var
      hold off
      plot(Fppm,spec1,'g');
      hold on
    end
    h=plot(Fppm,spec1m);
    set(h,'color',curent_color);
    set(gca,'Xdir','reverse');
    if isfield(param,'xlim'),    set(gca,'Xlim',param.xlim);end
    title(titre)    

    if isfield(param,'plot_ref_peak')
      [a b c] = get_peak_bound(param.plot_ref_peak);
      ylim = get(gca,'ylim');
      hold on
      plot([c c],ylim,'k')
    end
    
    
    subplot(4,1,2)
    hold on
    if param.display_var
      hold off
      plot(Fppm,sspec1,'g');
      hold on
    end
    h=plot(Fppm,sspec1m);
    set(h,'color',curent_color);
    set(gca,'Xdir','reverse');
    if isfield(param,'xlim'),    set(gca,'Xlim',param.xlim);end
    title(titre)    

    if isfield(param,'plot_ref_peak')
      [a b c] = get_peak_bound(param.plot_ref_peak);
      ylim = get(gca,'ylim');
      hold on
      plot([c c],ylim,'k')
    end
    
    subplot(4,1,3)
    hold on
    if param.display_var
      hold off
      plot(Fppm,spec2,'g');
      hold on
    end
    h=plot(Fppm,spec2m);
    set(h,'color',curent_color);
    set(gca,'Xdir','reverse');
    if isfield(param,'xlim'),    set(gca,'Xlim',param.xlim);end

    if isfield(param,'plot_ref_peak')
      [a b c] = get_peak_bound(param.plot_ref_peak);
      ylim = get(gca,'ylim');
      hold on
      plot([c c],ylim,'k')
    end
    
    subplot(4,1,4)

    hold on
    if param.display_var
      hold off
      plot(Fppm,sspec2,'g');
      hold on
    end
    h=plot(Fppm,sspec2m);
    set(h,'color',curent_color);
    set(gca,'Xdir','reverse');
    if isfield(param,'xlim'),    set(gca,'Xlim',param.xlim);end

    if isfield(param,'plot_ref_peak')
      [a b c] = get_peak_bound(param.plot_ref_peak);
      ylim = get(gca,'ylim');
      hold on
      plot([c c],ylim,'k')
    end
     
    if isfield(param,'diff_y_lim')
     set(gca,'Ylim',param.diff_y_lim);
   end    
   
  else
%    ns = size(fid,2);
    fidm = mean(fid,2);

    switch param.display
      case 'real'
	spec  = real(fftshift(fft(fid)));
	specm = real(fftshift(fft(fidm)));
      case 'imag'
	spec  = imag(fftshift(fft(fid)));
	specm = imag(fftshift(fft(fidm)));
      case 'abs'
	spec  = abs(fftshift(fft(fid)));
	specm = abs(fftshift(fft(fidm)));
    end	
    
    titre = info.Serie_description;
    figure();
    hold on 
    
    plot(Fppm,spec,'g')
    plot(Fppm,specm,'b')

    title(titre)    
    set(gca,'Xdir','reverse');

  end

  if isfield(param,'save_file') & param.same_fig~=1
    print( gcf, '-dpsc2','-append',param.save_file)
  end
end

if(param.same_fig==1)
  figure(1)
  subplot(3,1,2)

  h=legend(legend_str,'Location','South');
  pos = get(h,'position');
  pos(2) = pos(2)/1.6;
  set(h,'position',pos)
  
  if isfield(param,'save_file') 
    print( gcf, '-dpsc2','-append',param.save_file)
  end

end


if 0%test different ti

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

  info = spec_info{1};
  
  spec = info.spectrum;
  resolution1 = spec.spectral_widht/(spec.n_data_points-1)/spec.synthesizer_frequency;
  freqat0ppm1 = spec.FreqAt0/spec.synthesizer_frequency+4.7;
  %Fppm =  freqat0ppm1:resolution1:freqat0ppm1+(spec.n_data_points-1)*resolution1;
  Fppm =  freqat0ppm1:-resolution1:freqat0ppm1-(spec.n_data_points-1)*resolution1;
  t=[0:spec.dw:(spec.np-1)*spec.dw]';

  
 % ff=fid{1}(:,1:2:20);            
 % ff=[fid{1}(:,1:3),fid{2},fid{1}(:,4:5)];
  
  ff=fid{1};
  param.mean_line_broadening=6; inc_sh=500; sh=0;
  
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
   
  
  ff=fid{1};
  
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
