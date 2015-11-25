function ro = mean_raw()

  dir_sel = spm_select(inf,'dir','select a dirs to get result from','',pwd)
 % s=get_subdir_regex('PROTO_SPECTRO_DYST/LCmodel/Raw',{'pat','control','suj'});
 % dir_sel=get_subdir_regex(s,'basis_MEGA_edit_MM_Gln$');
 dir_sel=cellstr(dir_sel);
 
 
  
 pp.gessfile=2;
 
 
 for nd = 1:length(dir_sel)
 
   aa = get_subdir_regex_files(dir_sel{nd},'.*\.RAW');
   F = cellstr(aa{1});

   r=read_raw(char(F));
   
   aa = get_subdir_regex_files(dir_sel{nd},'.*\.H2O');
   F = cellstr(aa{1});
   rw = read_raw(char(F));
   
   rr = r(1); rrw = rw(1);
   
   for k=2:length(r)
     rr.fid = rr.fid+r(k).fid ;
     rrw.fid = rrw.fid+rw(k).fid ;
   end  
   
   rr.fid = rr.fid./length(r);
   rrw.fid = rrw.fid./length(r);
   
   rr.sujet_name = 'ze_mean';
   rr.water_ref = rrw;
   
   pp.root_dir = dir_sel{nd};
   write_fid_to_lcRAW(rr,pp)
   
   ro(nd) = rr
   
   clear rr rrw
   
 end
 
 