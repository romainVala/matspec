function controlfilename = createLCmodel_control_svs(metabname,l1,l2,l3)

controlfilename=[metabname '.CONTROL'];

% create .CONTROL file for LCModel
disp(['Creating file ' metabname]); disp(' ')

if findstr('se_140',metabname)
  te=140;
elseif findstr('se_30',metabname)
  te=30;
else te=18;
end

do_water_scaling=1;
doecc=0;

[pathstr,filename ] = fileparts(metabname)

rawname = metabname;

fileid=fopen(controlfilename,'w');
fprintf(fileid,' $LCMODL\n');
fprintf(fileid,[' TITLE=''HIPO deprim''\n']);
fprintf(fileid,[' OWNER=''CENIR''\n']);
fprintf(fileid,[' PGNORM=''A4''\n']);


switch te
  case 18
    fprintf(fileid,[' FILBAS=''/home/romain/.lcmodel/basis-sets/3t/gamma_press_te18_123mhz_173.basis''\n']);
  case 30
    fprintf(fileid,[' FILBAS=''/home/romain/.lcmodel/basis-sets/3t/gamma_press_te30_123mhz_104.basis''\n']);
  case 40
    fprintf(fileid,[' FILBAS=''/home/romain/.lcmodel/basis-sets/3t/gamma_press_te40_123mhz_106.basis''\n']);
  case 140
    fprintf(fileid,[' FILBAS=''/home/romain/.lcmodel/basis-sets/3t/gamma_press_te140_123mhz_167.basis''\n']);


end

fprintf(fileid,[' FILRAW=''' metabname '.RAW''\n']);
fprintf(fileid,[' FILPS=''' metabname  '.PS''\n']);
fprintf(fileid,[' FILCOO=''' metabname '.COORD''\n']);
fprintf(fileid,' LCOORD=31\n');
fprintf(fileid,[' FILPRI=''' metabname '.PRINT''\n']);
fprintf(fileid,' LPRINT=6\n');
%fprintf(fileid,[' FILTAB=''' metabname '.TAB''\n']);
%fprintf(fileid,' LTABLE=7\n');

 %FILTAB='Sujet07_E1_MC_L.TAB'
 %LTABLE = 7


%fprintf(fileid,' TRAMP=1\n VOLUME=7.2 \n');
if do_water_scaling
  
  %fprintf(fileid,' DOECC=T\n');
  fprintf(fileid,' DOWS=T\n');
  
  dd=dir([rawname,'*.H2O']);
  if length(dd)~=1
    error('can not find water referenc scan of %s',rawname)
  end

  % fprintf(fileid,' WCONC=40300\n');
  % fprintf(fileid,' ATTH2O=0.45\n');  %exp(-64/80)
  % fprintf(fileid,' ATTMET=0.7\n');   %exp(-64/300)*(1-exp(-3000/1500))

  fprintf(fileid,' WCONC=55555\n');
  fprintf(fileid,' ATTH2O=1\n');
  fprintf(fileid,' ATTMET=1\n');

  %fprintf(fileid,' WCONC=42400\n');
  %fprintf(fileid,' ATTH2O=0.34\n');
  %fprintf(fileid,' ATTMET=1\n');
  
  fprintf(fileid,[' FILH2O=''' fullfile(pathstr,dd.name) '''\n']);

  if doecc
    fprintf(fileid,' DOECC=T\n');
  end
  

end

fprintf(fileid,' NEACH=50\n');
%fprintf(fileid,' NUSE1=4\n');
%fprintf(fileid,' CHUSE1(1)=''GABA'',''NAA'',''GLU'',''OCC_MM''\n');

fprintf(fileid,[' DEGZER= 0 \n']);
%fprintf(fileid,' SDDEGZ=20.\n');
fprintf(fileid,' SDDEGZ=999.\n');
fprintf(fileid,[' DEGPPM=0\n']);
fprintf(fileid,' SDDEGP=20.0\n');
%fprintf(fileid,' SDDEGP=0\n');

%fprintf(fileid,' NSIMUL=0\n');
%fprintf(fileid,' NSIMUL=13\n');

%fprintf(fileid,' SHIFMN=-0.2,-0.1\n');
%fprintf(fileid,' SHIFMX=0.3,0.3\n');

fprintf(fileid,' FWHMBA=0.0050\n');

%GABA std 20 -> 19 (without)
%fprintf(fileid,' RFWHM=2.5\n');

%no information in the user manual (Hidden Control Parameters)
%fprintf(fileid,' DKNTMN=1\n');

%fprintf(fileid,' RFWHM=2.5\n');
%fprintf(fileid,' DKNTMN=0.25\n');


fprintf(fileid,' PPMST=4.5\n');
fprintf(fileid,' PPMEND=0.8\n');

fprintf(fileid,[l1,'\n']);
fprintf(fileid,[l2,'\n']);
fprintf(fileid,[l3,'\n']);
fprintf(fileid,' $END\n');

fclose(fileid);

