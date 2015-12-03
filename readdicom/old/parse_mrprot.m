function mrprot = parse_mrprot(fp)
% parse mrprot (text) structure stored in an open file

mrprot = [];
done = 0;
while(done == 0)
    % read a line
    line = fgetl(fp);
    
    % strip any comments
    ctest = findstr(line, '#');
    if (ctest > 1)
        line = line(1:ctest-1);
    end
    
    if (line == -1)
        % reached eof
        done = -1;
    else
        if ( size(line,2) < 1 )
            % blank line -- skip
        elseif ( ~isletter(line) | ~isletter(line(1)) )  % note: leave as | (not scalar)
            % blank line or comment -- skip
        elseif (strfind(line,'__'))
            %rrr skipe new field prisma
        else
            % first, take the variable name -- everything before the '='
            [varname, stub] = strtok(line, '=');

            % break it down into levels delimited by '.'
            varnamearr = textscan(varname, '%s', 'delimiter', '.');
            varnamearr = varnamearr{:}';
            lvls = size(varnamearr,2);
            
            index = zeros(lvls,2);
            for x=1:lvls
                % look for brackets indicating array
                workstr = varnamearr{x};
                btest1 = findstr(workstr, '[');
                btest2 = findstr(workstr, '][');
  
                if (btest2 > 0)         % found a 2D array
                    btest1 = btest1(1);
                    index(x,1) = str2double(getBracketString(workstr));
                    index(x,2) = str2double(getBracketString(workstr(btest2+1:end)));
                    varnamearr{x} = [workstr(1:btest1-1) blanks(size(workstr,2) - btest1 + 1)];
                elseif (btest1 > 0)     % found a 1D array
                    index(x,1) = str2double(getBracketString(workstr));
                    index(x,2) = 0;
                    varnamearr{x} = [workstr(1:btest1-1) blanks(size(workstr,2) - btest1 + 1)];
                else
                    index(x,1:2) = [0 0];
                end
            end
            
            fields = {{1}};
            for x=1:lvls
                varname = deblank(varnamearr{x});
                
                if (strncmp(varname, 'm_', 2)) % fix VAxx YAPS naming
                    varname = varname(3:end);
                    old_version = true;
                    
                    %fix VAxx array naming, since they are equivalent to
                    %VBxx non-arrayed parameters
                    if ( (strncmp(varname, 'al', 2)) || (strncmp(varname, 'afl', 2)) )
                        test_varname = varname(2:end);
                    else
                        test_varname = varname;
                    end
                else
                    old_version = false;
                    test_varname = varname;
                end
                
                idx1 = index(x,1) + 1;
                idx2 = index(x,2) + 1;
                
                if (x < lvls)
                    fields = {fields{:}, varname, {idx1, idx2}};
                else
                    % last one
                    stub = getYaPSBracketString(getEqualString(stub));
                    
                    if ( (strncmp(test_varname, 'afl', 3)) || ... % array of floats (numeric)
                         (strncmp(test_varname, 'ac', 2))  || ... % array of signed chars (?) (numeric)
                         (strncmp(test_varname, 'ad', 2))  || ... % array of doubles (numeric)
                         (strncmp(test_varname, 'al', 2))  || ... % array of longs (numeric)
                         (strncmp(test_varname, 'ax', 2))  || ... % array of complex values (numeric)
                         (strncmp(test_varname, 'an', 2)) )      % array of signed value (long?) (numeric)
                        fields = {fields{:}, varname, {idx1, idx2}, str2num(stub)};  % (use str2num here for arrays)

                    elseif ( (strncmp(test_varname, 'aui', 3)) || ... % array of unsigned int (hex)
                             (strncmp(test_varname, 'aul', 3)) )     % array of unsigned long (hex)
                        fields = {fields{:}, varname, {idx1, idx2}, getHexVal(stub)};

                    elseif (strncmp(test_varname, 'at', 2)) % array of text strings
                        fields = {fields{:}, varname, {idx1, idx2}, cellstr(getQuotString(stub))};

                    elseif ( (strncmp(test_varname, 'fl', 2)) || ... % float (numeric)
                             (strncmp(test_varname, 'l', 1))  || ... % long value (signed) (numeric)
                             (strncmp(test_varname, 'd', 1))  || ... % double value (numeric)
                             (strncmp(test_varname, 'n', 1))  || ... % signed value (long?) (numeric)
                             (strncmp(test_varname, 'b', 1))  || ... % bool (numeric)
                             (strncmp(test_varname, 'e', 1))  || ... % enum (long?) (numeric)
                             (strncmp(test_varname, 'i', 1)) )      % int (numeric)
                        fields = {fields{:}, varname, str2double(stub)};

                    elseif ( (strncmp(test_varname, 'ush', 3)) || ... % unsigned short (hex)
                             (strncmp(test_varname, 'ul', 2))  || ... % unsigned long (hex)
                             (strncmp(test_varname, 'ui', 2))  || ... % unsigned int (hex)
                             (strncmp(test_varname, 'un', 2))  || ... % unsigned value (hex)
                             (strncmp(test_varname, 'uc', 2)) )      % unsigned char (hex)
                        fields = {fields{:}, varname, getHexVal(stub)};

                    elseif (strncmp(test_varname, 't', 1)) % text string
                        fields = {fields{:}, varname, getQuotString(stub)};

                    elseif ( (old_version) && (strcmp(test_varname, 'SecUserToken')) )
                        % don't know what this is
                        fields = {fields{:}, varname, stub};
                    elseif ( (strcmp(test_varname, 'WaitForUserStart')) )
                        % don't know what this is either (romain)
                        fields = {fields{:}, varname, stub};

                    else
                        
                      warning('parse_mrprot: unknown data type for %s!!',varname);
                    end
                end
            end

            mrprot = setfield(mrprot,fields{:});
        end
    end
end



%--------------------------------------------------------------------------

function stvar = getEqualString(text)
% strips leading whitespace and '=' character to find assignment string

stvar = text(findstr(text,'=')+1:end);
stvar = deblank(rot90(deblank(rot90(stvar,2)),-2));

%--------------------------------------------------------------------------

function stvar = getYaPSBracketString(text)
% extracts text string from YAPS output in meas.asc
% sometimes brackets [] are used (old syngo), sometimes not (new syngo)

a = strfind(text,'[');
b = strfind(text,']');

if ( isempty(a) || isempty(b) )
    % no brackets found (>=VB12T)
    a = strfind(text,'=');
    if (a > 0) % found = sign
        stvar = deblank(rot90(deblank(rot90(text(a+1:end),2)),-2));
    else
        stvar = text;
    end
elseif ((b - a) < 2)
    stvar = '';
else
    stvar = text(a+1:b-1);
end


%--------------------------------------------------------------------------

function stvar = getBracketString(text)
% extracts text string from within [] brackets

a = strfind(text,'[');
b = strfind(text,']');

if ( isempty(a) || isempty(b) )
    stvar = '';
elseif ((b - a) < 2)
    stvar = '';
else
    stvar = text(a+1:b-1);
end

%--------------------------------------------------------------------------

function stvar = getQuotString(text)
% extracts string between double quotes, e.g. "string"
%  also works with double-double quotes, e.g. ""string""

idx = findstr(text,'"');

if ( (length(idx) == 4) && (idx(1)+1 == idx(2)) && (idx(3)+1 == idx(4)) ) % double-double quotes
    stvar = text(idx(2)+1:idx(3)-1);
elseif (length(idx) >= 2) % double quotes, or ??? just extract between first and last quotes
    stvar = text(idx(1)+1:idx(end)-1);
else % malformed?
    stvar = text;
end

%--------------------------------------------------------------------------

function hval = getHexVal(text)
% gets C++ style hexadecimal value from a text string
%  (assumes nothing follows the hex string)

tmp = text(findstr(text,'0x')+2:end);
hval = hex2dec(tmp);

%--------------------------------------------------------------------------

% function mrprot = assignMrProtVal(mrprot, varnamestruct, index, val)
% % this function assigns values to the mrprot structure based on pre-parsed
% % structure names and array indices
% 
% if ~iscellstr(varnamestruct)
%     error('assignMrProtVal: ERROR: varnamebase must be cell string');
% end
