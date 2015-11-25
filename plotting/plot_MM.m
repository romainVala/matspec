function plot_MM(f)

mean_line_broadening = 8;

for k=1:length(f)
  
  
  fid = f(k).fid;
  
  spec = f(k).spectrum;
  resolution1 = spec.spectral_widht/(spec.n_data_points-1)/spec.synthesizer_frequency;
  freqat0ppm1 = spec.FreqAt0/spec.synthesizer_frequency+4.7;
  %Fppm =  freqat0ppm1:resolution1:freqat0ppm1+(spec.n_data_points-1)*resolution1;
  Fppm =  freqat0ppm1:-resolution1:freqat0ppm1-(spec.n_data_points-1)*resolution1;

  if (mean_line_broadening)
    t=[0:spec.dw:(spec.np-1)*spec.dw]';
    for k=1:size(fid,2)
      fid(:,k) = fid(:,k) .* exp(-t*pi*mean_line_broadening);
    end
  end

  figure

  hold on
  set(gca,'Xdir','reverse');

  for kk=1:size(fid,2)
    spec1  = fftshift(fft(fid(:,kk)),1) + kk*2000;
    
    plot(Fppm,real(spec1))
  end
  grid on
end


if 0
%  31 05 2010
 mmc=mc(2);                                                                   
 mmc.fid(:,4) = ( mc(2).fid(:,4)  +  mc(1).fid(:,1) + mc(3).fid(:,1) ) / 3;   
 mmc.fid(:,5) = ( mc(2).fid(:,5)  +  mc(1).fid(:,2) + mc(3).fid(:,3) ) / 3;   
 mmc.fid(:,6) = ( mc(2).fid(:,6)  +  mc(1).fid(:,3) ) / 2;                    
 mmc.fid = [ mmc.fid(:,1:4) mc(3).fid(:,2) mmc.fid(:,[5:6]) mc(1).fid(:,4:6) ]; 
end
