function controlfilename = createLCmodel_control(metabname,l1,l2,l3,preproc_dir)


do_water_scaling=0;
single_NAA_basis=0;
gaba=1;

if single_NAA_basis
  basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/NAA_090814.BASIS';
else
  basis_set_file_path = '/home/romain/data/spectro/Basis_set/Gosia/basis_PRESS_TE68_CENIR_090730.BASIS';
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
fprintf(fileid,[' PGNORM=''A4''\n']);
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

   if single_NAA_basis
     fprintf(fileid,' WSMET=NAA\n');
   else
     if gaba
       fprintf(fileid,' WSMET=GABA\n');
     else
       fprintf(fileid,' WSMET=sNAA\n');
     end
   end

   fprintf(fileid,' WSPPM=2.01\n');

   fprintf(fileid,' N1HMET=3\n');
   fprintf(fileid,' WCONC=55555\n');
   fprintf(fileid,' ATTH2O=1.0\n');
   fprintf(fileid,' ATTMET=1.0\n');
   
   %fprintf(fileid,' WSMET=NAA\n');
   %fprintf(fileid,' WSPPM=3.\n');

  dd=dir([rawname,'*.H2O']);
  if length(dd)>1
    dd=dir([rawname,'_ref.H2O']);
  end
  
  if length(dd)~=1
    error('can not find water referenc scan of %s',rawname)
  end

  fprintf(fileid,[' FILH2O=''' fullfile(pathstr,dd.name) '''\n']);

 end 

%fprintf(fileid,' NEACH=31\n');

if ~single_NAA_basis

  if gaba
    fprintf(fileid,' NCALIB=1\n');
    fprintf(fileid,' CHCALI(1)=''Glu''\n');
    fprintf(fileid,' NUSE1=1\n');
    fprintf(fileid,' CHUSE1(1)=''Glu''\n');

  else
    fprintf(fileid,' NCALIB=1\n');
    fprintf(fileid,' CHCALI(1)=''sNAA''\n');
    %  fprintf(fileid,' CHCALI(2)=''mNAA''\n');
  end
end


%NCOMBI=1
%CHCOMB(1)='ed_Gln+ed_Glu'; %to combie

%fprintf(fileid,' NAMREL=''Cr+PCr''\n'); %give ratio over NAA
%fprintf(fileid,' CONREL=8\n'); %11 mm give the attemp conc of NAA

%fprintf(fileid,' NCOMBI=6');
%fprintf(fileid,' CHCOMB(1) = ''mNAA+NAAG''\n ');
%fprintf(fileid,' CHCOMB(2) = ''sNAA+NAAG''\n ');
%fprintf(fileid,' CHCOMB(3) = ''Cr+PCr''\n ');
%fprintf(fileid,' CHCOMB(4) = ''Glc+Tau''\n ');
%fprintf(fileid,' CHCOMB(5) = ''Glu+Gln''\n ');
%fprintf(fileid,' CHCOMB(6) = ''PCho+GPC''\n ');

%fprintf(fileid,' NUSE1=2\n');
%fprintf(fileid,' CHUSE1(1)=''Cr'',''sNAA''\n');
%fprintf(fileid,' CHUSE1(1)=''ed_GAB'',''ed_NAA'',''ed_Glu'',''ed_Gln'',''Mac''\n');

fprintf(fileid,[' DEGZER= 0 \n']);
fprintf(fileid,' SDDEGZ=200.\n');
fprintf(fileid,[' DEGPPM=0\n']);
fprintf(fileid,' SDDEGP=0.0\n');  %let s try at 6

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


fprintf(fileid,' PPMST=4.2\n');
fprintf(fileid,' PPMEND=0.5\n');

fprintf(fileid,[l1,'\n']);
fprintf(fileid,[l2,'\n']);
fprintf(fileid,[l3,'\n']);
fprintf(fileid,' $END\n');

fclose(fileid);

