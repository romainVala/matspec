function mrprot = parse_mrprot(fp)
% parse mrprot (text) structure stored in an open file

mrprot = [];
done = 0;
while(done == 0)
    line = fgetl(fp);
    if (line == -1)
        % reached eof
        done = -1;
    else
        if ( ~isletter(line) | ~isletter(line(1)) )
            % blank line or comment -- skip
        else
            % predefine variables
            varnamearr = '';
            index = 0;
            index_ctr = 0;
            
            % first, take the variable name -- everything before the '='
            [varname, stub] = strtok(line, '=');

            % break it down into levels delimited by '.'
            while true
                [vartmp, varrem] = strtok(varname, '.');
                if isempty(vartmp)
                    break;
                else
                    index_ctr = index_ctr + 1;
                    varnamearr = strvcat(varnamearr, vartmp);
                    varname = varrem;
                end
            end
            
            for x=1:index_ctr
                % look for brackets indicating array
                workstr = varnamearr(x,:);
                btest1 = findstr(workstr, '[');
                btest2 = findstr(workstr, '][');
  
                if (btest2 > 0)         % found a 2D array
                    btest1 = btest1(1);
                    index(x,1) = str2num(getBracketString(workstr));
                    index(x,2) = str2num(getBracketString(workstr(btest2+1:end)));
                    varnamearr(x,:) = [workstr(1:btest1-1) blanks(size(workstr,2) - btest1 + 1)];
                elseif (btest1 > 0)     % found a 1D array
                    index(x,1) = str2num(getBracketString(workstr));
                    index(x,2) = 0;
                    varnamearr(x,:) = [workstr(1:btest1-1) blanks(size(workstr,2) - btest1 + 1)];
                else
                    index(x,1:2) = [0 0];
                end
            end
            
            fields = {{1}};
            for x=1:index_ctr
                varname = deblank(varnamearr(x,:));
                
                if (strncmp(varname, 'm_', 2)) % fix VAxx YAPS naming
                    varname = varname(3:end);
                end
                
                idx1 = index(x,1) + 1;
                idx2 = index(x,2) + 1;
                
                if (x < index_ctr)
                    fields = {fields{:}, varname, {idx1, idx2}};
                else
                    % last one
                    stub = getYaPSBracketString(getEqualString(stub));
                    
                    if ( (strncmp(varname, 'afl', 3)) | ... % array of floats (numeric)
                         (strncmp(varname, 'ac', 2))  | ... % array of signed chars (?) (numeric)
                         (strncmp(varname, 'ad', 2))  | ... % array of doubles (numeric)
                         (strncmp(varname, 'al', 2))  | ... % array of longs (numeric)
                         (strncmp(varname, 'an', 2)) )      % array of signed value (long?) (numeric)
                        fields = {fields{:}, varname, {idx1, idx2}, str2num(stub)};

                    elseif ( (strncmp(varname, 'aui', 3)) | ... % array of unsigned int (hex)
                             (strncmp(varname, 'aul', 3)) )     % array of unsigned long (hex)
                        fields = {fields{:}, varname, {idx1, idx2}, getHexVal(stub)};

                    elseif (strncmp(varname, 'at', 2)) % array of text strings
                        fields = {fields{:}, varname, {idx1, idx2}, cellstr(getQuotString(stub))};

                    elseif ( (strncmp(varname, 'fl', 2)) | ... % float (numeric)
                             (strncmp(varname, 'l', 1))  | ... % long value (signed) (numeric)
                             (strncmp(varname, 'd', 1))  | ... % double value (numeric)
                             (strncmp(varname, 'n', 1))  | ... % signed value (long?) (numeric)
                             (strncmp(varname, 'b', 1))  | ... % bool (numeric)
                             (strncmp(varname, 'i', 1)) )      % int (numeric)
                        fields = {fields{:}, varname, str2num(stub)};

                    elseif ( (strncmp(varname, 'ush', 3)) | ... % unsigned short (hex)
                             (strncmp(varname, 'ul', 2))  | ... % unsigned long (hex)
                             (strncmp(varname, 'un', 2))  | ... % unsigned value (hex)
                             (strncmp(varname, 'uc', 2)) )      % unsigned char (hex)
                        fields = {fields{:}, varname, getHexVal(stub)};

                    elseif (strncmp(varname, 't', 1)) % text string
                        fields = {fields{:}, varname, getQuotString(stub)};
                    
                    else
                        error('rdMeasFunc: unknown data type for %s!!',varname);
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

if ( isempty(a) | isempty(b) )
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

if ( isempty(a) | isempty(b) )
    stvar = '';
elseif ((b - a) < 2)
    stvar = '';
else
    stvar = text(a+1:b-1);
end

%--------------------------------------------------------------------------

function stvar = getQuotString(text)
% extracts string between double quotes

idx = findstr(text,'"');

if (idx > 0)
    stvar = text(idx+1:end);
    stvar = stvar(1:findstr(stvar,'"')-1);
else
    stvar = text;
end

%--------------------------------------------------------------------------

function hval = getHexVal(text)
% gets C++ style hexadecimal value from a text string
%  (assumes nothing follows the hex string)

tmp = text(findstr(text,'0x')+2:end);
hval = hex2dec(tmp);

%--------------------------------------------------------------------------

function mrprot = assignMrProtVal(mrprot, varnamestruct, index, val);
% this function assigns values to the mrprot structure based on pre-parsed
% structure names and array indices

if ~iscellstr(varnamestruct)
    error('assignMrProtVal: ERROR: varnamebase must be cell string');
end
