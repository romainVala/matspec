function controlfilename = createLCmodel_control_mega_2HG(metabname,l1,l2,l3,preproc_dir)

nb=1;
do_water_scaling=0;

phantome=0;

basis_set_file_path = '/home/romain/data/spectro/Basis_set/MEGA5_inv/MEGA5_inv.BASIS';
%basis_set_file_path = '/home/romain/data/spectro/Basis_set/MEGA5_inv_no_gln/MEGA5.BASIS';
%basis_set_file_path = '/home/romain/data/spectro/Basis_set/MEGA6_relax/MEGA6.BASIS';


switch nb
  case 1
    basis_set_file_path = '/home/romain/data/spectro/Basis_set/MEGA_2HG/basis_MEGA_edit_CENIR_120716.BASIS';

  case 2
    basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/new_MEGA/basis_MEGA_edit_CENIR.BASIS';
    basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/new_MEGA/basis_MEGA_edit_CENIR_SS.BASIS';
end
  

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

 if do_water_scaling
   %%%%%%%for ws (water scaling)
   fprintf(fileid,' DOWS=T\n');

   %Gab marche pas avec 3.8 ou 3.7

   fprintf(fileid,' WSMET=NAA\n');
   fprintf(fileid,' WSPPM=2.01\n');

   fprintf(fileid,' N1HMET=3\n');

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


switch nb
  case 1
    fprintf(fileid,' NCOMBI=1');
    fprintf(fileid,' CHCOMB(1) = ''GLU+GLN''\n ');
    fprintf(fileid,' NAMREL=''NAA''\n'); %give ratio over NAA
    fprintf(fileid,' CONREL=11\n'); %11 mm give the attemp conc of NAA
    
    fprintf(fileid,' NUSE1=3\n');
    fprintf(fileid,' CHUSE1(1)=''NAA'',''GABA'',''GLU''\n');

  case 2
    fprintf(fileid,' NCOMBI=1');
    fprintf(fileid,' CHCOMB(1) = ''ed_Gln+ed_Glu''\n ');    
    fprintf(fileid,' NAMREL=''ed_NAA''\n'); %give ratio over NAA
    fprintf(fileid,' CONREL=11\n'); %11 mm give the attemp conc of NAA

    fprintf(fileid,' NUSE1=3\n');
    fprintf(fileid,' CHUSE1(1)=''ed_NAA'',''ed_GAB'',''ed_Glu''\n');
    
end
 

%fprintf(fileid,' NOMIT=1\n');
%fprintf(fileid,' CHOMIT(1)=''MM''\n');

if phantome
  fprintf(fileid,' NOMIT=4\n');
  fprintf(fileid,' CHOMIT(1)=''GABA''\n');
  fprintf(fileid,' CHOMIT(2)=''GLU''\n');
  fprintf(fileid,' CHOMIT(3)=''GLN''\n');
  fprintf(fileid,' CHOMIT(4)=''MM''\n');
end


fprintf(fileid,[' DEGZER= 0 \n']);
fprintf(fileid,' SDDEGZ=20.\n');
fprintf(fileid,[' DEGPPM=0\n']);
fprintf(fileid,' SDDEGP=20.0\n');  %let s try at 6

fprintf(fileid,' NSIMUL=0\n');

%fprintf(fileid,' SHIFMN=-0.2,-0.1\n');
%fprintf(fileid,' SHIFMX=0.3,0.3\n');

fprintf(fileid,' FWHMBA=0.0160\n'); %width of the basis set NAA %firstly
%0.005 if 2Hz lineshape 2/123.26 = 0.016

%GABA std 20 -> 19 (without)
fprintf(fileid,' RFWHM=2.5\n');   % corection to lineshape (default 1.8)
% (increas it to 3 when to big lineshap)

%no information in the user manual (Hidden Control Parameters)
fprintf(fileid,' DKNTMN=0.5\n');


fprintf(fileid,' PPMST=4.5\n');
fprintf(fileid,' PPMEND=0.5\n');

fprintf(fileid,' NNORAT = 1\n');
fprintf(fileid,' NORATO = ''GABA''\n');

fprintf(fileid,[l1,'\n']);
fprintf(fileid,[l2,'\n']);
fprintf(fileid,[l3,'\n']);
fprintf(fileid,' $END\n');

fclose(fileid);

