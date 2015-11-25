
%selection des sujets dans l'ordre
load('/home/romain/data/spectro/hipo/repro_study/anat/hipo_water_content.mat');
suj = get_subdir_regex('/home/romain/data/spectro/hipo/repro_study/lcmodel/avril2013/');

dres=get_subdir_regex_multi(suj,{'Test1DK2','Test1DK02','Test4DK2','Test4DK02'})
c=get_result(dres);

%group
group = get_subdir_regex
for k=1:length(group)
suj = get_subdir_regex(group(k),'H','removed_PE$')
c=get_result(suj);

%attention ne pas faire la corection de l'eau pour les 768 et 2304
c=correct_result(c,cw);

c=correct_T2_metab(c,{'HIPO'});

%Retire les concentrations pour lesquelles le CRLB est supérieur à 50%
c = remove_big_SD(c,50);

%pour obtenir toutes les correlation 
c=get_all_correlation(c);
%pour voir les noms exact des correlation 
%c{1}(1)


write_result_to_csv(c,'conc.csv',{'suj',...
'Gln','SDGln','Glu','SDGlu','Gln_cor_Glu','Glu_Gln','SDGlu_Gln',...
'Asc','SDAsc','GSH','SDGSH','Asc_cor_GSH','GSH_Asc','SDGSH_Asc',...
'GABA','SDGABA',...
'NAA_NAAG','SDNAA_NAAG',...
'PCho_GPC','SDPCho_GPC',...
'Cr_PCr','SDCr_PCr',...
'Ins','SDIns',...
'Lac','SDLac',...
'sIns','SDsIns',...
'Asp','SDAsp',...
'PE','SDPE',...
'Tau','SDTau','Glc','SDGlc','Tau_cor_Glc','Glc_Tau','SDGlc_Tau',...
'MM1','SDMM1','linewidth'});
end

%selection des sujets dans l'ordre 
sujd256 = get_subdir_regex('/home/romain/data/spectro/hipo/repro_study/lcmodel/avril2013/');

d256_Test1DK2  = get_subdir_regex(sujd256,'Test1DK2')
d256_Test1DK02 = get_subdir_regex(sujd256,'Test1DK02')
d256_Test4DK2  = get_subdir_regex(sujd256,'Test4DK2')
d256_Test4DK02 = get_subdir_regex(sujd256,'Test4DK02')


ctest1DK2 =get_result(d256_Test1DK2)
ctest1DK02=get_result(d256_Test1DK02)
ctest4DK2 =get_result(d256_Test4DK2)
ctest4DK02=get_result(d256_Test4DK02)

%write_res_to_csv(c,'toto.csv');


cw=get_water_content_hipo1;
%reduce the water to 3 spectra
cwOK = cw;
cwOK(1).suj = cw(1).suj([1 4 6]);
cwOK(1).fgray = cw(1).fgray([1 4 6]);cwOK(1).fwhite = cw(1).fwhite([1 4 6]);cwOK(1).fcsf = cw(1).fcsf([1 4 6]);
for k=2:10
    cwOK(k).suj = cw(k).suj([1 4 7]);
    cwOK(k).fgray = cw(k).fgray([1 4 7]);cwOK(k).fwhite = cw(k).fwhite([1 4 7]);cwOK(k).fcsf = cw(k).fcsf([1 4 7]);
end
cw=cwOK
clear cwOK

cw = correct_water_content(cw,1,1); %take into acount T1 and T2 water and compute correction factor

%apply the correction factor cor_al
ctest1DK2 = correct_result(ctest1DK2,cw);  
ctest1DK02 = correct_result(ctest1DK02,cw);
ctest4DK2 = correct_result(ctest4DK2,cw);
ctest4DK02 = correct_result(ctest4DK02,cw);

ctest1DK2 = correct_T2_metab(ctest1DK2,{'HIPO'});  
ctest1DK02 = correct_T2_metab(ctest1DK02,{'HIPO'});
ctest4DK2 = correct_T2_metab(ctest4DK2,{'HIPO'});
ctest4DK02 = correct_T2_metab(ctest4DK02,{'HIPO'});

ctest1DK2 = remove_big_SD(ctest1DK2,50);
ctest1DK02 = remove_big_SD(ctest1DK02,50);
ctest4DK2 = remove_big_SD(ctest4DK2,50);
ctest4DK02 = remove_big_SD(ctest4DK02,50);


co = concat_conc(ctest1DK2,ctest1DK02,'_test1_DK02')
co = concat_conc(co,ctest4DK2,'_test4_DK2')
co = concat_conc(co,ctest4DK02,'_test4_DK02')

write_result_to_csv(co,'to.csv',{'suj',...
    'Cr','SDCr','Cr_test1_DK02','SDCr_test1_DK02','Cr_test4_DK2','SDCr_test4_DK2','Cr_test4_DK02','SDCr_test4_DK02',...
    'NAA','SDNAA','NAA_test1_DK02','SDNAA_test1_DK02','NAA_test4_DK2','SDNAA_test4_DK2','NAA_test4_DK02','SDNAA_test4_DK02',...
    'Gln','SDGln','Gln_test1_DK02','SDGln_test1_DK02','Gln_test4_DK2','SDGln_test4_DK2','Gln_test4_DK02','SDGln_test4_DK02',...
    'PCr','SDPCr'});

