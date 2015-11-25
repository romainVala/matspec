function do = r_movefile(d,new_dir,type)
%do = r_moverfile(d,new_dir,type)
%will move or copy or link files d in new_dir
%type can be  'copy' 'link' 'move'


if ~exist('type')
    type = 'copy';
end

if isstr(d)
    d = repmat({d},size(new_dir));
end

if isstr(new_dir)
    new_dir = repmat({new_dir},size(d));
end


if any(size(d)-size(new_dir))
    error('rrr \n the 2 cell input must have the same size\n')
end


[pp ff ] = get_parent_path(d);

for k=1:length(d)
    
    %  if ~exist(new_dir{k})
    %    mkdir(new_dir{k})
    %  end
    for kf=1:size(d{k},1)
        
        if exist(new_dir{k},'dir')
            do{k}(kf,:) = fullfile(new_dir{k},ff{k}(kf,:));
        else %(exist(new_dir{k},'file'))
            do{k}(kf,:) = new_dir{k};
        end
        
        
        switch type
            case 'copyn'
                if ~exist(do{k}(kf,:),'file')
                    %copyfile(d{k}(kf,:),new_dir{k});
                    cmd = sprintf('cp -fpr %s %s',d{k}(kf,:),new_dir{k});
                    unix(cmd);
                end
            case 'copy'
                
                %copyfile(d{k}(kf,:),new_dir{k});
                cmd = sprintf('cp -fpr %s %s',d{k}(kf,:),new_dir{k});
                unix(cmd);
                
            case 'linkn'
                
                if ~exist(do{k}(kf,:),'file')
                    
                    %copyfile(d{k}(kf,:),new_dir{k});
                    cmd = sprintf('ln -s %s %s',d{k}(kf,:),new_dir{k});
                    unix(cmd);
                end
            case 'link'
                %copyfile(d{k}(kf,:),new_dir{k});
                cmd = sprintf('ln -s %s %s',d{k}(kf,:),new_dir{k});
                unix(cmd);
            case 'move'
                movefile(deblank(d{k}(kf,:)),new_dir{k});
            otherwise
                error('rrr type %s unknown \n',type)
                
        end
        
    end
    
end
