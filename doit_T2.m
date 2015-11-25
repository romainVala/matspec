rootdir = '/nasDicom/dicom_raw/PROTO_SL_BG3T/';

sujet_dir_wc = {'REPROT2_H'};

fonc_dir_wc = 'laser_TE.*N...$';

s_dir = get_subdir_regex(rootdir,sujet_dir_wc);
s_sub_dir = get_subdir_regex(s_dir,fonc_dir_wc);

P = char(s_sub_dir);

f=explore_spectro_data(P);

fs = sum_fid_local(f,4);

par = processing_spec
par.figure=0;
par.mean_line_broadening=4;
fc = processing_spec(fs,par);

