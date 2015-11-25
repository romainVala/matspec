
d=get_subdir_regex('/servernas/images5/romain/spectro7T/7T_MRS/spectra_dicom_T2','.*TE=...$');

d=get_subdir_regex('/home/romain/images5/spectro7T/dicom_TE35','.*TE=...$');
d=get_subdir_regex('/home/romain/images5/spectro7T/dicom_array_new','.*TE=...$');

f=explore_spectro_data(char(d));

par.mean_line_broadening=8;
par.figure=0;
fc=processing_spec(f,par)

fcut = extract_fid_first_scan(fc,1:64);

pp.root_dir='/home/romain/images5/spectro7T/LCmodel/ALL_aligned_NAA';
pp.root_dir='/home/romain/images5/spectro7T/LCmodel/first64_aligned_NAA';
pp.root_dir='/home/romain/images5/spectro7T/LCmodel/new_array';
pp.subdir=2;



write_fid_to_lcRAW(fcut,pp) 


d=get_subdir_regex('/home/romain/images5/spectro7T/dicom_TE35','.*TE=..._wref$');

fw=explore_spectro_data(char(d));
par.ref_metab='water';
fwc=processing_spec(fw,par)

pp.root_dir='/home/romain/images5/spectro7T/LCmodel/TE35_all';
pp.gessfile=3;
pp.subdir=3;
write_fid_to_lcRAW(fc,pp,fwc) 

pp.root_dir='/home/romain/images5/spectro7T/LCmodel/TE35_first64';
write_fid_to_lcRAW(fcut,pp,fwc) 


%reprocess BG
 d=get_subdir_regex('/home/romain/images5/spectro7T/dicom_TE35','BG.*TE=...$');

 par.ref_metab='CRE_SMALL3'  ;
par.mean_line_broadening=8



%get concentration and correct

d=get_subdir_regex(pwd,'.*','_5');
c=get_result(d);
cw=get_water_content7T(c);

%take mean value for g/w/csf content
 cw(2).fgray = cw(2).fgray*0 + 0.61;
 cw(2).fwhite = cw(2).fwhite*0 + 0.35;
 cw(2).fcsf = cw(2).fcsf*0 + 0.04;
 
cw = correct_water_content(cw,1,2);

cc=correct_result(c,cw);
call=concat_conc(cc,cw);
write_conc_res_to_csv(call,'toto.csv')
write_conc_res_summary_gosia_to_csv(call,'totoS.csv')

d=get_subdir_regex(pwd,'.*','_sep_last');




%for finding the patient age and sex
f=fopen('toto.csv','w+')
fprintf(f,'Name,Serie,age,sex\n')
for k=1:length(ff)
  fprintf(f,'Sujet %s,%s,%s,%s\n',ff(k).SubjectID,ff(k).ser_dir,ff(k).patient_age,ff(k).patient_sex);
end
fclose(f)

for k=1:length(ff)
  P{k}  = fullfile(ff(k).suj_dir,ff(k).ser_dir);
end
P = ...
{
'/servernas/images5/romain/spectro7T/spectra_dicom_T2/100302_OC_slaser_TE=035_wref/'
'/servernas/images5/romain/spectro7T/dicom_array_new/100629_OC_slaser_TE=035_wref/' 
'/servernas/images5/romain/spectro7T/dicom_array_new/100706_OC_slaser_TE=035_wref/' 
'/servernas/images5/romain/spectro7T/spectra_dicom_T2/090528_MC_slaser_TE=035_wref/'
'/servernas/images5/romain/spectro7T/spectra_dicom_T2/100316_MC_slaser_TE=035_wref/'
'/servernas/images5/romain/spectro7T/spectra_dicom_T2/100420_MC_slaser_TE=035_wref/'
'/servernas/images5/romain/spectro7T/spectra_dicom_T2/090526_BG_slaser_TE=035_wref/'
'/servernas/images5/romain/spectro7T/spectra_dicom_T2/090602_BG_slaser_TE=035_wref/'
'/servernas/images5/romain/spectro7T/spectra_dicom_T2/100413_BG_slaser_TE=035_wref/'
'/servernas/images5/romain/spectro7T/spectra_dicom_T2/090526_CR_slaser_TE=035_wref/'
'/servernas/images5/romain/spectro7T/spectra_dicom_T2/100323_CR_slaser_TE=035_wref/'
'/servernas/images5/romain/spectro7T/dicom_array_new/100706_CR_slaser_TE=035'
}



 d=get_subdir_regex(pwd,'[BCMO].*','.*','WS')
 c=get_result(d)