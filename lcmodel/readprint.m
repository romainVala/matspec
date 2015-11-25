% read .PRINT file and plot data
% valabregue 02/2012

function [met cormat] = readprint(filename)
%filename = '/home/romain/data/spectro/hipo/repro_study/lcmodel/9session_Naj_last_mean/BA_MM/REPRO_HIPO_01_mean.PRINT';

[pathstr,fname,ext] = fileparts(filename);
lcmodelresults.name=fname;

% open .COORD file

fprintf('**** READING LCMODEL RESULTS IN .PRINT FILE *****\n\n');
fprintf(['Opening file ' filename '\n']);
fileid=fopen(filename);


% discard text until beginning of concentrations table (preceded by word 'Metab.')
l=fgetl(fileid);

while isempty(findstr('Correlation coefficients',l))
    l=fgetl(fileid);
end

l=fgetl(fileid);  %blank line
l=fgetl(fileid);  %name line

[met{1} tt]=strtok(l);
k=2;
while ~isempty(deblank(tt))
    [met{k} tt] = strtok(tt);
    k=k+1;
end
first_line_length = length(met);

l=fgetl(fileid);
if isempty(deblank(l(1:10)))  %one more named line
    numline=2;
    [met{k} tt]=strtok(l);
    while ~isempty(deblank(tt))
        k=k+1;
        [met{k} tt] = strtok(tt);
    end
else
    numline=1;
end

l=fgetl(fileid);

if isempty(deblank(l(1:10)))  %one more named line
    k=k+1;
    numline=3;
    [met{k} tt]=strtok(l);
    while ~isempty(deblank(tt))
        k=k+1;
        [met{k} tt] = strtok(tt);
    end
end

cormat = zeros(length(met)+1);

if numline == 1
    %cormat = zeros(length(met));
    for k = 2 : first_line_length+1
        
        [m tt]=strtok(l);
        met{k} = nettoie_dir(m);
        kj=1;
        while ~isempty(deblank(tt))
            [mm tt] = strtok(tt);
            cormat(k,kj) = str2num(mm);
            kj=kj+1;
        end
        
        l = fgetl(fileid);
        
    end
    
else
    
    for k = 2 : first_line_length
                
        [m tt]=strtok(l);
        met{k} = nettoie_dir(m);
        kj=1;
        while ~isempty(deblank(tt))
            [mm tt] = strtok(tt);
            cormat(k,kj) = str2num(mm);
            kj=kj+1;
        end
        l = fgetl(fileid);
    end
    
    if numline == 2
        
        for k=first_line_length+1:length(met)+1
            l = fgetl(fileid);
            if isempty(l), continue; end
            
            [m tt]=strtok(l);
            met{k} = nettoie_dir(m);
            kj=1;
            
            while ~isempty(deblank(tt))
                [mm tt] = strtok(tt);
                cormat(k,kj) = str2num(mm);
                kj=kj+1;
            end
            
            l = fgetl(fileid);   %read the number on the second line
            [mm tt] = strtok(l);
            if ~isempty(mm)
                cormat(k,kj) = str2num(mm);
                kj=kj+1;
            end
            
            while ~isempty(deblank(tt))
                [mm tt] = strtok(tt);
                cormat(k,kj) = str2num(mm);
                kj=kj+1;
            end
            
        end
        
    else %3ligne
        for k=first_line_length+1:length(met)+1
            l = fgetl(fileid);
            [m tt]=strtok(l);
            met{k} = nettoie_dir(m);
            kj=1;
            
            while ~isempty(deblank(tt))
                [mm tt] = strtok(tt);
                cormat(k,kj) = str2num(mm);
                kj=kj+1;
            end
            
            l = fgetl(fileid);   %read the number on the second line
            [mm tt] = strtok(l);
            if ~isempty(mm)
                cormat(k,kj) = str2num(mm);
                kj=kj+1;
            end
            
            while ~isempty(deblank(tt))
                [mm tt] = strtok(tt);
                cormat(k,kj) = str2num(mm);
                kj=kj+1;
            end
            
            if k>first_line_length*2+1
                %read the Third line
                l = fgetl(fileid);   %read the number on the second line
                [mm tt] = strtok(l);
                if ~isempty(mm)
                    cormat(k,kj) = str2num(mm);
                    kj=kj+1;
                end
                
                while ~isempty(deblank(tt))
                    [mm tt] = strtok(tt);
                    cormat(k,kj) = str2num(mm);
                    kj=kj+1;
                end
                

            end
            
        end
        
    end
end
