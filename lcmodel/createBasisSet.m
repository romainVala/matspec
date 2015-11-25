function  createBasisSet()

par.BasisSetDir = '/home/romain/data/spectro/Basis_set/Gosia/new_MEGA/basis_MEGA_edit_CENIR_SS/';
par.name_basis = 'basis_SS_inv';
par.element_basis_name={'NAA','GABA','GLU','MM'};

par.element_basis_name={'NAA','GABA','GLU','GLN','MM'};
par.element_basis_filename={'NAA','GABA','Glu','Gln','MM'};
guess_from_raw = 1;


ff = fullfile (par.BasisSetDir,[par.name_basis,'.IN']);
fileid=fopen(ff,'w');

if guess_from_raw

  %first file set the main 
  dd = dir(fullfile(par.BasisSetDir,['*',par.element_basis_filename{1},'*.RAW']));
  fraw = fullfile(par.BasisSetDir,dd.name);

  [pathstr,filename,ext] = fileparts(fraw);
  fid = fopen(fullfile(pathstr,[filename,'.PLOTIN']));

  l=fgetl(fid);
  l1=fgetl(fid);  %HZPPM
  l2=fgetl(fid);  %NUNFIL
  l3=fgetl(fid);  %DELTAT
  fclose(fid);

  fprintf(fileid,' $SEQPAR\n');
  fprintf(fileid,[' SEQ=''%s''\n'],par.name_basis);
  fprintf(fileid,' $END\n\n');

  fprintf(fileid,' $NMALL\n');
  fprintf(fileid,'%s\n',l1);
  fprintf(fileid,'%s\n',l2);
  fprintf(fileid,'%s\n',l3);
  
%  fprintf(fileid,[' HZPPPM=' num2str(sfrq) '\n']);
%  fprintf(fileid,[' NUNFIL=' num2str(nbpoints) '\n']);
%  fprintf(fileid,[' DELTAT=' num2str(1/sw_hz) '\n']);
  fprintf(fileid,[' FILBAS=''' par.name_basis '.BASIS''\n']);
  fprintf(fileid,[' FILPS=''' par.name_basis '.PS''\n']);
  fprintf(fileid,' AUTOSC=.FALSE.\n');
  fprintf(fileid,' AUTOPH=.FALSE.\n');
  fprintf(fileid,' PPMST=6\n');
  fprintf(fileid,' PPMEND=-0.5\n');
  fprintf(fileid,' $END\n\n');

  for nbf = 1:length(par.element_basis_name)

    dd = dir(fullfile(par.BasisSetDir,['*',par.element_basis_filename{nbf},'*.RAW']));
    if length(dd)~=1
      error('only one (.RAW) file must contain the word %s\n',par.element_basis_filename{nbf});
    end
    fraw = fullfile(par.BasisSetDir,dd.name);
    
    fprintf(fileid,' $NMEACH\n');
    fprintf(fileid,[' FILRAW=''%s''\n'],fraw);
    fprintf(fileid,[' METABO=''%s''\n'],par.element_basis_name{nbf});
    fprintf(fileid,' DEGZER=0.\n');
    fprintf(fileid,' DEGPPM=0.\n');
    fprintf(fileid,' CONC=1.\n');
    fprintf(fileid,' PPMAPP=0.1,-0.1\n');
    fprintf(fileid,' $END\n\n');
  end
  
else %not guess_from_raw so adapt it !

sfrq = 123.1058;
nbpoint = 2048;
sw_hz=1/0.0008334;

nbpoints=8192; % Varian np divided by 2
%nbpoints=2048; % Varian np divided by 2



fprintf(fileid,' $SEQPAR\n');
fprintf(fileid,[' SEQ=''%s''\n'],par.name_basis);
fprintf(fileid,' $END\n\n');

fprintf(fileid,' $NMALL\n');
fprintf(fileid,[' HZPPPM=' num2str(sfrq) '\n']);
fprintf(fileid,[' NUNFIL=' num2str(nbpoints) '\n']);
fprintf(fileid,[' DELTAT=' num2str(1/sw_hz) '\n']);
fprintf(fileid,[' FILBAS=''' par.name_basis '.BASIS''\n']);
fprintf(fileid,[' FILPS=''' par.name_basis '.PS''\n']);
fprintf(fileid,' AUTOSC=.FALSE.\n');
fprintf(fileid,' AUTOPH=.FALSE.\n');
fprintf(fileid,' PPMST=4\n');
fprintf(fileid,' PPMEND=-0.16\n');
fprintf(fileid,' $END\n\n');

fprintf(fileid,' $NMEACH\n');
fprintf(fileid,[' FILRAW=''20090709_ST001_Basis_GABA_bis_E1_mega_press_1_32x1.RAW''\n']);
fprintf(fileid,[' METABO=''GABA''\n']);
fprintf(fileid,' DEGZER=0.\n');
fprintf(fileid,' DEGPPM=0.\n');
fprintf(fileid,' CONC=1.\n');
fprintf(fileid,' PPMAPP=1.,-0.16\n');
fprintf(fileid,' $END\n\n');

fprintf(fileid,' $NMEACH\n');
fprintf(fileid,[' FILRAW=''20090709_ST001_Basis_NAA_bis_E1_mega_press_1_32x1.RAW''\n']);
fprintf(fileid,[' METABO=''NAA''\n']);
fprintf(fileid,' DEGZER=0\n');
fprintf(fileid,' DEGPPM=0.\n');
fprintf(fileid,' CONC=1.\n');
fprintf(fileid,' PPMAPP=1.,-0.16\n');
fprintf(fileid,' $END\n\n');

fprintf(fileid,' $NMEACH\n');
fprintf(fileid,[' FILRAW=''20090709_ST001_Basis_Glu_bis_E1_mega_press_1_32x1.RAW''\n']);
fprintf(fileid,[' METABO=''GLU''\n']);
fprintf(fileid,' DEGZER=0.\n');
fprintf(fileid,' DEGPPM=0.\n');
fprintf(fileid,' CONC=1.\n');
fprintf(fileid,' PPMAPP=1.,-0.16\n');
fprintf(fileid,' $END\n\n');

 fprintf(fileid,' $NMEACH\n');
 fprintf(fileid,[' FILRAW=''MM_11_sujets_ze.RAW''\n']);
 fprintf(fileid,[' METABO=''OCC_MM''\n']);
 fprintf(fileid,' DEGZER=0\n');
 fprintf(fileid,' DEGPPM=0.\n');
 fprintf(fileid,' CONC=1.\n');
 fprintf(fileid,' PPMAPP=0.5,-0.16\n');
 fprintf(fileid,' $END\n\n');

end

fclose(fileid);
