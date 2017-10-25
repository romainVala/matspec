function processing_LCmodel(type,preproc_dir,par)

if ~exist('par'),par ='';end

defpar.sge=0;
defpar.jobname='lcmodel';

par = complet_struct(par,defpar);


if ~exist('preproc_dir')
  preproc_dir = '';
end

%if ~isempty('type')
%  type='ws';
%  type='mega';
%end

root_dir=pwd;

sel = spm_select(inf,'dir','select a dir containing raw file in','',root_dir)

F = get_files_recursif(sel,'.RAW');
char(F)

for k = 1:length(F)
  
    [pathstr,filename,ext] = fileparts(F{k});
  
    fid = fopen(fullfile(pathstr,[filename,'.PLOTIN']));

    l=fgetl(fid);
    l1=fgetl(fid);
    l2=fgetl(fid);
    l3=fgetl(fid);
    fclose(fid);
    
    switch type
      case 'mega'
	P = createLCmodel_control_mega(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)
      case 'mega2HG'
	P = createLCmodel_control_mega_2HG(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)
      
      case 'press'
	P = createLCmodel_control_press(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)
      
      case 'press18'
	P = createLCmodel_control_press18(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)
	      
      case 'pressNAA'
	P = createLCmodel_control_pressNAA(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)
      
      case 'pressCRE'
	P = createLCmodel_control_pressCRE(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)
	      
      case 'svs'
	P = createLCmodel_control_svs(fullfile(pathstr,filename),l1,l2,l3)
      
      case 'laser'
	P = createLCmodel_control_laser(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)

        case 'laser55'
	P = createLCmodel_control_laser55(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)

      case 'laserIDH1'
	P = createLCmodel_control_laserIDH1(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)
      
      case 'laserT2'
	P = createLCmodel_control_laserT2(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)
      
      case 'laserCRE'
	P = createLCmodel_control_laserCRE(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)
      case 'laserNAA'
	P = createLCmodel_control_laserNAA(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)

      case 'laser7T'
	P = createLCmodel_control_laser7T(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)
      
      case 'sead'
	P = createLCmodel_control_sead(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)
      case '117press'
	P = createLCmodel_control_press117T(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)

      case '117laser'
	P = createLCmodel_control_laser117T(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)

        case 'steam'
    P = createLCmodel_control_steamT2(fullfile(pathstr,filename),l1,l2,l3,preproc_dir)
    
    end
    
if par.sge=0
    unix(['~/.lcmodel/bin/lcmodel < ' P])
else
   do_cmd_sge({['~/.lcmodel/bin/lcmodel < ' P]},par)
end

    
end
