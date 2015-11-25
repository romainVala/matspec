function plot_adjust_phase(action)

persistent diffid fid1m fid2m info hdl

mean_line_broadening=0;

if isstruct(action)
  
  hdl = [];
  
  fid=action.fid;
  
  info = action(1);
  
  ns = size(fid,2)/2;
  fid1 = fid(:,1:ns);
  fid2 = fid(:,(ns+1):end);
  fid1m = mean(fid1,2);
  fid2m = mean(fid2,2);

  if (mean_line_broadening)
    spec = info.spectrum;
    t=[0:spec.dw:(spec.np-1)*spec.dw]';
    fid1m = fid1m .* exp(-t*pi*mean_line_broadening);
    fid2m = fid2m .* exp(-t*pi*mean_line_broadening);
  end

  
  diffid = fid2m-fid1m;
  
  hdl.fig = figure();

  set(hdl.fig,'ToolBar','figure')
  
  hdl.text = uicontrol('String','1','Style','edit');
  
  hdl.change = uicontrol('String','change','Callback','plot_adjust_phase(''change_phase'')','Position',[90 20 50 20]);

  hdl.curent_phase =  uicontrol('String','0','Position',[150 20 40 20]);
  
  hdl.holdstate =  uicontrol('Style','check','Value',0,'Position',[200 20 20 20]);
  
  hdl.display = uicontrol('Style','popupmenu','String',{'noedit','edit','diff'},'Value',3,'Position',[230 20 50 20],'Callback','plot_adjust_phase(''draw'')');

  hdl.display_type = uicontrol('Style','popupmenu','String',{'real','imag','abs','phase'},'Value',1,'Position',[290 20 50 20],'Callback','plot_adjust_phase(''draw'')');
  
  plot_adjust_phase('draw')

else
  switch action
    case 'draw'
      spec = info.spectrum;
      resolution1 = spec.spectral_widht/(spec.n_data_points-1)/spec.synthesizer_frequency;
      freqat0ppm1 = spec.FreqAt0/spec.synthesizer_frequency+4.7;
      Fppm =  freqat0ppm1:-resolution1:freqat0ppm1-(spec.n_data_points-1)*resolution1;

      dispval = get(hdl.display,'Value');
      switch dispval
	case 1
	  spec =fftshift(fft(fid1m),1);
	case 2
	  spec =fftshift(fft(fid2m),1);
	case 3
	  spec =fftshift(fft(diffid),1);
      end
      disptype = get(hdl.display_type,'Value');
      switch disptype
	case 1
	  spec = real(spec);
	case 2
	  spec = imag(spec);
	case 3
	  spec = abs(spec);
	case 4
	  spec = angle(spec);
      end
      


      hval = get(hdl.holdstate,'Value');
      if ~hval
	ha = get(hdl.fig,'CurrentAxes');
	if ~ isempty(ha);
	  limx = get(ha,'xlim');
	  limy = get(ha,'ylim');
	  hdl = rmfield(hdl,'curent_plot');
	end
      end
      
      if ~isfield(hdl,'curent_plot')
	hold off
	hdl.curent_plot = plot(Fppm,spec,'r');
	hold on
	xl=get(gca,'xlim');
	plot(xl,[0 0],'k')
	
	if exist('limx')
	  set(ha,'xlim',limx);
	  set(ha,'ylim',limy);
	end
      else
	set(hdl.curent_plot,'Color',[0 0 1])
	hdl.curent_plot = plot(Fppm,spec,'r');
      end
      
      
      set(gca,'Xdir','reverse');

      cur_phase = get(hdl.curent_phase,'string');
      
      dispval = get(hdl.display,'Value');
      stt=get(hdl.display,'String');
      
      titre = [ info.Serie_description ' spec ' stt{dispval} ' phase ' cur_phase ' '  ];
      title(titre)
      
    case 'change_phase'
      phi = str2num(get(hdl.text,'string')) ;
      
      cur_phase = str2num(get(hdl.curent_phase,'string'));
      
      cur_phase = cur_phase + phi;
      
      set(hdl.curent_phase,'string',num2str(cur_phase));
      
      diffid=exp(-1i*pi*phi/180)*diffid;
      fid1m =exp(-1i*pi*phi/180)*fid1m;
      fid2m =exp(-1i*pi*phi/180)*fid2m;
      
      hold on
      plot_adjust_phase('draw')
      
  end
  
    
end



