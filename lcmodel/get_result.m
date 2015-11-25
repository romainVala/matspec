function [conc]=get_result(dir_sel,waterref)

%for 3T data
RESONANCE_FREQ = 123.25;
%for 7T data
%RESONANCE_FREQ = 296.5917;

if ~exist('waterref')
    waterref=0;
end

if iscell(dir_sel{1}) %multi dir per subject
    for nb_mod=1:length(dir_sel{1});
        [pp model_name(nb_mod)] = get_parent_path(dir_sel{1}(nb_mod));
        for nbp=1:length(dir_sel)
            do{nb_mod}{nbp} = dir_sel{nbp}{nb_mod};
        end        
        c=get_result(do{nb_mod});
        for nbp = 1:length(c)
            c(nbp).model_name = model_name{nb_mod};
        end
        conc{nb_mod} = c;
    end
    return
end

root_dir=pwd;

if ~exist('dir_sel')
    dir_sel = spm_select(inf,'dir','select a dirs to get result from','',root_dir)
    dir_sel=cellstr(dir_sel);
end

for npool = 1:length(dir_sel)
    
    %F = get_files_recursif(dir_sel(npool,:),'.COORD');
    aa = get_subdir_regex_files(dir_sel{npool},'.*\.COORD');
    bb = get_subdir_regex_files(dir_sel{npool},'.*\.PRINT');
    F = cellstr(aa{1});
    Fp = cellstr(bb{1});
    
    if isempty(dir([dir_sel{npool},'*.RAW']) )
        preproc_subdir=1; %result are in a preproc subdir
else
preproc_subdir=0;
    end
    
    [p,f] = fileparts(dir_sel{npool});
    [p,f] = fileparts(p);
    if preproc_subdir, [p,f] = fileparts(p);end
    
    concpool.pool=f;
    
    for k = 1:length(F)
        
        result(k) = readcoord(F{k});
       
try 
        [met cormat] = readprint(Fp{k});
   catch
	fprintf('problem reading the correlation coeff\n');
	met={};
	cormat=[];
end    
        %find the watter ref
        if waterref
            
            %f=get_coresponding_water_ref(F{k});
            
            %      aa=addsufixtofilenames(F{k},'_ref');
            %      aa=change_file_extention(aa,'.H2O');
            %      if ~exist(aa)
            %	write_water_fid_to_lcRAW(f,aa)
            %      end
            
            wc = get_coresponding_water_content(F{k});
        end
        
        
        concpool.suj{k} = result(k).name;
        
        for kk=1:length(result(k).metabconc)
            nn = result(k).metabconc(kk).name;
            ind = findstr(nn,'+');
            if ~isempty(ind)
                if ind==1, nn(ind)='';      else   nn(ind) = '_';      end
            end
            
            ind = findstr(nn,'-');
            if ~isempty(ind)
                if ind==1, nn(ind)='';      else   nn(ind) = '_';      end
            end
            
            if strcmp(nn(1),'2')
                nn=['t',nn];
            end
            
            nnSD = ['SD',nn];
            
            if isfield(concpool,nn)
                ccc   = getfield(concpool,nn);
                cccSD = getfield(concpool,nnSD);
            else
                ccc = [];
                cccSD = [];
            end
            
            ccc(end+1)   = result(k).metabconc(kk).relconc;
            cccSD(end+1) = result(k).metabconc(kk).SD;
            concpool = setfield(concpool,nn,ccc);
            concpool = setfield(concpool,nnSD,cccSD);
            
        end
        
        %concpool.suj{k} = result(k).name;
        
        concpool.phase_cor(k) = result(k).phase_cor;
        concpool.phase1_cor(k) = result(k).phase1_cor;
        
        concpool.linewidth(k) = result(k).linewidth * RESONANCE_FREQ;
        
        concpool.SN(k) = result(k).SN;
        concpool.freq_shift(k) = result(k).data_shift;
        concpool.met = met;
        concpool.cormat{k} = cormat;
        
        
        if waterref
         %   concpool.suj_age{k} = f.patient_age;
         %   concpool.water_phase(k) = f.wat_phase;
         %   concpool.water_width(k) = f.water_width;
            %      concpool.water_width_no_cor(k) = f.water_width_no_cor;
            %      concpool.water_width_lana(k) = f.water_width_lana;
            %      concpool.integral_real_fit(k) = f.integral_real_fit ;
            %      concpool.integral_real_fit_all(k) = f.integral_real_fit_all ;
            %      concpool.integral_fid_abs(k) = f.integral_fid_abs ;
            %      concpool.integral_fid_cor_abs(k) = f.integral_fid_cor_abs ;
            %      concpool.integral_real(k) = f.integral_real;
            %      concpool.integral_real_all(k) = f.integral_real_all;
            
            %      concpool.integral_abs(k) = f.integral_abs;
            
        end
        if exist('wc')
            concpool.fgray(k)  = wc(2);
            concpool.fwhite(k) = wc(3);
            concpool.fcsf(k)   = wc(4);
        end
        
    end
    conc(npool) = concpool;
    
    clear concpool;
    
    if 1
        ff=fieldnames(conc);
        concpool=conc(1);
        for k=1:length(ff)
            concpool=setfield(concpool,ff{k},[]);
        end
    end
    
end

