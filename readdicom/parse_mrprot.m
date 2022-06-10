function mrprot = parse_mrprot(arr)
% parse mrprot (text) structure
%   E. Auerbach, CMRR, Univ. of Minnesota, 2022
%    some changes by Steven Baete, NYU LMC CBI, 2013 (SB)

version = '2022.04.01';

fprintf('   ** parse_mrprot version %s started (%d bytes input)\n', version, numel(arr));

tstart = tic;

% isolate the meas.asc portion only (strip the meas.evp part if present)
if (size(arr,1) > 1), arr = arr'; end
spos = strfind(arr,'### ASCCONV BEGIN ');
epos = strfind(arr,'### ASCCONV END ###');
if (~isempty(spos) && ~isempty(epos))
    arr = arr(spos:epos-1);
end

% mgetl returns a cell array where each cell is a line of text
[lines, numlines] = mgetl(arr);

mrprot = [];
for curline=1:numlines
    % work on one line at a time
    line = lines{curline};
    
    % strip any comments
    ctest = strfind(line, '#');
    if (ctest > 1)
        line = line(1:ctest-1);
    end
    
    if ( size(line,2) < 1 )
        % blank line -- skip
    elseif ( ~isletter(line) | ~isletter(line(1)) )  %#ok<OR2> % note: leave as | (not scalar)
        % blank line or comment -- skip
    else
        skip_this = false;
        
        % first, take the variable name -- everything before the '='
        [varname, stub] = strtok(line, '=');
        
        % sDiffusion.sFreeDiffusionData.sComment.NNN is an oddball case introduced in
        % since VE11 or so; convert to []
        if (my_strncmp(varname, 'sDiffusion.sFreeDiffusionData.sComment.'))
            varname = [strtrim(varname) ']'];
            varname(39) = '[';
        end
        
        % break it down into levels delimited by '.'
        varnamearr = textscan(varname, '%s', 'delimiter', '.');
        varnamearr = varnamearr{:}';
        lvls = size(varnamearr,2);
        
        index = zeros(lvls,2);
        for x=1:lvls
            % look for brackets indicating array
            workstr = strtrim(varnamearr{x});

            btest1 = strfind(workstr, '[');
            btest2 = strfind(workstr, '][');
            
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
            varname = make_safe_fieldname(varnamearr{x});
            
            if (my_strncmp(varname, 'x__attribute__')) % new for VD11 (note: after VD13 mod, make_safe_fieldname() prepends 'x')
                % skip it
                skip_this = true;
                break;
            end
            
            if (my_strncmp(varname, 'm_')) % fix VAxx YAPS naming
                varname = varname(3:end);
                old_version = true;
                
                %fix VAxx array naming, since they are equivalent to
                %VBxx non-arrayed parameters
                if ( (my_strncmp(varname, 'al')) || (my_strncmp(varname, 'afl')) )
                    test_varname = varname(2:end);
                else
                    test_varname = varname;
                end
            else
                old_version = false;
                test_varname = varname;
            end
            
            % these changed in VD11 for some reason; rename for backward compatibility
            if (my_strncmp(varname, 'sWipMemBlock'))
                varname = 'sWiPMemBlock';
            end
            
            idx1 = index(x,1) + 1;
            idx2 = index(x,2) + 1;
            
            if (x < lvls)
                fields = {fields{:}, varname, {idx1, idx2}};
            else
                % last one
                stub = getYaPSBracketString(getEqualString(stub));
                
                if (     (my_strncmp(test_varname, 'afl'))                          || ... % array of floats (numeric)
                         (my_strncmp(test_varname, 'ac'))                           || ... % array of signed chars (?) (numeric)
                         (my_strncmp(test_varname, 'ad'))                           || ... % array of doubles (numeric)
                         (my_strncmp(test_varname, 'al'))                           || ... % array of longs (numeric)
                         (my_strncmp(test_varname, 'ax'))                           || ... % array of complex values (numeric)
                         (my_strncmp(test_varname, 'MaxOnlineTxAmpl'))              || ... % array of floats
                         (my_strncmp(test_varname, 'MaxOfflineTxAmpl'))             || ... % array of floats
                         (my_strncmp(test_varname, 'IdPart'))                       || ... % array of bytes (?)
                         (my_strncmp(test_varname, 'an')) )                                % array of signed value (long?) (numeric)
                    fields = {fields{:}, varname, {idx1, idx2}, str2num(stub)};  %#ok<*CCAT,ST2NM> % (use str2num here for arrays)
                    
                elseif ( (my_strncmp(test_varname, 'aui'))                          || ... % array of unsigned int (hex)
                         (my_strncmp(test_varname, 'aul')) )                               % array of unsigned long (hex)
                    fields = {fields{:}, varname, {idx1, idx2}, getHexVal(stub)};
                    
                elseif ( (my_strncmp(test_varname, 'sComment')) )                          % array of chars (hex)
                    fields = {fields{:}, varname, {idx2, idx1}, char(getHexVal(stub))};
                    
                elseif   (my_strncmp(test_varname, 'at'))                                  % array of text strings
                    fields = {fields{:}, varname, {idx1, idx2}, cellstr(getQuotString(stub))};
                    
                elseif ( (my_strncmp(test_varname, 'fl'))                           || ... % float (numeric)
                         (my_strncmp(test_varname, 'l'))                            || ... % long value (signed) (numeric)
                         (my_strncmp(test_varname, 'd'))                            || ... % double value (numeric)
                         (my_strncmp(test_varname, 'n'))                            || ... % signed value (long?) (numeric)
                         (my_strncmp(test_varname, 'e'))                            || ... % enum (long?) (numeric)
                         (my_strncmp(test_varname, 'WorstCase'))                    || ... % float
                         (my_strncmp(test_varname, 'Nucleus'))                      || ... % float
                         (my_strncmp(test_varname, 'BCC'))                          || ... % int (numeric)
                         (my_strncmp(test_varname, 'WaitForUserStart'))             || ... % bool (numeric)
                         (my_strncmp(test_varname, 'DecouplingMatrixValid'))        || ... % bool (numeric)
                         (my_strncmp(test_varname, 'ScatterMatrixValid'))           || ... % bool (numeric)
                         (my_strncmp(test_varname, 'Laterality'))                   || ... % ??? (numeric)
                         (my_strncmp(test_varname, 'SarOptimization'))              || ... % ??? (numeric)
                         (my_strncmp(test_varname, 'Reordering3D'))                 || ... % ??? (numeric)
                         (my_strncmp(test_varname, 'DistributionAsymmetry'))        || ... % ??? (numeric)
                         (my_strncmp(test_varname, 'SpiralInterleaves'))            || ... % ??? (numeric)
                         (my_strncmp(test_varname, 'MrfMode'))                      || ... % ??? (numeric)
                         (my_strncmp(test_varname, 'MrfUserMode'))                  || ... % ??? (numeric)
                         (my_strncmp(test_varname, 'CameraBasedMotionCorrection'))  || ... % ??? (numeric)
                         (my_strncmp(test_varname, 'i')) )        % int (numeric)
                    fields = {fields{:}, varname, str2double(stub)};
                    
                elseif ( (my_strncmp(test_varname, 'ush'))                          || ... % unsigned short (hex)
                         (my_strncmp(test_varname, 'b'))                            || ... % bool (numeric, sometimes hex)
                         (my_strncmp(test_varname, 'ul'))                           || ... % unsigned long (hex)
                         (my_strncmp(test_varname, 'ui'))                           || ... % unsigned int (hex)
                         (my_strncmp(test_varname, 'un'))                           || ... % unsigned value (hex)
                         (my_strncmp(test_varname, 'UseDouble'))                    || ... % unsigned value (hex)
                         (my_strncmp(test_varname, 'Ignore'))                       || ... % unsigned value (hex)
                         (my_strncmp(test_varname, 'Size1'))                        || ... % unsigned value (hex)
                         (my_strncmp(test_varname, 'Size2'))                        || ... % unsigned value (hex)
                         (my_strncmp(test_varname, 'uc')) )                                % unsigned char (hex)
                    fields = {fields{:}, varname, getHexVal(stub)};
                    
                elseif ( (my_strncmp(test_varname, 't'))                            || ... % text string
                         (my_strncmp(test_varname, 's'))                            || ... % text string
                         (my_strncmp(test_varname, 'ZZMatrixVectorUUID')) )                % string (UUID)
                    fields = {fields{:}, varname, getQuotString(stub)};
                    
                elseif ( (old_version) && (strcmp(test_varname, 'SecUserToken')) )
                    % don't know what this is
                    fields = {fields{:}, varname, stub};
                    
                else
                    fprintf('parse_mrprot WARNING: unknown data type for %s (value = %s), discarding this line:\n%s\n',varname, stub, line);
                    skip_this = true;
                end
            end
        end
        
        if (~skip_this), mrprot = setfield(mrprot,fields{:}); end
    end
end

telapsed = toc(tstart);
fprintf('   ** parse_mrprot completed in %.3f s\n', telapsed);

%--------------------------------------------------------------------------

function count = my_strncmp(inStr, testStr)
% strncmp variant that tests the exact length of the test string

count = strncmp(inStr, testStr, length(testStr));

%--------------------------------------------------------------------------

function stvar = getEqualString(text)
% strips leading whitespace and '=' character to find assignment string

stvar = text(strfind(text,'=')+1:end);
stvar = strtrim(stvar);

%--------------------------------------------------------------------------

function stvar = getYaPSBracketString(text)
% extracts text string from YAPS output in meas.asc
% sometimes brackets [] are used (old syngo), sometimes not (new syngo)

a = strfind(text,'[');
b = strfind(text,']');

if ( ~isempty(a) ) %SB
    a = a(1);
end
if ( ~isempty(b) ) %SB
    b = b(1);
end

if ( isempty(a) || isempty(b) )
    % no brackets found (>=VB12T)
    a = strfind(text,'=');
    if (a > 0) % found = sign
        stvar = strtrim(text(a+1:end));
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

idx = strfind(text,'"');

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

if (my_contains(text,'0x'))
    tmp = text(strfind(text,'0x')+2:end);
    hval = hex2dec(tmp);
else
    % in VD11 the hex notation is inconsistent...sometimes these are dec
    hval = str2double(strtrim(text));
end

%--------------------------------------------------------------------------

function [lines, numlines] = mgetl(arr)
% mgetl: parse an entire text file into cell array of strings where each
% cell is one line. recognizes dos and unix file formats.

arr = char(arr);
if (size(arr,1) > size(arr,2)), arr = arr'; end
arr_len = length(arr);
lf = strfind(arr, char(10)); %#ok<CHARTEN>
numlines = length(lf);
if (lf(numlines) < arr_len)
    numlines = numlines + 1;
    lf(numlines) = arr_len;
end

lines = cell(numlines, 1);

stpos = 1;
for x=1:numlines
    if (x > 1), stpos = lf(x-1)+1; end
    endpos = lf(x) - 1;
    if (lf(x) > 1)
        if (arr(endpos) == char(13))
            endpos = endpos - 1; % strip cr and lf if both present
        end
    end
    if (endpos >= stpos), lines{x} = arr(stpos:endpos); end
end

%--------------------------------------------------------------------------

function stvar = make_safe_fieldname(tagStr)
% this function checks potential fieldnames and makes sure they are valid
% for MATLAB syntax, e.g. 2DInterpolation -> x2DInterpolation (must begin
% with a letter)

tagStr = strtrim(tagStr);

if (isempty(tagStr)) %SB
    tagStr = 'x';
end

if (isletter(tagStr(1)))
    stvar = tagStr;
else
    stvar = strcat('x', tagStr);
end

if my_contains(stvar, ';'), stvar = strrep(stvar, ';', '_'); end
if my_contains(stvar, '@'), stvar = strrep(stvar, '@', '_'); end % VD13
if my_contains(stvar, '-'), stvar = strrep(stvar, '-', '_'); end % (SB)

%--------------------------------------------------------------------------

function TF = my_contains(str,pattern)
% eja: version compatibility wrapper for contains function:
% TF = contains(str,pattern) returns 1 (true) if str contains the
% specified pattern, and returns 0 (false) otherwise.

if exist('contains','builtin')
    TF = contains(str,pattern);
else
    TF = ~isempty(strfind(str,pattern)); %#ok<STREMP>
end
