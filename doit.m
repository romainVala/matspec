%***************GENERAL************************

%It works for single voxel spectroscopi and  MEGA PRESS acquisition 
%to make it works you need to add (almost) all subdirectorie in your matlab
%path




%***************IMPORT DATA****************


%For just a few acquisition you can select the directories of dicom file
%with a gui ( spm file selector : change directories on the left, select on the
%rigth panel and unselect with the bottom panel)
fid = explore_spectro_data

%if you have many subject to process, a quick way to select several
%directories of dicom files is something like that
dicom_dir = get_subdir_regex('/path/to/thesubjec','suj','ser');
P = char(dicom_dir)

%get_subdir_regex can have only 2 argument or more
%this will give you all sub directories that contain the name ser in the
%directories (in the first path) that contain the name 'suj'
%'suj' or 'ser' are regulare expresion
%'.*' will give you all subdirectorie
%'^suj.*01$' will give you all name that begin with suj and that end with 01


fid = explore_spectro_data(P)
%this should give you an array of struct containing raw data fid
%and informationa about each spectra


%if you have the same region split in several directories (due to several
%series acquisition then you may use

fid = concatenate_fid(fid);

% it checks for the same series description and the same voxel position and
% then concatenate the fid time data as it was an unique series (of 128 nex
% for instance). A small problem is that it takes all information from the
% first series. So it's wrong for the center frequency which change if
% frequency adjustment is perform between series acquisition. the option
% fid_o = concatenate_fid(fid,1); will try to apply a frequency shift to the
% fid  but the result was quite strange so I do not use it (but I
% would like to have it correctly). Since we do frequency correction on each
% single acquisition it does not matter ...
%note that this concatenation can also be done after preprocessing

 
%******************** PRE-PROCESSING ****************
%you will recognise here part of your original code whith the
%processing_MEGA function which does frequency shift and phase corection on
%each spectra 
par = processing_MEGA;
fid_cor = processing_MEGA(fid,par);       

%For single spectra (whithout editing) use 
par = processing_spec
fid_cor = processing_spec(fid,par);       

%the par structure is the same for the both

%par is a matlab structure (previosly defined) with the following field, if
% not defind (or some field missing) the default value will be taken

par.ref_metab = 'NAA';
par.figure=0;
par.mean_line_broadening=3;
  
par.ref_metab = 'CRE_SMALL2'; % default is CRE_SMALL2 this define the
% reference peak to do the frequency corection on (ref uper and lower bound)
% different value can be easily added in spect_processing/get_peak_bound.m 

%par.correct_freq_mod ='abs';  %default is 'real'
%par.do_phase_cor=0; % 0 will not perform phase corection; default 1
%par.do_freq_cor=0; % 0 will not perform frequency corection; default 1
par.figure=0; % will not display result (corection and the mean difference spectra). default 1
par.mean_line_broadening = 1; % the line broadening aplied before
%frequency corection (it is not apply to fid of the end result it is just
%applied to find the max at a given ppm. default  0 


%do it again for the water reference scan
fwater = explore_spectro_data;
%do some corection or not for instance
parw.ref_metab='water' ;
fwater = precessing_spec(fwater,parw);


fwater = get_water_width(fwater);
%will add several field water_width water_width_no_cor and different
%integral term of the water peak

%*********************** LCMODEL PROCESS *************************
%to convert the matlab fid run : 

pp.root_dir='path/to/write/raw/file'

write_fid_to_lcRAW(fid_cor,pp,fwater);

%if you want just the subject name in the .RAW files you can try with
pp.gessfile = 2;

%there are other option in th pp parameter to take or not subdirectories
%but try this first
%be careful if fid_cor have serveral spectra (an array of struct then fwater
%shlould be a array of corresponding water reference


%process it with LCmodel
processing_LCmodel('laser','test')           %and select the dir in which raw files are written

%it will create a subdirectory test for each input directory and it will use
%the control parameter defined in the file createLCmodel_control_laser.m (in
%lcmodel subdirectory
%of course lcmodel should run on this computer (or I can adapt it with a ssh)



%*********************** To get LCMDEL RESULT

%first get the directories were the ps file are
%the way I do is that I have in a dir ('/rootdir') where all the
%region (ie directorie) containing all .RAW for different subject 
%and after processing_LCmdoel a subdirectorie ('test') where the .PS are
%for your 7T date I change the file write_fid_to_lcRAW to have nice name
%I used for parameter :  pp.gessfile=3; and pp.subdir=3;
%but you can also organize it by hand

d = get_subdir_regex('/rootdir','.*','test')
c = get_reult(d);
%will gi you in c a struct with all lcmodel information length(c) will be
%the number of region char(c(1).suj) will give you the subject of the first
region

%to write it in csv file which you can import in xls
write_conc_res_to_csv(c,'toto.csv');
write_conc_res_summary_gosia_to_csv(ccT2,'totoS.csv');

%if you want the result scale to Cr_PCr=8 (the exact field name of c is the 
%the name of the metabolite basis set and the lcmodel summed
c_cre = correct_result_ration(c,'','Cr_Pcr',8)

%then you can juste write it ! with write_conc_res...
    

%*************** PLOTTING ****************************
% this will plot all the spectra 


plot_spectrum(fid_cor)

%or

plot_spectrum(fid_cor,p)

%with p define with any of the following line

p.mean_line_broadening = 2;
p.xlim = [0 6]; %default is full range
%p.y_lim=[-3000 3000] will set the y axis limite: default is full range
p.diff_y_lim = [-500 3000]; %y axis limit only for the difference spectrum (third plot)

%p.save_file = '/home/romain/spectro_mega'; %will save a postcript file of the figure
p.display_var = 0; %will only plot the mean. default is 1 : it will display
%all single spectrum in green and the mean in blue

p.same_fig=1; % will plot all spectra (as many as length(fid_cor)) in the
%same figure. (use it with .display_var=0 to see something ) default value
%is 0 (a figure for each)

%p.display = 'abs'; % or 'imag' or 'phase' or 'real'  ... to select the
% spectial display you want : default is 'real'
%p.x_freq=1 % to display xaxis in frequency, if not defined it uses ppm
%param.plot_ref_peak = 'CRE_SMALL2' ;%will plot the reference peak (possible
% value are defined in spect_processing/get_peak_bound.m 
  

%for instance if you do 2 corection you can do 
plot_spectrum([fid_cor1,fid_cor2],p)  %to see them in the same plot


%%%%%%%%%%%%% some other small thing
plot_adjust_phase(fid) %will give you a gui to change and see the phase you
%can then apply it with :
fid_cor2 = chage_phase(fid_cor,20) %for a 20° phase change



%
plot_diff(f1,f2)  %if a plot to compare 2 population of spectra f1 and f2



There are also different routine read lcmodel result  correct for csf
I'll explain it soon

be patient, send me the matlab error, and have fun);;;