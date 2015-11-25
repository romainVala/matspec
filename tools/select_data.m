function P=select_data()

rootdir = '/home/romain/data/spectro/PROTO_SPECTRO_DYST/Sujet_dicom';


sujet_dir_wc = {'Sujet'};
%sujet_dir_wc = {'2008_06'};

%sujet control
%for BGL
%sujet_dir_wc = {'Sujet03','Sujet04','Sujet05','Sujet07','Sujet08','Sujet10','Sujet15','Sujet02','Sujet22','Sujet11','Sujet01'};

%for MCL
sujet_dir_wc = {'Sujet01$','Sujet02$','Sujet03$','Sujet04$','Sujet05$','Sujet07$','Sujet08$','Sujet10$','Sujet11$','Sujet14$','Sujet15$','Sujet22$','Sujet37$','Sujet38$'};
% plus sujet14 1 session   (Sujet 11 Left handed)
%for BGL 01 04 22 have no 2nd session.  11 E1 has the biggest watter peak
%sujet_dir_wc = {'Sujet02','Sujet03','Sujet05','Sujet07','Sujet08','Sujet10','Sujet11','Sujet14','Sujet15'};


%sujet dyto
%for BGL suj 21 24 have no 2ne session
%sujet_dir_wc = {'Sujet06','Sujet12','Sujet13','Sujet19','Sujet20','Sujet23','Sujet25','Sujet26','Sujet27','Sujet28','Sujet29','Sujet30','Sujet35'};

%for MCL
%sujet_dir_wc = {'Sujet06','Sujet12','Sujet13','Sujet19','Sujet20','Sujet21','Sujet23','Sujet24','Sujet25','Sujet26','Sujet27','Sujet28','Sujet29','Sujet30','Sujet35','Sujet41'};
%sujet21 Sujetis bad (lipide contamination) for MCL E2 Sujet 19 : too BAD
%plus sujet 23 1 session

%for MM
%sujet_dir_wc = {'Sujet08','Sujet11','Sujet14','Sujet15','Sujet12','Sujet13','Sujet19','Sujet21','Sujet23','Sujet24','Sujet25','Sujet26','Sujet27','Sujet29','Sujet30','Sujet35'}

%sujet_dir_wc = {'uje'};

%sujet_dir_wc = {'Sujet28','Sujet35','Sujet37','Sujet38','Sujet41'};


fonc_dir_wc = '_MC_R$';
%fonc_dir_wc = '_OCC_MM$';
%fonc_dir_wc = '_MC_L$';
%fonc_dir_wc = '_BG_R$';
%fonc_dir_wc = '_OCC$';
%fonc_dir_wc = '_BG_L$';
%fonc_dir_wc = '_CER$';
%fonc_dir_wc = {'OCC_MM$','OCC_MM_TI','OCC_TI'};

fonc_dir_wc = {'_MC_L$','MC_R$','_OCC$','_BG_L$','BG_R$','CER$'};
fonc_dir_wc = {'_OCC$','_BG_L$','BG_R$','CER$'};

fonc_dir_wc = 'BG_L$';


s_dir = get_subdir_regex(rootdir,sujet_dir_wc);
s_sub_dir = get_subdir_regex(s_dir,fonc_dir_wc);

P = char(s_sub_dir);

