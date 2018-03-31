function [o nofiledir yesfiledir] = get_subdir_regex_files(indir,reg_ex,p)
%cell vector of in directories
%reg_ex regular expression to select files
%p parameter, if  p.preproc_subdir is defined it will lock in this subdir
% and if not exist il will create it and copy the files in this subdir

if ~exist('p'), p=struct;end
if ~exist('indir'), indir={pwd};end
if ~exist('reg_ex'), reg_ex=('graphically');end

if ~isempty(indir)
    if iscell(indir)
        if iscell(indir{1})
            for nbsuj=1:length(indir)
                [ooo nonono]  = get_subdir_regex_files(indir{nbsuj},reg_ex,p);
                o{nbsuj} = char(ooo);
                nofiledir{nbsuj} = (nonono);
                [pp ff]=get_parent_path(ooo);
                yesfiledir{nbsuj} = (pp);
            end
            return
        end
    end
end

nofiledir={};
if ischar(reg_ex)
    if strcmp(reg_ex,'graphically')
        o={};
        for nb_dir=1:length(indir)
            dir_sel = spm_select(inf,'any','select files','',indir{nb_dir});
            dir_sel = cellstr(dir_sel);
            for kk=1:length(dir_sel)
                o{end+1} = dir_sel{kk};
            end
        end
        return
    end
end


if isnumeric(p)
    aa=p;clear p
    p.wanted_number_of_file = aa;
    p.verbose=0;
end

if ~isfield(p,'verbose'), p.verbose=1;end

if ~iscell(reg_ex), reg_ex={reg_ex};end
if ~iscell(indir), indir={indir};end

o={};

for nb_dir=1:length(indir)
    
    cur_dir = indir{nb_dir};
    
    please_copy_file=0;
    
    if isfield(p,'preproc_subdir')
        if exist(fullfile(cur_dir,p.preproc_subdir),'dir')
            cur_dir = fullfile(cur_dir,p.preproc_subdir);
        else
            please_copy_file=1;
        end
        
    end
    
    od = dir(cur_dir);
    od = od(3:end);
    
    found=0;to={};
    
    for nb_reg=1:length(reg_ex)
        for k=1:length(od)
            if ~od(k).isdir && ~isempty(regexp(od(k).name,reg_ex{nb_reg}, 'once' ))
                to{end+1} = fullfile(cur_dir,od(k).name);
                found=found+1;
            end
        end
    end
    to = char(to);
    
    if p.verbose
        fprintf('found %d files in %s for ',found,cur_dir)
        for kr=1:length(reg_ex)
            fprintf('%s\t',reg_ex{kr});
        end
        fprintf('\n');
    end
    
    if ~isempty(to)
        if please_copy_file
            if p.verbose, fprintf('   copy them to %s ...',p.preproc_subdir);  end
            to = char(change_file_path_to_preproc_dir(to,p));
            if p.verbose, fprintf('   ... done\n');  end
            
        end
        
        o{end+1} = to;
        
    else
        nofiledir{end+1} = cur_dir;
    end
    
    if isfield(p,'wanted_number_of_file')
        if size(to,1)~=p.wanted_number_of_file;
            fprintf('BAD number of file found')
            char(to)
            error('Change the regular expression : %s to get only %d files',char(reg_ex),p.wanted_number_of_file)
        end
        
    end
    
end

