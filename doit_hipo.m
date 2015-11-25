%SELECTION des donnes

rootdir = '/nasDicom/dicom_raw/PROTO_SL_BG3T/';

sujet_dir_wc = {'REPRO_H'};

fonc_dir_wc = 'laser_TE64$';
%fonc_dir_wc = 'laser_TE64_TR15_ref$';

s_dir = get_subdir_regex(rootdir,sujet_dir_wc);
s_sub_dir = get_subdir_regex(s_dir,fonc_dir_wc);

P = char(s_sub_dir);

f=explore_spectro_data(P);

fs = sum_fid_local(f,4);

par = processing_spec
par.figure=0;

%par.mean_line_broadening=2;
%fc2 = processing_spec(fs,par);

par.mean_line_broadening=6;
par.ref_metab = 'CRE_SMALL2';
%2013 bizarre ca marche pas avec CRE_SMALL2, je fait avec NAA
par.mean_line_broadening=10;
par.ref_metab = 'NAA'

fc = processing_spec(fs,par);

%par.mean_line_broadening=8;
%fc8 = processing_spec(fs,par);

%que pour la repro
fcc=change_exam_number2(fc);



%puis refaire pour l'eau
fonc_dir_wc = 'laser_TE64_TR15_ref$';

s_dir = get_subdir_regex(rootdir,sujet_dir_wc);
s_sub_dir = get_subdir_regex(s_dir,fonc_dir_wc);

P = char(s_sub_dir);

w=explore_spectro_data(P);
par.mean_line_broadening=2
 par.ref_metab = 'water'   
wc=processing_spec(w,par) 


pp.root_dir='/home/romain/data/spectro/hipo/repro_study/lcmodel/9session_LAST';
pp.root_dir='/home/romain/data/spectro/hipo/repro_study/lcmodel/avril2013/9session128'
 pp.subdir=1;

write_fid_to_lcRAW(fcc,pp,wc);

%128
fcc128=fcc;fcc164=fcc;
for kk=1:length(fcc)
    fcc128(kk).fid = fcc(kk).fid(:,1:128);
    fcc164(kk).fid = fcc(kk).fid(:,1:64);
end
%mean 512
ind=1
for k = 1:30
    fref = fcc(ind);
    fprintf('%s et %s ser %s %s\n',fcc(ind).sujet_name,fcc(ind+1).sujet_name,fcc(ind).ser_dir,fcc(ind+1).ser_dir);
    fcc512(k) = fref;
    fcc512(k).fid = (fcc(ind).fid + fcc(ind+1).fid)./2;
    while(strcmp(fref.suj_dir,fcc(ind).suj_dir))
        ind = ind+1;
        if ind>length(fcc)
            break
        end
    end
    
end

%mean 384
ind=1
for k = 1:30
    fref = fcc(ind);
    fprintf('%s et %s ser %s %s\n',fcc(ind).sujet_name,fcc(ind+1).sujet_name,fcc(ind).ser_dir,fcc(ind+1).ser_dir);
    fcc384(k) = fref;
    fcc384(k).fid = [fcc(ind).fid  fcc(ind+1).fid(:,1:128)];
    while(strcmp(fref.suj_dir,fcc(ind).suj_dir))
        ind = ind+1;
        if ind>length(fcc)
            break
        end
    end
    
end

%cor_all pour le 512
cw512=cw;
cw512(1).cor_all = [mean(cw(1).cor_all(1:2)) mean(cw(1).cor_all(4:5)) mean(cw(1).cor_all(6:7))];
for kk=2:10
    cw512(kk).cor_all = [mean(cw(kk).cor_all(1:2)) mean(cw(kk).cor_all(4:5)) mean(cw(kk).cor_all(7:8))];
end
%sur h2o pour faire le lcmodel
processing_LCmodel('laser','test1_WS')


%to write result in a xls sheet 
d = get_subdir_regex('/home/romain/data/spectro/hipo/repro_study/lcmodel/9session_Naj_last_lb10','HIPO','naa55$');
%last res from removed_PE
d=get_subdir_regex(d,'.*','removed_PE$')
char(d)
c=get_result(d);
%CP effect

cw=get_water_content_hipo1;

cw1 = correct_water_content(cw,1,1); %take into acount T1 and T2 water and compute correction factor
cw2 = correct_water_content(cw,1,111); %take into acount T1 and T2 water and compute correction factor
cw3 = correct_water_content(cw,1,115); %take into acount T1 and T2 water and compute correction factor
cw4 = correct_water_content(cw,1,11); %take into acount T1 and T2 water and compute correction factor

cwmean = cw
for k=1:10, cwmean(k).cor_all = mean(cwmean(k).cor_all);end
%cw = [ cw cw cw cw cwmean]; %si on prend tout

cw(1).fgray=[0.64 0.66 0.6770]; 
cw(1).fwhite=[0.3 0.28 0.2232]; 
cw(1).fcsf=[0.06 0.06 0.0992]; 

cc1 = correct_result(c,cw1);  %apply the correction factor cor_all
cc2 = correct_result(c,cw2);  %apply the correction factor cor_all
cc3 = correct_result(c,cw3);  %apply the correction factor cor_all
cc4 = correct_result(c,cw4);  %apply the correction factor cor_all

cc1 = correct_T2_metab(cc1);
cc2 = correct_T2_metab(cc2);cc3 = correct_T2_metab(cc3);cc4 = correct_T2_metab(cc4);
ccT2 = correct_T2_metab(cc);
ccT2 = remove_big_SD(ccT2,50);

 write_conc_res_to_csv(ccT2,'toto.csv');

write_conc_res_summary_gosia_to_csv(ccT2,'totoS.csv');

%ration CP
fn={'Glu_Gln','NAA_NAAG','PCho_GPC','Cr_PCr','Ins'};

for k=1:length(cc1)
    cration.pool=cc1(k).pool;cration.suj=cc1(k).suj;
 
    for nval=1:length(fn)
        val1 = getfield(cc1(k),fn{nval});
        val2 = getfield(cc3(k),fn{nval});
        cration = setfield(cration,fn{nval},val2./val1) ; 
    end
    cra(k) = cration;
end

met = find_metab_list(ccnew);

for nbmet=1:length(met) 
    rrr=[]
for k=1:50
    v = getfield(cration(k),met{nbmet});
    if k==1
        rrr = v;
    else
        rrr = [rrr v];
    end
end
A(nbmet,:) = rrr;
end

%make suj average
suj='';
nsuj=0;

for k=1:length(wfc)
  
  if isempty(suj)
    suj = wfc(k).sujet_name;
    nsuj = nsuj+1;
    
    wfo(nsuj) = wfc(k);
    
  else
    if strcmp(suj,wfc(k).sujet_name)
      wfo(nsuj).fid = [wfo(nsuj).fid wfc(k).fid];
    else
      suj = wfc(k).sujet_name;
      nsuj = nsuj+1;
      wfo(nsuj) = wfc(k);

    end
  end
end
  
for k=1:30
  fo(k).water_ref = wfo(k);
end


%T2 met

s=get_subdir_regex(rootdir,sujet_dir_wc,{'TE130'});
s=get_subdir_regex(rootdir,sujet_dir_wc,{'TE210'});
s=get_subdir_regex(rootdir,sujet_dir_wc,{'TE300'});
s(4)=''

f=explore_spectro_data(char(s));

fs = sum_fid_local(f,4);

par = processing_spec
par.figure=0;
par.mean_line_broadening=2;
fc = processing_spec(fs,par);


c=get_result();

for k=1:4
%  NA(k,:) = c(k).CrCH3_PCrCH3
  NA(k,:) = c(k).NAA_NAAG;
  naa=log(NA);
end

te=[65 130 210 300];

for nsuj = 1:10
  [a,b,xfit,yfit] = fit_ax_b(te,naa(:,nsuj)')
  t2(nsuj) = -1/a;
  
  figure
  plot(te,naa(:,nsuj),'x')
  hold on
  plot(xfit,yfit,'r')   
end






%order water ref
numscan=zeros(1,10);

for k=1:length(wm)
  numsuj = str2num(wm(k).sujet_name(31:32));
  numscan(numsuj) = numscan(numsuj) + 1; 

  owm(numsuj).pool = ['REPRO_HIPO_' num2str(numsuj)];
  
  owm(numsuj).suj{numscan(numsuj)} = wm(k).Serie_description;
  owm(numsuj).water_width(numscan(numsuj)) = wm(k).water_width;
  owm(numsuj).water_width_lana(numscan(numsuj)) = wm(k).water_width_lana;  
  
  owm(numsuj).integral_real(numscan(numsuj)) = wm(k).integral_real;
  owm(numsuj).integral_real_all(numscan(numsuj)) = wm(k).integral_real_all;  
  owm(numsuj).integral_fid_abs(numscan(numsuj)) = wm(k).integral_fid_abs;  

  
end

%T2 relax
rootdir = '/nasDicom/dicom_raw/PROTO_SL_BG3T/';

sujet_dir_wc = {'REPRO_H.*'};

fonc_dir_wc = '_relax$';
s_dir={};clear suj

for k=1:10
  suj{1} = sprintf('%s%.2d',sujet_dir_wc{1},k);
  s_dir = [s_dir , get_subdir_regex(rootdir,suj)];
end

s_sub_dir = get_subdir_regex(s_dir,fonc_dir_wc);

P = char(s_sub_dir);

f=explore_spectro_data(P);

par.ref_metab = 'water';
par.mean_line_broadening = 1;

fc=processing_spec(f,par);


%recupere le water content pour T2 relax
 l=load('concentration')
wc=l.c

cfgray(1) = wc(1).fgray(3); cfwhite(1) = wc(1).fwhite(3); cfcsf(1) = wc(1).fcsf(3); 
cfgray(2) = wc(1).fgray(8); cfwhite(2) = wc(1).fwhite(8); cfcsf(2) = wc(1).fcsf(8); 


for k=2:10
  cfgray(2*k-1) = wc(k).fgray(6); cfwhite(2*k-1) = wc(k).fwhite(6); cfcsf(2*k-1) = wc(k).fcsf(6); 
  cfgray(2*k)   = wc(k).fgray(9); cfwhite(2*k)   = wc(k).fwhite(9); cfcsf(2*k)   = wc(k).fcsf(9); 
end

fcsf = cfcsf*0.97./(cfgray*0.78 + cfwhite*0.65 + cfcsf*0.97);


[sgray i] = sort(cfgray);
sT2 = T2b(i)
figure
plot(sgray,sT2,'x')

[swhite i] = sort(cfwhite);
sT2 = T2b(i)
figure
plot(swhite,sT2,'x')


%remove EPI correction
cc(1).fgray(2:3) = [cc(1).fgray(1) cc(1).fgray(1)];
cc(1).fgray(5) = cc(1).fgray(4);
cc(1).fgray(7:8) = [cc(1).fgray(6) cc(1).fgray(6)];

cc(1).fwhite(2:3) = [cc(1).fwhite(1) cc(1).fwhite(1)];
cc(1).fwhite(5) = cc(1).fwhite(4);
cc(1).fwhite(7:8) = [cc(1).fwhite(6) cc(1).fwhite(6)];

cc(1).fcsf(2:3) = [cc(1).fcsf(1) cc(1).fcsf(1)];
cc(1).fcsf(5) = cc(1).fcsf(4);
cc(1).fcsf(7:8) = [cc(1).fcsf(6) cc(1).fcsf(6)];


for k=2:10
  cc(k).fgray(2:3) = [cc(k).fgray(1) cc(k).fgray(1)];
  cc(k).fgray(5:6) = [cc(k).fgray(4) cc(k).fgray(4)] ;
  cc(k).fgray(8:9) = [cc(k).fgray(7) cc(k).fgray(7)];

  cc(k).fcsf(2:3) = [cc(k).fcsf(1) cc(k).fcsf(1)];
  cc(k).fcsf(5:6) = [cc(k).fcsf(4) cc(k).fcsf(4)] ;
  cc(k).fcsf(8:9) = [cc(k).fcsf(7) cc(k).fcsf(7)];
  
  cc(k).fwhite(2:3) = [cc(k).fwhite(1) cc(k).fwhite(1)];
  cc(k).fwhite(5:6) = [cc(k).fwhite(4) cc(k).fwhite(4)] ;
  cc(k).fwhite(8:9) = [cc(k).fwhite(7) cc(k).fwhite(7)];

end

%T2 metab short
TE=[130 210 300 64];

for k=1:4
  y(:,k) = c(k).NAA_NAAG;
end
yl=log(y);

for k=1:10
  yy = yl(k,:);
  [a,b] = fit_ax_b(TE,yy);
  T2(k) = -1/a;
end
2009_08_17_SL_BG3T_REPRO_HIPO_02   2009_08_17_SL_BG3T_REPRO_HIPO_03  2009_08_17_SL_BG3T_REPRO_HIPO_04   2009_08_17_SL_BG3T_REPRO_HIPO_06  2009_08_18_SL_BG3T_REPRO_HIPO_01_E2 009_08_18_SL_BG3T_REPRO_HIPO_05_E2 2009_08_20_SL_BG3T_REPRO_HIPO_07   2009_08_20_SL_BG3T_REPRO_HIPO_08   2009_08_20_SL_BG3T_REPRO_HIPO_10   2009_08_20_SL_BG3T_REPRO_Hipo_09   

  392.5930  431.1743  287.6639  364.6688  403.2869  480.2025  364.0311  360.3381  291.7493  309.9594


%T2 metab
TE=[125 155 185 275 400 64 95];

for k=1:6
%y=log(c(k).Cr_CH3_PCrCH3);
%=log(c(k).Glu_Gln);NAA_NAAG Cr_CH2_PCrCH2: Cr_CH3_PCrCH3:
y=log(c(k).PCho_GPC       );

ind=isinf(y);
if any(ind)
  fprintf('removing %d points \n',sum(ind))
  y(ind)='';
  xx=TE;
  xx(ind)='';
else
  xx=TE;
end

[a,b] = fit_ax_b(xx,y);
T2(k) = -1./a;
end

T2NAA_NAAG =
  355.8359  372.7633  349.4059  372.7928  321.1474  303.8994
  326.1999  357.5184  324.1194  360.0622  289.4585  286.1486


T2Glu_Gln =
  136.9316  228.0122  227.5854  189.2207  177.1474  164.5007
  222.6106  362.2362  190.4522  198.3727  166.2400  165.3187
  
T2PCho_GPC

  350.8315  444.7570  387.1311  229.5405  325.8928  320.3183

T2Ins =

  290.7737  243.7183  247.1654  145.9036  319.4613  380.8319

T2 Cr_CH2_PCrCH2=

  132.1697  125.7012  219.9782  118.5732  148.2975  199.4348

T2 Cr_CH3_PCrCH3  =

  198.3415  183.9403  212.9202  158.2330  166.4900  161.9798


    
%Pour faire   
%si c with WS and cnw is whithout
for k=1:length(c)
  cw(k).corWfscale = c(k).NAA./cnw(k).NAA;
  cw(k).cor_all = cw(k).cor_all.*cw(k).corWfscale;
end

[p,suj]=  get_parent_path(d);
dn=r_mkdir('/home/romain/data/spectro/hipo/repro_study/lcmodel/9session_Naj_last_lb10/WScale',suj);
dn=r_mkdir('/home/romain/data/spectro/hipo/repro_study/lcmodel/9session_Naj_last_lb10/WScale_mean',suj);


d=get_subdir_regex('/home/romain/data/spectro/hipo/repro_study/lcmodel/9session_Naj_last_lb10','.*');
fr = get_subdir_regex_files(d,'.*RAW$')

par.gessfile = 0;

for k = 1:length(d)
  r = read_raw(fr{k});
  
  par.root_dir=dn{k};
   
  for ns=1:length(r)
    r(ns).fid = r(ns).fid .* cw(k).cor_all(ns);
  end
  
  if k==1
    r1 = average_series_fid_spec(r(1:3));
    r2 = average_series_fid_spec(r(4:5));
    r3 = average_series_fid_spec(r(6:8));
  else
    r1 = average_series_fid_spec(r(1:3));
    r2 = average_series_fid_spec(r(4:6));
    r3 = average_series_fid_spec(r(7:9));
  end
  
  r4 = average_series_fid_spec(r);
  
  %par.filename = fullfile(par.root_dir, [ r(ns).sujet_name '_WS' ]);
  %write_fid_to_lcRAW(r(ns),par);

  par.filename = fullfile(par.root_dir, [ 'Mean3_Session1_WS' ]);
  write_fid_to_lcRAW(r1,par);
  par.filename = fullfile(par.root_dir, [ 'Mean3_Session2_WS' ]);
  write_fid_to_lcRAW(r2,par);
  par.filename = fullfile(par.root_dir, [ 'Mean3_Session3_WS' ]);
  write_fid_to_lcRAW(r3,par);
  par.filename = fullfile(par.root_dir, [ 'Mean9_All_Session_WS' ]);
  write_fid_to_lcRAW(r4,par);
  
end


%GET the last RESULTSto write result in a xls sheet 

dbrut=get_subdir_regex('/servernas/images2/romain/data/spectro/hipo/repro_study/lcmodel','lb10','.*','naa55$')  
%dWS the water scaling a ete fait directement sur les spectres (csf WS T1 T2 de l'eau)
dWS=get_subdir_regex('/servernas/images2/romain/data/spectro/hipo/repro_study/lcmodel','lb10','WScale','.*','noWS')  


c=get_result(dbrut);
cws=get_result(dWS)


cw=get_water_content_hipo1;
cw = correct_water_content(cw,1,1); %take into acount T1 and T2 water and compute correction factor
cc = correct_result(c,cw);  %apply the correction factor cor_all

%cc donne bien la meme chose que cws 

ccT2 = correct_T2_metab(cws,{'HIPO'}); 
ccSD = remove_big_SD(ccT2,50)          
cccor = remove_big_correlation(ccSD);

write_res_to_csv(ccSD,'toto.csv');
write_res_to_csv(cccor,'toto.csv');

  
%mai 2013
load('allconc.mat')

d64 = get_subdir_regex(pwd,'64bis','H','mai')
d128 = get_subdir_regex(pwd,'768','.*','mai')

c64=get_result(d128)
cc = correct_result(c64,cw512);
cc = correct_T2_metab(cc,{'HIPO'}); 
cc = remove_big_SD(cc,50)  

write_conc_res_to_csv(cc,'c700.csv');





