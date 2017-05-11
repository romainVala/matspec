%this script uses 3 different matlab package :
%matspect.tar.gz is the matlab code for spectroscopy analysis
%spm8.tar.gz is the spm code (you can also get it from their site)
%batch5.tar.gz is my matlab code (mainly for automatisation of spm command)

%unzip those and add all directories (and sub dir) in your matlab path.
% if you work with linux, (and a bash shel) you can also start matlab
% with the script matlab_start (you must edit this script and adjust the path). 
% this will set the matlab path and start matlab



%***************************************************************************
%the first step is to convert the dicom anatomical data into nifti format
%if this is siemens dicom, you can try the command in matlab
convert_dicom

%it will ask you an input directory of dicom file (you can give the root
%directory where all the subject are stored)
%it will then ask you for an output directory 
%and it will create in this output directory
%an subdir PROTOCOL NAME and in it sujbect dirs and series dir.
%you only need to keep the T1 series.


%***************************************************************************
%% T1 SEGMENTATION
%% First get the data
T1dir = get_subdir_regex('c:path\to\the\subject\dir','suj','t1');

%'suj' is the regular expression that will select in root_dir all directories
%that contain 'suj'. and in all those directorie all subdirs that contain 't1';
%to see what is your selection
char(T1dir)

%if you put all your T1 volumes in a single folder then you only  need to enter :
T1dir = '/path/to/the/T1/volume/folder';
  
% get the T1 volume
fT1 = get_subdir_regex_files(T1dir,'.*img$');

%If you have .nii.gz files you must unzip them
fT1 = get_subdir_regex_files(T1dir,'.*nii.gz$')
fT1 = unzip_volume(fT1); %this unzip your nifti file, which needed before use with spm


%to see what is your selection
char(fT1)

%Run the segmentation using the new segment function of spm8
job= job_new_segment(fT1);
%to see the spm parameter and then you can push the green button to run it
spm_jobman('interactive',job)
%or directly execute the job, this will take ~ 15 mn for each volume
spm_jobman('run',job)


%you should end up with new volume (10 for each T1 volume) in your t1 directories 
% Only Three are of interest they have suffix c1 c2 c3 for gray white and csf
%You must have a loock to those 3 volume to ensure that they are correct


%**************************************************************************
%******************** NOTE ON THE get_subdir_regex and get_subdir_regex_files

%the regular expresion is very powerful to select any subset of names
%but sometimes, (for instance if you only want to select a few number of
%files or directories) it is convinient to have a graphical selection

%for that you can call those function without argument (or only with one
%argument the rootdirectory to start the selection
somedir = get_subdir_regex;
somefiles = get_subdir_regex_files;
somefiles = get_subdir_regex_files(somedir);
% this will call the spm graphical selection box in the uper left panel you
%can travel in your folder structure, with the uper rigth panel you make your
%selection and with the down panel you can remove some selection
%press the done button when you are done ...
%**************************************************************************



%***************************************************************************
%next step if to convert your dicom spectra into nifti volume

%get all referenc scan for each voxel for each subject
dr=get_subdir_regex('c:path\to\the\subject\dir','suj','ref$');
%ON Kati DATA
dr = get_subdir_regex('/home/romain/data/spectro/spectro_data_copy','^PN.*-laser.*wref$')
%this will select all folders that start with PN (^PN) and contain any thing (.*) 
%and contain '-laser' and then any thing (.*) and that end with wref(wref$)

%read the dicom spectra into matlab structure
war = explore_spectro_data(char(dr));

%Convert the spectroscopic voxel position into a nifti volume
write_fid_to_nii(war,'/home/romain/spectro_data_copy/anat');
   
    
%***************************************************************************
%*************** GET THE RESULTS
%First extract the LCmodel concentration

%if the lcmmodel results are in different directory use 
d=get_subdir_regex; %to select all directories

c=get_result(d)            


%next step is to get the water content in each voxel
% if c is the matlab structure obtain from get_result
% You must define the T1dir variable the same way as for the segmentation 
% then the selection of gray white and csf is easy this is the volume that
% start with c1 c2 c3 :

C1_files = get_subdir_regex_files(T1dir,'^c1');
C2_files = get_subdir_regex_files(T1dir,'^c2');
C3_files = get_subdir_regex_files(T1dir,'^c3');

%you must alos get the water reference nifti volume
%first get the folder
water_ref_nifti_folder = get_subdir_regex('/home/romain/spectro_data_copy/anat/spectro_data_copy','^PN');
%this will select all folders which name starts with PN
water_files = get_subdir_regex_files(water_ref_nifti_folder,'.*nii$');

cw=get_water_content(c,C1_files,C2_files,C3_files,water_files)

%WARNING it is very important to check that you have the same subject in the
%same order for each of those 3 variable the selection will follow the
%alphabetic order, so it should be ok, but it depend of the naming convetion 
%the one use for the .RAW

char(c.suj)
char(water_files)
char(C1_files)

%For Katie, I thing you use the write_fid_to_lcRAW fonction with the
%pp.gessfile=2 as argument ;


%next step is to compute the water relaxation which depend on those parameters

par.water_fraction = [0.78 0.65 0.97];
par.TR=3000;      par.TE=64;
par.gmT1=1000;    par.gmT2=70;
par.wmT1=1000;    par.wmT2=70;
par.csfT1=4000;   par.csfT2=400;

cw=water_content_attenuation(cw,par)

%apply those corection to the lcmodel concentration
cc=correct_result(c,cw);

call=concat_conc(cc,cw);

%write it to a csv file (toto.csv) which you can import in xls
write_conc_res_to_csv(call,'toto.csv')

%an alternative summary is 
write_conc_res_summary_gosia_to_csv(cc,'totoS.csv')
