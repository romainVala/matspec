%compute T2 from c result structure
%select dir where lcmodel result are it assume a separate directory for
%each subject (and each TE acquisition in this dir)
d=get_subdir_regex('/servernas/images5/romain/spectro7T/LCmodel','T2_array','^[BCMO]','.*','no');
c=get_result(d)

SD_thresh = 50;   %parameter to skip te measure where CRLB abose SD_thresh

metab_list = { 'Glu','Ins','sIns','sNAA','mNAA','GSHd','sNAA_NAAG','Glu_Gln','PCho_GPC','CrCH3_PCrCH3','CrCH2_PCrCH2','sNAA_mNAA','Tau'};

%choose output csv file
figdir='/home/range4-raid1/mate/DATA/T2_fig';
resfile = fullfile(figdir,'T2res.csv');

%choose if saving the figure for the exponential fit
save_fig=1;

rf = fopen(resfile,'w+');


for nbsuj = 1:length(c)

  clear allte;
  %get the TE from description
  
  fprintf(rf,'\n%s ',c(nbsuj).suj{1} );
  
  for nte=1:length(c(nbsuj).suj)
    desc = c(nbsuj).suj{nte};

    ind = findstr(desc,'_TE_');
    TEval = desc(ind+4:end);

    allte(nte) = str2num(TEval);
    fprintf(rf,' %d  ',allte(nte));
  end
  
  fprintf(rf,'\n ');
  
  fprintf(rf,'metab,T2 lin, R2 lin,Pval, te of max error, max error , T2 exp, R2 exp, Pval,te of max error, max error,min_T2,max_T2,CI,CI/T2 \n');
  
  [te,ind]=sort(allte);
  allte=allte(ind);
  if max(allte)>500
    error('problem with find the TE')
  end
  
  for nmet = 1:length(metab_list)
    metc = getfield(c(nbsuj),metab_list{nmet});
    metcSD =  getfield(c(nbsuj),['SD' metab_list{nmet}]);
    metc=metc(ind);
    metcSD = metcSD(ind)

    skip_te_ind = find(metcSD>SD_thresh);
    if ~isempty(skip_te_ind)
        fprintf('Warning skiping TE %d for %s',allte(skip_te_ind),metab_list{nmet});
    end
    
    curentte = allte; 
    curentte(skip_te_ind) = [];
    metc(skip_te_ind) = [];
    
    [a,b,aa,bb,fit_error] = fit_ax_b(curentte,log(metc));

    T2_lin = -1/a;
     
    Rlin = log(metc) -  (a*curentte+b) ;
     
    fit_error_lin = sqrt(sum(Rlin.*Rlin));
    
    vstart(1) = exp(b);    vstart(2) = T2_lin;

    try
       [ vEnd,R,J,COVB,MSE] = nlinfit(curentte,metc,@single_exp,vstart);
    catch
       R=1000000;
       vEnd=[1 1];
    end
  
    fit_error_exp = sqrt(sum(R.*R));
  
    rel_err_exp = abs(R)./sum(abs(R));
    rel_err_lin = abs(Rlin)./sum(abs(Rlin));
    [vlin ilin]=max(rel_err_lin);
    [vexp iexp]=max(rel_err_exp);
   
    titre_str = [ c(nbsuj).suj{1} '_' num2str(curentte(end)) ' ' metab_list{nmet}];
    
    [R2_linfit P_linfit] = corrcoef(exp(a*curentte+b),metc);
    [R2_expfit P_expfit] = corrcoef(single_exp(vEnd,curentte),metc);
    
    R2_linfit = (R2_linfit(2)).^2;
    R2_expfit = (R2_expfit(2)).^2;
    P_expfit = P_expfit(1,2);
    P_linfit = P_linfit(1,2);
    
    %CI = nlparci(vEnd,R,'jacobian',J);
    CI = nlparci(vEnd,R,'covar',COVB)
% fprintf(rf,'metab,T2 lin, R2 lin,Pval, te of max error, max error , T2 exp, R2 exp, Pval,te of max error, max error,min_T2,max_T2,CI,CI/T2 \n');


    fprintf(rf,'%s, %0.1f, %f, %d,%0.3f, %0.1f, %0.1f, %f, %d,%0.3f, %0.1f, %0.1f, %0.1f, %0.1f, %f \n',metab_list{nmet},T2_lin,R2_linfit,P_linfit,allte(ilin),vlin*100,vEnd(2),R2_expfit,P_expfit,allte(iexp),vexp*100,CI(2,1),CI(2,2),CI(2,2)-CI(2,1),(CI(2,2)-CI(2,1))/vEnd(2));
    
    if save_fig
%      [allte,ind]=sort(allte);
%      metc=metc(ind);
      
      h=figure;
   
      subplot(3,1,1);hold on
      plot(curentte,a*curentte+b)
      plot(curentte,log(metc),'xr')
      
      legend('linear fit log')
      title(titre_str)
      
      subplot(3,1,2);hold on
      plot(curentte,exp(a*curentte+b))
      plot(curentte,metc,'xr')
      
      legend('linear fit')
    
      
      subplot(3,1,3);hold on
      yy=single_exp(vEnd,curentte);
      plot(curentte,yy)
      plot(curentte,metc,'xr')
      
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
