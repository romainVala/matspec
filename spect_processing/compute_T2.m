%compute T2 from c result structure

metab_list = { 'Glu','Ins','sIns','sNAA','mNAA','GSHd','sNAA_NAAG','Glu_Gln','PCho_GPC','CrCH3_PCrCH3','CrCH2_PCrCH2','sNAA_mNAA'};

figdir='/home/romain/images5/spectro7T/7T_MRS/T2_fit_figure';
figdir='/home/romain/images5/spectro7T/7T_MRS/LCmodel/BG_spw2000/T2';
figdir='/home/romain/images5/spectro7T/results/T2_new_array';
figdir='/home/romain/images5/spectro7T/results/T2_all_fig2';

resfile = fullfile(figdir,'T2res.csv');
rf = fopen(resfile,'w+');

save_fig=0;

for nmet = 1:length(metab_list)

  fprintf(rf,'\n\nMETAB %s \n', metab_list{nmet} );
  %  fprintf(rf,'\n%s ',c(nbsuj).suj{1} );
  fprintf(rf,'Subject,T2 lin, R2lin,te of max error, max error , T2 exp , R2exp,te of max error, max error\n');

  for nbsuj = 1:length(c)
  
    clear allte;
    %get the TE from description
    
    allte_descr='';
    
    for nte=1:length(c(nbsuj).suj)
      desc = c(nbsuj).suj{nte};
      
      ind = findstr(desc,'TE_');
      TEval = desc(ind+3:ind+5);
      if TEval(end)=='_'
	TEval(end)='';
      end
      
      allte(nte) = str2num(TEval);
      allte_descr =[allte_descr sprintf(' %d  ',allte(nte))];
    end
  
    if mod(nbsuj,3)==1
      fprintf(rf,'\n ');
    end
    
    
    [te,ind]=sort(allte);
    allte=allte(ind);

    metc = getfield(c(nbsuj),metab_list{nmet});
    metc=metc(ind);

    
    [a,b,aa,bb,fit_error] = fit_ax_b(allte,log(metc));

    T2_lin = -1/a;
     
    Rlin = log(metc) -  (a*allte+b) ;
     
    fit_error_lin = sqrt(sum(Rlin.*Rlin));
    
    vstart(1) = exp(b);    vstart(2) = T2_lin;
   
    try
       [ vEnd,R,J,COVB,MSE] = nlinfit(allte,metc,@single_exp,vstart);
    catch
       R=1000000;
       vEnd=[1 1];
    end
  
    fit_error_exp = sqrt(sum(R.*R));
  
    rel_err_exp = abs(R)./sum(abs(R));
    rel_err_lin = abs(Rlin)./sum(abs(Rlin));
    [vlin ilin]=max(rel_err_lin);
    [vexp iexp]=max(rel_err_exp);
   
    titre_str = [ c(nbsuj).suj{1} '_' num2str(allte(end)) ' ' metab_list{nmet}];
    
    R2_linfit_log = corrcoef((a*allte+b)',(log(metc))');
    R2_linfit = corrcoef(exp(a*allte+b),metc);
    R2_expfit = corrcoef(single_exp(vEnd,allte),metc);
    
    R2_linfit = (R2_linfit(2)).^2;
    R2_expfit = (R2_expfit(2)).^2;
    
%    fprintf(rf,'%s, %0.1f, %0.1f, %d, %0.1f, %0.1f, %0.1f, %d, %0.1f \n',metab_list{nmet},T2_lin,fit_error_lin,allte(ilin),vlin*100,vEnd(2),fit_error_exp,allte(iexp),vexp*100);
    fprintf(rf,'%s %s, %0.1f, %0.3f, %d, %0.1f, %0.1f, %0.3f, %d, %0.1f \n',c(nbsuj).suj{1},allte_descr,T2_lin,R2_linfit,allte(ilin),vlin*100,vEnd(2),R2_expfit,allte(iexp),vexp*100);

    if nbsuj==2
%      keyboard
    end
    
    
    if save_fig
%      [allte,ind]=sort(allte);
%      metc=metc(ind);
      
      h=figure;
   
      subplot(3,1,1);hold on
      plot(allte,a*allte+b)
      plot(allte,log(metc),'xr')
      
      legend('linear fit log')
      title(titre_str)
      
      subplot(3,1,2);hold on
      plot(allte,exp(a*allte+b))
      plot(allte,metc,'xr')
      
      legend(sprintf('linear fit R²=%f',R2_linfit))
    
      
      subplot(3,1,3);hold on
      yy=single_exp(vEnd,allte);
      plot(allte,yy)
      plot(allte,metc,'xr')
      
      legend('exponential fit')
      legend(sprintf('exponential fit R²=%f',R2_linfit))
      
      set(h,'PaperPosition',[ 0.25  2.5 8 6])  ;
      set(h,'Position',[431    94   777   854 ])
      
      titre_str=nettoie_dir(titre_str);
      
      saveas(h,fullfile(figdir,titre_str),'jpeg')
      
      close(h)
    end
    
  end
end

fclose(rf)
