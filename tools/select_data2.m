function P=select_data()

rootdir = '/home/romain/data/spectro/hipo/dicom_files';

sujet_dir_wc = {'Sujet1[01]','Sujet09'};


fonc_dir_wc = 'TE64$';



s_dir = get_subdir_regex(rootdir,sujet_dir_wc);
s_sub_dir = get_subdir_regex(s_dir,fonc_dir_wc);

P = char(s_sub_dir);

