%compute T2 from c result structure
% d=get_subdir_regex('/servernas/images5/romain/spectro7T/LCmodel','T2_array','^[BCMO]','.*','no');
%c=get_result(d)

metab_list = { 'Glu','Ins','sIns','sNAA','mNAA','GSHd','sNAA_NAAG','Glu_Gln','PCho_GPC','CrCH3_PCrCH3','CrCH2_PCrCH2','sNAA_mNAA','Tau'};

figdir='/home/romain/images5/spectro7T/7T_MRS/T2_fit_figure';
figdir='/home/romain/images5/spectro7T/7T_MRS/LCmodel/BG_spw2000/T2';
figdir='/home/romain/images5/spectro7T/results/T2_new_array';
figdir='/home/romain/images5/spectro7T/results/T2_all_fig2';
figdir='/home/romain/images5/spectro7T/results/test';

resfile = fullfile(figdir,'T2res.csv');
rf = fopen(resfile,'w+');

save_fig=0;

for nbsuj = 1:length(c)

  clear allte;
  %get the TE from description
  
  fprintf(rf,'\n%s ',c(nbsuj).suj{1} );
  
  for nte=1:length(c(nbsuj).suj)
    desc = c(nbsuj).suj{nte};

    ind = findstr(desc,'TE_');
    TEval = desc(ind+3:ind+5);
    if TEval(end)=='_'
      TEval(end)='';
    end

    allte(nte) = str2num(TEval);
    fprintf(rf,' %d  ',allte(nte));
  end
  
  fprintf(rf,'\n ');
  
  fprintf(rf,'metab,T2 lin, R2 lin,Pval, te of max error, max error , T2 exp, R2 exp, Pval,te of max error, max error,min_T2,max_T2,CI,CI/T2 \n');
  
  [te,ind]=sort(allte);
  allte=allte(ind);
  if max(allte)>230
    error('AZERAZERAZ')
  end
  
  for nmet = 1:length(metab_list)
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
    
    [R2_linfit P_linfit] = corrcoef(exp(a*allte+b),metc);
    [R2_expfit P_expfit] = corrcoef(single_exp(vEnd,allte),metc);
    
    R2_linfit = (R2_linfit(2)).^2;
    R2_expfit = (R2_expfit(2)).^2;
    P_expfit = P_expfit(1,2);
    P_linfit = P_linfit(1,2);
    
    %CI = nlparci(vEnd,R,'jacobian',J);
    CI = nlparci(vEnd,R,'covar',COVB)


    fprintf(rf,'%s, %0.1f, %f, %d,%0.3f, %0.1f, %0.1f, %f, %d,%0.3f, %0.1f, %0.1f, %0.1f, %0.1f, %f \n',metab_list{nmet},T2_lin,R2_linfit,P_linfit,allte(ilin),vlin*100,vEnd(2),R2_expfit,P_expfit,allte(iexp),vexp*100,CI(2,1),CI(2,2),CI(2,2)-CI(2,1),(CI(2,2)-CI(2,1))/vEnd(2));
    
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
      
      legend('linear fit')
    
      
      subplot(3,1,3);hold on
      yy=single_exp(vEnd,allte);
      plot(allte,yy)
      plot(allte,metc,'xr')
      
      legend('exponential fit')
      
      set(h,'PaperPosition',[ 0.25  2.5 8 6])  ;
      set(h,'Position',[431    94   777   854 ])
      
      titre_str=nettoie_dir(titre_str);
      
      saveas(h,fullfile(figdir,titre_str),'jpeg')
      
      close(h)
    end
    
  end
end

fclose(rf)
