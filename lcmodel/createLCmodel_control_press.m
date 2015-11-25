function controlfilename = createLCmodel_control(metabname,l1,l2,l3,preproc_dir)

basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/basis_PRESS_TE68_CENIR_090730.BASIS';
basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/basis_PRESS_TE=68_CENIR_090901.BASIS';
basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/press_raw/basis_PRESS_090730_Glu_Gln_Vivo.BASIS';
basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/PRESS_new/basis_PRESS_TE=68_CENIR_090909.BASIS';
basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/PRESS_new2/basis_PRESS_TE=68_CENIR_090911.BASIS';
%basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/PRESS_new2/basis_PRESS_TE=68_CENIR_090911_exp.BASIS';
%basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/PRESS_new3/basis_PRESS_TE=68_SS.BASIS';
%basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/PRESS_new3/basis_PRESS_TE=68_CENIR_090916.BASIS';

%basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/PRESS_new4/basis_PRESS_TE=68_CENIR_090917_inv.BASIS';
%basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/PRESS_new4/basis_PRESS_TE=68_CENIR_090917_80.BASIS';

basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/PRESS_new5/basis_PRESS_TE=68.BASIS';
basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/PRESS_new6/basis_PRESS_TE=68.BASIS';
%basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/PRESS_new7/basis_PRESS_TE=68_rel.BASIS';
%basis_set_file_path = '/home/romain/.lcmodel/basis-sets/3t/gamma_press_te18_123mhz_173.basis';

do_water_scaling=1;
NAA=1;


[pathstr,filename ] = fileparts(metabname)

wd = fullfile(pathstr,preproc_dir)
if ~exist(wd)
  mkdir(wd)
end

rawname = metabname;
metabname = fullfile(wd,filename);

controlfilename=[metabname '.CONTROL'];

% create .CONTROL file for LCModel
disp(['Creating file ' metabname]); disp(' ')

fileid=fopen(controlfilename,'w');
fprintf(fileid,' $LCMODL\n');
fprintf(fileid,[' TITLE=''Encours''\n']);
fprintf(fileid,[' OWNER=''Montreal''\n']);
fprintf(fileid,[' PGNORM=''US''\n']);
fprintf(fileid,[' FILBAS=''%s''\n'],basis_set_file_path);
fprintf(fileid,[' FILRAW=''' rawname '.RAW''\n']);
fprintf(fileid,[' FILPS=''' metabname  '.PS''\n']);
fprintf(fileid,[' FILCOO=''' metabname '.COORD''\n']);
fprintf(fileid,' LCOORD=31\n');
fprintf(fileid,[' FILPRI=''' metabname '.PRINT''\n']);
fprintf(fileid,' LPRINT=6\n');
%fprintf(fileid,[' FILTAB=''' metabname '.TAB''\n']);
%fprintf(fileid,' LTABLE=7\n');

 %FILTAB='Sujet07_E1_MC_L.TAB'
 %LTABLE = 7

 
% fprintf(fileid,' NOMIT=3\n');
% fprintf(fileid,' CHOMIT(1)=''Asc''\n');
% fprintf(fileid,' CHOMIT(2)=''GSH''\n');
% fprintf(fileid,' CHOMIT(3)=''Glc''\n');
% fprintf(fileid,' \n');
 
 if do_water_scaling
   %%%%%%%for ws (water scaling)
   fprintf(fileid,' DOWS=T\n');

   %fprintf(fileid,' WSMET=sNAA\n');
   %fprintf(fileid,' WSPPM=2.01\n');
   %fprintf(fileid,' N1HMET=3\n');
   
   fprintf(fileid,' WCONC=55555\n');
   fprintf(fileid,' ATTH2O=1.0\n');
   fprintf(fileid,' ATTMET=1.0\n');


  dd=dir([rawname,'*.H2O']);
  if length(dd)~=1
    error('can not find water referenc scan of %s',rawname)
  end

  fprintf(fileid,[' FILH2O=''' fullfile(pathstr,dd.name) '''\n']);

 end 

fprintf(fileid,' NEACH=31\n');

%NCOMBI=1
%CHCOMB(1)='ed_Gln+ed_Glu'; %to combie

fprintf(fileid,' NAMREL=''Cr+PCr''\n'); %give ratio over NAA
fprintf(fileid,' CONREL=8\n'); %11 mm give the attemp conc of NAA

switch NAA
  case 1
    fprintf(fileid,' NCOMBI=5');
    fprintf(fileid,' CHCOMB(1) = ''NAA+NAAG''\n ');
    fprintf(fileid,' CHCOMB(2) = ''Cr+PCr''\n ');
    fprintf(fileid,' CHCOMB(3) = ''Glc+Tau''\n ');
    fprintf(fileid,' CHCOMB(4) = ''Glu+Gln''\n ');
    fprintf(fileid,' CHCOMB(5) = ''PCho+GPC''\n ');

  case 2
    fprintf(fileid,' NCOMBI=6');
    fprintf(fileid,' CHCOMB(1) = ''mNAA+NAAG''\n ');
    fprintf(fileid,' CHCOMB(2) = ''sNAA+NAAG''\n ');
    fprintf(fileid,' CHCOMB(3) = ''Cr+PCr''\n ');
    fprintf(fileid,' CHCOMB(4) = ''Glc+Tau''\n ');
    fprintf(fileid,' CHCOMB(5) = ''Glu+Gln''\n ');
    fprintf(fileid,' CHCOMB(6) = ''PCho+GPC''\n ');

  case 3
    fprintf(fileid,' NCOMBI=5');
    fprintf(fileid,' CHCOMB(1) = ''NAAr+NAAG''\n ');
    fprintf(fileid,' CHCOMB(2) = ''Cr+PCr''\n ');
    fprintf(fileid,' CHCOMB(3) = ''Glc+Tau''\n ');
    fprintf(fileid,' CHCOMB(4) = ''Glu+Gln''\n ');
    fprintf(fileid,' CHCOMB(5) = ''PCho+GPC''\n ');
    
end

fprintf(fileid,' NUSE1=2\n');
switch NAA
  case 1
    fprintf(fileid,' CHUSE1(1)=''Cr'',''NAA''\n');
    %fprintf(fileid,' CHUSE1(1)=''Cr'',''NAA''\n');
  case 2
    fprintf(fileid,' CHUSE1(1)=''Cr'',''sNAA''\n');
  case 3
    fprintf(fileid,' CHUSE1(1)=''Cr'',''NAAr''\n');    
end

%fprintf(fileid,' CHUSE1(1)=''ed_GAB'',''ed_NAA'',''ed_Glu'',''ed_Gln'',''Mac''\n');

fprintf(fileid,[' DEGZER= 0 \n']);
fprintf(fileid,' SDDEGZ=20.\n');
fprintf(fileid,[' DEGPPM=0\n']);
fprintf(fileid,' SDDEGP=20.0\n');  %let s try at 6

%fprintf(fileid,' NSIMUL=0\n');

%fprintf(fileid,' SHIFMN=-0.2,-0.1\n');
%fprintf(fileid,' SHIFMX=0.3,0.3\n');

fprintf(fileid,' FWHMBA=0.0160\n'); %width of the basis set NAA %firstly
%0.005 if 2Hz lineshape 2/123.26 = 0.016

%GABA std 20 -> 19 (without)
fprintf(fileid,' RFWHM=2.5\n');   % corection to lineshape (default 1.8)
% (increas it to 3 when to big lineshap)

%no information in the user manual (Hidden Control Parameters)
fprintf(fileid,' DKNTMN=0.5\n');

fprintf(fileid,'NRATIO=0\n');

fprintf(fileid,' PPMST=4.2\n');
fprintf(fileid,' PPMEND=0.5\n');

fprintf(fileid,[l1,'\n']);
fprintf(fileid,[l2,'\n']);
fprintf(fileid,[l3,'\n']);
fprintf(fileid,' $END\n');

fclose(fileid);

