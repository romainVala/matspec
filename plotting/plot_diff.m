function plot_diff(f1,f2,tit)

param.mean_line_broadening = 1;
param.xlim=[0 4.5];param.ylim=[-2000 14000];
param.diff_y_lim=[-2000 3500];
param.save_file = '/home/romain/Doc/spectro_doc/Dysto/aaa';

param.xlim=[2.5 4.3];
param.xlim=[0 4.5];
%param.diff_y_lim=[-300 1500];
param.display_var = 0;
param.same_fig=1;
param.plot_single = 0;

info = f1(1);
  
  spec = info.spectrum;
  resolution1 = spec.spectral_widht/(spec.n_data_points-1)/spec.synthesizer_frequency;
  freqat0ppm1 = spec.FreqAt0/spec.synthesizer_frequency+4.7;
  %Fppm =  freqat0ppm1:resolution1:freqat0ppm1+(spec.n_data_points-1)*resolution1;
  Fppm1 =  freqat0ppm1:-resolution1:freqat0ppm1-(spec.n_data_points-1)*resolution1;

  info = f2(1);
  
  spec = info.spectrum;
  resolution1 = spec.spectral_widht/(spec.n_data_points-1)/spec.synthesizer_frequency;
  freqat0ppm1 = spec.FreqAt0/spec.synthesizer_frequency+4.7;
  %Fppm =  freqat0ppm1:resolution1:freqat0ppm1+(spec.n_data_points-1)*resolution1;
  Fppm2 =  freqat0ppm1:-resolution1:freqat0ppm1-(spec.n_data_points-1)*resolution1;

for k=1:length(f1)

  fid = f1(k).fid;

  ns = size(fid,2)/2;
  
  fid1 = fid(:,1:ns);
  fid2 = fid(:,(ns+1):end);


  fid1m = mean(fid1,2);
  fid2m = mean(fid2,2);
  if (param.mean_line_broadening)
    t=[0:spec.dw:(spec.np-1)*spec.dw]';
    fid1m = fid1m .* exp(-t*pi*param.mean_line_broadening);
    fid2m = fid2m .* exp(-t*pi*param.mean_line_broadening);
  end

  difffids1m(:,k) = fid2m - fid1m;
    
  legend_str1{k} =  [f1(k).sujet_name,' ',f1(k).examnumber,' ',f1(k).SerDescr];
end


for k=1:length(f2)

  fid = f2(k).fid;

  ns = size(fid,2)/2;
  
  fid1 = fid(:,1:ns);
  fid2 = fid(:,(ns+1):end);
  
  fid1m = mean(fid1,2);
  fid2m = mean(fid2,2);
  if (param.mean_line_broadening)
    t=[0:spec.dw:(spec.np-1)*spec.dw]';
    fid1m = fid1m .* exp(-t*pi*param.mean_line_broadening);
    fid2m = fid2m .* exp(-t*pi*param.mean_line_broadening);
  end

  difffids2m(:,k) = fid2m - fid1m;
  
  legend_str2{k} =  [f2(k).sujet_name,' ',f2(k).examnumber,' ',f2(k).SerDescr];
end
legend_str1{end+1} = 'mean';legend_str2{end+1} = 'mean';

specdiff1  = fftshift(fft(difffids1m),1);
specdiff2  = fftshift(fft(difffids2m),1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
set(gcf,'PaperPosition',[1 1 20 28])  ;
set(gcf,'Position',[10 900 800 880])
title('Difference Spectrum')
subplot(3,1,1)
hold on
plot(Fppm1, real(specdiff1),'b')
plot(Fppm1, real(mean(specdiff1,2)),'r')

set(gca,'Xdir','reverse');
if isfield(param,'xlim'),    set(gca,'Xlim',param.xlim);end
if isfield(param,'diff_y_lim'),  set(gca,'Ylim',param.diff_y_lim); end    

if exist('tit')
  title(tit{1})
else
  h=legend(legend_str1,'Location','NorthWest');
end

subplot(3,1,2)
hold on
plot(Fppm2, real(specdiff2),'b')
plot(Fppm2, real(mean(specdiff2,2)),'r')

set(gca,'Xdir','reverse');
if isfield(param,'xlim'),    set(gca,'Xlim',param.xlim);end
if isfield(param,'diff_y_lim'),  set(gca,'Ylim',param.diff_y_lim); end    

if exist('tit')
  title(tit{2})
else
h=legend(legend_str2,'Location','NorthWest');
end

subplot(3,1,3)
hold on

plot(Fppm1, real(mean(specdiff1,2)),'b')
plot(Fppm2, real(mean(specdiff2,2)),'r')

set(gca,'Xdir','reverse');
if isfield(param,'xlim'),    set(gca,'Xlim',param.xlim);end
if isfield(param,'diff_y_lim'),  set(gca,'Ylim',param.diff_y_lim); end    

h=legend({'mean of subplot 1','mean of subplot 2'},'Location','NorthWest');

if isfield(param,'save_file') 
  print( gcf, '-dpsc2','-append',param.save_file)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%test interp Fppm



if param.plot_single
  plot_spectrum(f1,param)
  plot_spectrum(f2,param)
  
  for k=1:length(f2)
    
    fidss = [f1(k) ,f2(k)];

    plot_spectrum(fidss,param)
    
  end

end

for k=1:3
  subplot(3,1,k)
  xl=get(gca,'xlim');
  plot(xl,[0 0],'k')
end


for k=1:0%size(specdiff1,2)

  
  if(0)
    
  figure()
  hold on
  plot(Fppm,real(specdiff1(:,k)),'b')
  plot(Fppm,real(specdiff2(:,k)),'r')
  
  info=f1(k);
  titre{1} = [info.sujet_name,' ',info.examnumber,' ',info.SerDescr];
  
  info=f2(k);
  titre{2} = [info.sujet_name,' ',info.examnumber,' ',info.SerDescr];
  
  
  set(gca,'Xdir','reverse');
  if isfield(param,'xlim'),    set(gca,'Xlim',param.xlim);end
  if isfield(param,'diff_y_lim'),  set(gca,'Ylim',param.diff_y_lim); end    

    h=legend(titre,'Location','North');

    if isfield(param,'save_file') 
      print( gcf, '-dpsc2','-append',param.save_file)
   end
  end

end
