%SELECTION des donnes
rootdir = '/nasDicom/dicom_raw/VERIO_IDH1';
sujet_dir_wc = {'IDH1'};

fonc_dir_wct = 'LASER_128_tumor$';
fonc_dir_wc_reft = 'LASER_128_tumor_REF$';

fonc_dir_wcsain = 'LASER_128_sain$';
fonc_dir_wc_refsain = 'LASER_128_sain_REF$';

suj = get_subdir_regex(rootdir,sujet_dir_wc);
sp_dir = get_subdir_regex(suj,fonc_dir_wct);
sp_ref = get_subdir_regex(suj,fonc_dir_wc_reft);

spls = get_subdir_regex(suj,fonc_dir_wcsain);
splsref = get_subdir_regex(suj,fonc_dir_wc_refsain);

ser_all = get_subdir_regex(suj,{'LASER','MEGA'});
fall = explore_spectro_data(char(ser_all));

flt=explore_spectro_data(char(sp_dir))
fltref=explore_spectro_data(char(sp_ref))

fls=explore_spectro_data(char(spls))
flsref=explore_spectro_data(char(splsref))

par.mean_line_broadening=10;
%par.METAB_inf=2.9;par.METAB_sup = 3.1;par.METAB_ref = 3.02;par.ref_metab='USER';
%Choline
par.METAB_inf=3.1;par.METAB_sup = 3.3;par.METAB_ref = 3.2;par.ref_metab='USER';

fltc=processing_spec(flt,par) 
flt(4).freq_cor=4; flt(4).phase_cor=4
fltc(4) = flt(4);%bad 


flsc=processing_spec(fls,par) 

parw.ref_metab='water'
fltrefc = processing_spec(fltref,parw)

[fltrefw res]=get_water_width(fltrefc)
fltrefs=scale_fid(fltrefc,mean(res.integral_fid_cor_abs)./res.integral_fid_cor_abs);
flts=scale_fid(fltc,mean(res.integral_fid_cor_abs)./res.integral_fid_cor_abs);

pp.root_dir='/servernas/home/romain/data/spectro/IDH1/new_lcmodel/laser_tumor';
write_fid_to_lcRAW(fltc,pp,fltrefc)

flsc=processing_spec(fls,par);  
flsrefc=processing_spec(flsref,parw);
[flsrefw res]=get_water_width(flsrefc)
flss=scale_fid(flsc,mean(res.integral_fid_cor_abs)./res.integral_fid_cor_abs);

pp.root_dir='/servernas/home/romain/data/spectro/IDH1/new_lcmodel/laser_sain';
write_fid_to_lcRAW(flsc,pp,flsrefc)

processing_LCmodel('laserIDH1','baTE60MMnew')


%%%%%%%%%%%% MEGA PRESS
fonc_dir_wc = 'tumor_32$';
fonc_dir_wc_ref = 'tumor_32_REF$';

fonc_dir_wcsain = 'sain_32$';
fonc_dir_wc_refsain = 'sain_32_REF$';

suj = get_subdir_regex(rootdir,sujet_dir_wc);
sp_dir = get_subdir_regex(suj,fonc_dir_wc);
sp_ref = get_subdir_regex(suj,fonc_dir_wc_ref);

spls = get_subdir_regex(suj,fonc_dir_wcsain);
splsref = get_subdir_regex(suj,fonc_dir_wc_refsain);


fmt=explore_spectro_data(char(sp_dir))
fmtref=explore_spectro_data(char(sp_ref))
fmt(11)=[]; % contain null spectra (BAD water)

fms=explore_spectro_data(char(spls))
fmsref=explore_spectro_data(char(splsref))

fmto = concatenate_fid(fmt)
fmso = concatenate_fid(fms)
fmso(8)=[];
 
par.mean_line_broadening=8;
%par.METAB_inf=2.9;par.METAB_sup = 3.12;par.METAB_ref = 3.02;par.ref_metab='USER';
%Choline
par.METAB_inf=3.1;par.METAB_sup = 3.4;par.METAB_ref = 3.2;par.ref_metab='USER';
fmsc = processing_MEGA(fmso,par)
fmtc = processing_MEGA(fmto,par)
 

 p=plot_spectrum;
 p.xlim=[0 4.5]; p.ylim=[-10000 20000]; p.diff_y_lim=[-4000 4000]
 p.same_fig=1; p.display_var=0;p.mean_line_broadening=2

plot_spectrum(fmsc,p)


parw.ref_metab='water'
fmsrefc = processing_MEGA(fmsref,parw)
fmtrefc = processing_MEGA(fmtref,parw)
%les 3 premiers ont un mauvaise ref de l'eau, je prend donc celle de la
%laser
fmtrefc(1:3) = [];fmsrefc(1:3)=[]
[fmtrefcw res]=get_water_width(fmtrefc)
[fmsrefcw res]=get_water_width(fmsrefc)

write_fid_to_csv(fmsrefcw,'toto.csv');write_fid_to_csv(fmtrefcw,'toto.csv');


pp.mega_type = 'diff_inv' 
pp.root_dir='/servernas/home/romain/data/spectro/IDH1/new_lcmodel/mega_inv_tumor';
write_fid_to_lcRAW(fmtc,pp,fltrefc)
pp.root_dir='/servernas/home/romain/data/spectro/IDH1/new_lcmodel/mega_inv_sain';
write_fid_to_lcRAW(fmsc,pp,flsrefc)


%phantome
clear par
par.reg_metab = 'zero'
par.METAB_inf=-0.1;par.METAB_sup = 0.2;par.METAB_ref = 0;par.ref_metab='USER';
ffmo=concatenate_fid(ffm)
ffmc = processing_MEGA(ffmo,par)


pour transformer roi en volum
froi=get_subdir_regex_files(sp,'^L.*nii')
write_fid_to_nii(froi,pwd)
fr=get_subdir_regex_files(sp,'^L.*mat')
write_roi_to_nii(fr,fa)

