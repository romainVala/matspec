function controlfilename = createLCmodel_control_laser117T(metabname,l1,l2,l3,preproc_dir)

do_water_scaling=0;
doecc=0;


%basis_set_file_path = '/home/romain/tmp/basis/basis_LASER_TE_20_11T.BASIS';
basis_set_file_path = '/servernas/home/romain/data/spectro/Basis_set/laser_11T_mouse/basis_LASER_TE_20_117T_MM.BASIS'


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
fprintf(fileid,[' TITLE='' CMRR _ CENIR''\n']);
fprintf(fileid,[' OWNER=''rrr''\n']);
fprintf(fileid,[' PGNORM=''US''\n']);

fprintf(fileid,[' FILBAS=''%s''\n'],basis_set_file_path);

fprintf(fileid,[' FILRAW=''' rawname '.RAW''\n']);
fprintf(fileid,[' FILPS=''' metabname  '.PS''\n']);
fprintf(fileid,[' FILCOO=''' metabname '.COORD''\n']);
fprintf(fileid,' LCOORD=9\n');
fprintf(fileid,[' FILPRI=''' metabname '.PRINT''\n']);
fprintf(fileid,' LPRINT=6\n');
%fprintf(fileid,[' FILTAB=''' metabname '.TAB''\n']);
%fprintf(fileid,' LTABLE=7\n');

 %FILTAB='Sujet07_E1_MC_L.TAB'
 %LTABLE = 7
 
fprintf(fileid,' NEACH=30\n');
fprintf(fileid,' NSIMUL=0\n');

if do_water_scaling
  
  fprintf(fileid,' DOWS=T\n');
  
  dd=dir([rawname,'*.H2O']);
  if length(dd)~=1
    error('can not find water referenc scan of %s',rawname)
  end

  fprintf(fileid,' WCONC=55555\n');
  fprintf(fileid,' ATTH2O=1\n');
  fprintf(fileid,' ATTMET=1\n');

  fprintf(fileid,' DOWS=T \n');
  
  fprintf(fileid,' NRATIO=0 \n');
  
  fprintf(fileid,[' FILH2O=''' fullfile(pathstr,dd.name) '''\n']);

  if doecc
    fprintf(fileid,' DOECC=T\n');
  end
  

end

%fprintf(fileid,' TRAMP=1\n VOLUME=7.2 \n');

  fprintf(fileid,' NCOMBI=6\n');
  fprintf(fileid,' CHCOMB(1) = ''NAA+NAAG''\n ');
  fprintf(fileid,' CHCOMB(2) = ''Glu+Gln''\n ');
  fprintf(fileid,' CHCOMB(3) = ''PCho+GPC''\n ');
  fprintf(fileid,' CHCOMB(4) = ''PCho+GPC+Gly''\n ');
  fprintf(fileid,' CHCOMB(5) = ''Cr+PCr''\n ');
  fprintf(fileid,' CHCOMB(6) = ''Lac+Thr''\n ');

  fprintf(fileid,' NUSE1=4\n');

  fprintf(fileid,' CHUSE1(1)=''Cr''\n');
  fprintf(fileid,' CHUSE1(2)=''PCr''\n');
  fprintf(fileid,' CHUSE1(3)=''NAA''\n');
  fprintf(fileid,' CHUSE1(4)=''Tau''\n');
  
  fprintf(fileid,' NAMREL=''Cr+PCr''\n'); %give ratio over NAA


fprintf(fileid,' CONREL=8\n'); %11 mm give the attemp conc of NAA

% 
% fprintf(fileid,[' NSDSH=3 \n']);
% fprintf(fileid,[' CHSDSH(1)=''sIns'' \n']);
% fprintf(fileid,[' CHSDSH(2)=''GPC''  \n']);
% fprintf(fileid,[' CHSDSH(3)=''Gly'' \n']);
% fprintf(fileid,[' ALSDSH(1)=0.004 \n']);
% fprintf(fileid,[' ALSDSH(2)=0.004 \n']);
% fprintf(fileid,[' ALSDSH(3)=0.004 \n']);
% fprintf(fileid,[' DESDSH=0.002 \n']);
%fprintf(fileid,[' \n']);

fprintf(fileid,[' DEGZER= 0 \n']); %expected value of zero order phase corection
fprintf(fileid,' SDDEGZ=20.\n');    %freedom in zero order phase corection
fprintf(fileid,[' DEGPPM=0\n']);   %expected value of first order phase correction
fprintf(fileid,' SDDEGP=20\n');  %standard deviation in expectation value of degppm 

%fprintf(fileid,' SHIFMN=-0.2,-0.1\n');
%fprintf(fileid,' SHIFMX=0.5,0.5\n');

fprintf(fileid,' FWHMBA=0.0050\n');
%no information in the user manual (Hidden Control Parameters)

%fprintf(fileid,' RFWHM=3\n');

fprintf(fileid,' RFWHM=1.8\n');
fprintf(fileid,' DKNTMN=5\n');

%fprintf(fileid,' DKNTMN=0.2\n');

%fprintf(fileid,'NRATIO=0\n');
fprintf(fileid,'NRATIO=13\n');

fprintf(fileid,' PPMST=4.1\n');
fprintf(fileid,' PPMEND=0.5\n');

%for BG spectral width 2000 
%fprintf(fileid,' PPMEND=1.35\n');


fprintf(fileid,' NOMIT=7\n');
fprintf(fileid,' CHOMIT(1)=''sNAA''\n');
fprintf(fileid,' CHOMIT(2)=''mNAA''\n');
fprintf(fileid,' CHOMIT(3)=''CrCH3''\n');
fprintf(fileid,' CHOMIT(4)=''CrCH2''\n');
fprintf(fileid,' CHOMIT(5)=''PCrCH3''\n');
fprintf(fileid,' CHOMIT(6)=''PCrCH2''\n');
fprintf(fileid,' CHOMIT(7)=''2HG''\n');


fprintf(fileid,[l1,'\n']);
fprintf(fileid,[l2,'\n']);
fprintf(fileid,[l3,'\n']);
fprintf(fileid,' $END\n');

fclose(fileid);

