 jobs={};
par.wanted_number_of_file=1;
 for ns=1:length(sdir)
   spec = get_subdir_regex(sdir(ns),'_ref$');
   ana =  get_subdir_regex(sdir(ns),'t1mpr.*176$');
   anaf = char(get_subdir_regex_files(ana,'^sSL.*img$',par))

   for kk=1:length(spec)
     [p f] = fileparts(spec{kk});     [p f] = fileparts(p);
     if isempty(str2num(f(4)))
       nuser = str2num(f(2:3));
       numepi = sprintf('^S%.2d',nuser+1);
     else
       nuser = str2num(f(2:4));
       numepi = sprintf('^S%.3d.*LOCA$',nuser+1);
     end
     
     epi = get_subdir_regex(sdir(ns),numepi);
     if isempty(epi)
       error('qsdfkeyboard')
     end
     
     epif = char(get_subdir_regex_files(epi,'^mean.*img$',par));
     specf= char(get_subdir_regex_files(spec(kk),'nii$',par));
          
     jobs = do_coregister(epif,anaf,specf,'',jobs);

   end
 end

