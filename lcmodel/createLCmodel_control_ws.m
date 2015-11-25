function controlfilename = createLCmodel_control_ws(metabname,l1,l2,l3)

controlfilename=[metabname '.CONTROL'];

% create .CONTROL file for LCModel
disp(['Creating file ' metabname]); disp(' ')

fileid=fopen(controlfilename,'w');
fprintf(fileid,' $LCMODL\n');
fprintf(fileid,[' TITLE=''DYSTONIE''\n']);
fprintf(fileid,[' OWNER=''CENIR''\n']);
fprintf(fileid,[' PGNORM=''A4''\n']);
fprintf(fileid,[' FILBAS=''/home/romain/data/spectro/PROTO_SPECTRO_DYST/LCmodel/Basis_set/MEGA2.BASIS''\n']);
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
 
%%%%%%%for ws (water scaling)
fprintf(fileid,' DOWS=T\n');
%fprintf(fileid,' WSMET=GABA\n');
fprintf(fileid,' WSMET=NAA\n');
%fprintf(fileid,' WSPPM=3.7\n');
fprintf(fileid,' WSPPM=2.65\n');
fprintf(fileid,[' FILH2O=''' metabname  '_ref.H2O''\n']);

fprintf(fileid,' NEACH=31\n');
%fprintf(fileid,' NUSE1=4\n');
%fprintf(fileid,' CHUSE1(1)=''GABA'',''NAA'',''GLU'',''OCC_MM''\n');
fprintf(fileid,' NUSE1=3\n');
fprintf(fileid,' CHUSE1(1)=''GABA'',''NAA'',''GLU''\n');

fprintf(fileid,[' DEGZER= 0 \n']);
fprintf(fileid,' SDDEGZ=20.\n');
fprintf(fileid,[' DEGPPM=0\n']);
fprintf(fileid,' SDDEGP=0.0\n');

fprintf(fileid,' NSIMUL=0\n');

%fprintf(fileid,' SHIFMN=-0.2,-0.1\n');
%fprintf(fileid,' SHIFMX=0.3,0.3\n');

fprintf(fileid,' FWHMBA=0.0050\n');

%GABA std 20 -> 19 (without)
fprintf(fileid,' RFWHM=2.5\n');

%no information in the user manual (Hidden Control Parameters)
fprintf(fileid,' DKNTMN=0.5\n');


fprintf(fileid,' PPMST=4.5\n');
fprintf(fileid,' PPMEND=0.5\n');

fprintf(fileid,[l1,'\n']);
fprintf(fileid,[l2,'\n']);
fprintf(fileid,[l3,'\n']);
fprintf(fileid,' $END\n');

fclose(fileid);

ff=[metabname,'_ref.H2O'];
if ~exist(ff)
  error('file %s does not exist',ff)
end

