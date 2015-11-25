suj=get_subdir_regex('/servernas/home/romain/data/spectro/PROTO_U731_CERVELET_TMS/dicom','PAS_S..$')
suj=get_subdir_regex('/servernas/home/romain/data/spectro/PROTO_U731_CERVELET_TMS/dicom','PAS_S.._E2$')

mc = get_subdir_regex(suj,'MC_L$');
mc = get_subdir_regex(suj,'BG_L$');
 
f = explore_spectro_data(char(mc));
f = concatenate_fid(f);

%par.figure = 1;
par.mean_line_broadening = 2; %8pour le MC mais 2 pour le BG 
par.stop_if_warning=1;
par.ref_metab='CRE_SMALL2' ;
fc  = processing_MEGA(f,par);

%pour BG E1    par.ref_metab='CRE_SMALL' ;   fc(2)  = processing_MEGA(f(2),par); 



mcw = get_subdir_regex(suj,'MC_L_ref$');
mcw = get_subdir_regex(suj,'BG_L_ref$');
fw = explore_spectro_data(char(mcw));
par.ref_metab = 'water';par.figure = 0;
par.mean_line_broadening = 1;
fwc= processing_MEGA(fw,par);
 
pp=write_fid_to_lcRAW;
pp.mega_type='diff_inv';    %pp.mega_type='first';
pp.root_dir = '/servernas/home/romain/data/spectro/PROTO_U731_CERVELET_TMS/lcmodel/MCL_E1';
pp.root_dir = '/servernas/home/romain/data/spectro/PROTO_U731_CERVELET_TMS/lcmodel/MCL_E2';

write_fid_to_lcRAW(fc,pp,fwc);

%get_result
d=get_subdir_regex('/servernas/images2/romain/data/spectro/PROTO_U731_CERVELET_TMS/lcmodel','E[12]','mega5');
c=get_result(d);
cw=get_water_content_pas(c)

cw=correct_water_content(cw,1,0)
cc=correct_result(cw);
ccs = remove_big_SD(cc,50);
ccs = correct_T2_metab(ccs);

de=get_subdir_regex(pwd,'NOE','E[12]','pres')
ce=get_result(de)
cec=correct_result(ce,cw);
cecs = remove_big_SD(cec,50);
cecs = correct_T2_metab(cecs);

write_res_to_csv(ccs,'totoM.csv')  

%write water_ref to anat
suj=get_subdir_regex('/servernas/home/romain/data/spectro/PROTO_U731_CERVELET_TMS/dicom','PAS')
ref=get_subdir_regex(suj,'ref$');
wr=explore_spectro_data(char(ref));
anatdir='/servernas/home/romain/data/spectro/PROTO_U731_CERVELET_TMS/anat'
wr=explore_spectro_data(char(ref));

%anat corege anat on first anat appy to other
adir='/servernas/home/romain/data/spectro/PROTO_U731_CERVELET_TMS/anat';
suj=get_subdir_regex(adir,'PAS_S..$')
[p sujname]=get_parent_path(suj) 

jobs={}

 for ns=1:length(suj)
   sdir =  get_subdir_regex(adir,sujname(ns))
%   t1 =  get_subdir_regex(adir,sujname(ns),'t1');
%   t2 = get_subdir_regex(adir,sujname(ns),'T2');

   for nbsess=1:length(sdir)
     d=dir(sdir{nbsess}); remo=[];
     for k=1:length(d)
       if ~d(k).isdir,       remo(end+1) =k ;     end
     end
     d(remo) = ''; d(1:2)='';
     
     nser=1;   
     if nbsess==1
       ref =   get_subdir_regex_files(fullfile(sdir{nbsess},d(1).name),'^s.*img$');   
       ref=char(ref); nser=2;
     end
     
     for nser=nser:length(d)
       if ~isempty(findstr(d(nser).name,'t1mpr')) || ~isempty(findstr(d(nser).name,'T2'))
	 break
       end
     end
     
     while nser<length(d)
       other={};
       src =get_subdir_regex_files( fullfile(sdir{nbsess},d(nser).name),'^s.*img$');     src=char(src);
       aa=nser+1;
       for nser=aa:length(d)
	 if ~isempty(findstr(d(nser).name,'t1mpr')) || ~isempty(findstr(d(nser).name,'T2'))
	   break
	 end
	 other(end+1) =get_subdir_regex_files( fullfile(sdir{nbsess},d(nser).name),{'img$','nii$'} );
       end
       jobs = do_coregister(src,ref,char(other),'',jobs);
     end
   end %nbsess
 
 end     
spm_jobman('run',jobs)

for ns=2:length(suj)
  %   sdir =  get_subdir_regex(adir,sujname(ns))
  t2 = get_subdir_regex(adir,sujname(ns),'T2');
  ft2=get_subdir_regex_files(t2,'^rs.*img',1);
  %change_vx_size([-1 1 1],char(ft2))
  oo=get_parent_path(ft2(1));
  exp='i1';
  for k=2:length(ft2)
    exp=[exp '+i' num2str(k)];
  end
  jo=job_image_calc(ft2,'meanT2.nii',exp,-4,4,oo{1})
  spm_jobman('run',jo)
end
   
%Move the files

cd /servernas/images2/romain/data/spectro/PROTO_U731_CERVELET_TMS/dicom

d=get_subdir_regex(pwd,'^2.*');
[pp,sn] = get_parent_path(d);


for k=1:length(sn)
  so{k} = sn{k}(12:end);
  if findstr('SPECTRO',so{k})
    so{k}(1:8)='';        
  end
  if findstr('Sujet',so{k}) 
    so{k}(6:9)='';
  end
  if findstr('SUJET',so{k})
    so{k}(6:9)='';
  end

  if findstr('PAS_S_',so{k})
    so{k}(6)='';
  end

end
char(so)

for k=1:length(sn)

  movefile(sn{k},so{k});
end



 d=get_subdir_regex('/home/romain/data/spectro/PROTO_U731_CERVELET_TMS/anat','^P.*');
 ana=get_subdir_regex(d,'t1')

 
 par=plot_lcmodel_result
par.save_dir='/servernas/images2/romain/data/spectro/PROTO_U731_CERVELET_TMS/lcmodel/fig';
par.ind_group=[2 3;5 6];
plot_loc
 plot_lcmodel_result(calle,{'Ins'},par)
