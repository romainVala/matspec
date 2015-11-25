function [T2b T2csf Ab Acsf sujet] = find_T2_hipo(fi)

int_field = 'integral_real_fit_all';
int_field = 'integral_fid_abs';
int_field = 'integral_fid_cor_abs';

do_plot=1

for k = 1:(length(fi)/8)

  tk=1;
  for tt = ((k-1)*8+1):k*8
    T2(tk,k) = getfield(fi(tt),int_field);
    TE(tk,k) = fi(tt).TE./1000;
    sujet{k} = fi(tt).sujet_name(31:end);
    tk=tk+1;
  end
  
end

for k=1:size(T2,2)
  tt2 = T2(:,k);
  tte = TE(:,k);
  
  vstart(1) = tt2(1)*1.2;
  vstart(2) = 70;
  vstart(3) = tt2(1) * 0.1 ;
  vstart(4) = 400;
  
  [ vEnd,R,J,COVB,MSE] = nlinfit(tte,tt2,@double_exp,vstart);
  
  if do_plot
    figure
    hold on
    plot(tte,tt2,'xr')
    yy=double_exp(vEnd,tte);
    plot(tte,yy)
    yyb = vEnd(1)*exp(-tte/vEnd(2))
    yycsf = vEnd(3)*exp(-tte/vEnd(4))
    
    plot(tte,yyb,'g')
    plot(tte,yycsf,'r')    
  end
  
  T2b(k)   = vEnd(2); 
  T2csf(k) = vEnd(4);
  Ab(k) = vEnd(1);
  Acsf(k) = vEnd(3);  
end


if do_plot
  figure
  hold on
  plot(T2b,'xr')

  set(gca,'XTick',[1:length(sujet)],'XTickLabel',sujet)

  title('T2 BRAIN')
  
  figure
  hold on
  plot(T2csf,'xr')

  set(gca,'XTick',[1:length(sujet)],'XTickLabel',sujet)

  title('T2 csf')

  figure
  hold on
  plot(Acsf./(Acsf+Ab),'xr')

  set(gca,'XTick',[1:length(sujet)],'XTickLabel',sujet)

  title('csf fraction')

end
keyboard