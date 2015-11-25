function metadata = dicominfo(filename, varargin)
%DICOMINFO  Read metadata from DICOM message.
%   INFO = DICOMINFO(FILENAME) reads the metadata from the compliant
%   DICOM file specified in the string FILENAME.
%
%   INFO = DICOMINFO(FILENAME, 'dictionary', D) uses the data dictionary
%   file given in the string D to read the DICOM message.  The file in D
%   must be on the MATLAB search path.  The default value is dicom-dict.mat.
%
%   Example:
%
%     info = dicominfo('CT-MONO2-16-ankle.dcm');
%
%   See also DICOMDICT, DICOMREAD, DICOMWRITE, DICOMUID.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7.2.1 $  $Date: 2007/02/03 07:50:07 $


% Parse input arguments.
if (nargin < 1)
    eid = 'Images:dicominfo:tooFewInputs';
    error(eid, '%s', 'DICOMINFO requires at least one argument.')
    
end

% Set the dictionary.
args = parseInputs(filename, varargin{:});
dicomdict('set_current', args.Dictionary)

% Get the metadata.
try

    % Get details about the file to read.
    fileDetails = getFileDetails(filename);
  
    % Ensure the file is actually DICOM.
    if (~isdicom(fileDetails.name))
        error('Images:dicominfo:notDICOM', ...
              'The specified file is not in DICOM format.')
    end

    % Parse the DICOM file.
    attrs = dicomparse(fileDetails.name, ...
                       fileDetails.bytes, ...
                       getMachineEndian, ...
                       false, ...
                       dicomdict('get_current')); 

    % Process the raw attributes.
    metadata = processMetadata(attrs, true);
    metadata = dicom_set_imfinfo_values(metadata);
    metadata = setMoreImfinfoValues(metadata, fileDetails);
    metadata = processOverlays(metadata);
    
catch
    
    dicomdict('reset_current');
    rethrow(lasterror)
    
end

% Reset the dictionary.
dicomdict('reset_current');



function metadata = processMetadata(attrs, isTopLevel)

if (isempty(attrs))
    metadata = [];
    return
end

% Create a structure for the output and get the names of attributes.
[metadata, attrNames] = createMetadataStruct(attrs, isTopLevel);

% Fill the metadata structure, converting data along the way.
for currentAttr = 1:numel(attrNames)
  
    this = attrs(currentAttr);
    metadata.(attrNames{currentAttr}) = convertRawAttr(this);
    
end



function processedAttr = convertRawAttr(rawAttr)

% Information about whether to swap is contained in the attribute.
swap = needToSwap(rawAttr);

% Determine the correct output encoding.
if (isempty(rawAttr.VR))

    % Look up VR for implicit VR files.  Use 'UN' for unknown
    % tags.  (See PS 3.5 Sec. 6.2.2.)
    vr = findVRFromTag(rawAttr.Group, rawAttr.Element);
    if (~isempty(vr))

        % Some attributes have a conditional VR.  Pick the first.
        rawAttr.VR = vr;
        if (numel(rawAttr.VR) > 2)
          rawAttr.VR = rawAttr.VR(1:2);
        end
        
    else
        rawAttr.VR = 'UN';
    end
    
end

% Convert raw data.  (See PS 3.5 Sec. 6.2 for full VR details.)
switch (rawAttr.VR)
case  {'AE','AS','CS','DA','DT','LO','LT','SH','ST','TM','UI','UT'}

    processedAttr = deblankAndStripNulls(char(rawAttr.Data));
    
case {'AT'}
    
    % For historical reasons don't transpose AT.
    processedAttr = dicom_typecast(rawAttr.Data, 'uint16', swap);
    
case {'DS', 'IS'}
 
    processedAttr = sscanf(char(rawAttr.Data), '%f\\');
    
case 'FL'
     
    processedAttr = dicom_typecast(rawAttr.Data, 'single', swap)';
     
case 'FD'
     
    processedAttr = dicom_typecast(rawAttr.Data, 'double', swap)';
    
case 'OB'

    processedAttr = rawAttr.Data';
    
case {'OW', 'US'}
    
    processedAttr = dicom_typecast(rawAttr.Data, 'uint16', swap)';
    
case 'PN'
  
    processedAttr = parsePerson(deblankAndStripNulls(char(rawAttr.Data)));
    
case 'SL'
     
    processedAttr = dicom_typecast(rawAttr.Data, 'int32', swap)';
    
case 'SQ'

    processedAttr = parseSequence(rawAttr.Data);

case 'SS'
    
    processedAttr = dicom_typecast(rawAttr.Data, 'int16', swap)';
    
case 'UL'
        
    processedAttr = dicom_typecast(rawAttr.Data, 'uint32', swap)';
    
case 'UN'

    % It's possible that the attribute contains a private sequence
    % with implicit VR; in which case the Data field contains the
    % parsed sequence.
    if (isstruct(rawAttr.Data))
        processedAttr = parseSequence(rawAttr.Data);
    else
        processedAttr = rawAttr.Data';
    end

otherwise
    
    % PS 3.5-1999 Sec. 6.2 indicates that all unknown VRs can be
    % interpretted as UN.  
    processedAttr = rawAttr.Data';

end

% Change empty arrays to 0-by-0.
if isempty(processedAttr)
  processedAttr = reshape(processedAttr, [0 0]);
end
  


function byteOrder = getMachineEndian

persistent endian

if (~isempty(endian))
  byteOrder = endian;
  return
end

[c, m, endian] = computer;
byteOrder = endian;



function args = parseInputs(filename, varargin)

% Set default values
args.Dictionary = dicomdict('get');

% Parse arguments based on their number.
if (nargin > 1)
    
    paramStrings = {'dictionary'};
    
    % For each pair
    for k = 1:2:length(varargin)
        param = lower(varargin{k});
        
             
        if (~ischar(param))
            eid = 'Images:dicominfo:parameterNameNotString';
            msg = 'Parameter name must be a string';
            error(eid, '%s', msg);
        end
 
        idx = strmatch(param, paramStrings);
        
        if (isempty(idx))
            eid = 'Images:dicominfo:unrecognizedParameterName';
            msg = sprintf('Unrecognized parameter name "%s"', param);
            error(eid, '%s', msg);
        elseif (length(idx) > 1)
            eid = 'Images:dicominfo:ambiguousParameterName';
            msg = sprintf('Ambiguous parameter name "%s"', param);
            error(eid, '%s', msg);
        end
    
        switch (paramStrings{idx})
        case 'dictionary'

            if (k == length(varargin))
                eid = 'Images:dicominfo:missingDictionary';
                msg = 'No data dictionary specified.';
                error(eid, '%s', msg);
            else
                args.Dictionary = varargin{k + 1};
            end
 
        end  % switch
       
    end  % for
           
end



function personName = parsePerson(personString)
%PARSEPERSON  Get the various parts of a person name

% A description and examples of PN values is in PS 3.5-2000 Table 6.2-1.

pnParts = {'FamilyName'
           'GivenName'
           'MiddleName'
           'NamePrefix'
           'NameSuffix'};

if (isempty(personString))
    personName = makePerson(pnParts);
    return
end

people = tokenize(personString, '\\');  % Must quote '\' for calls to STRREAD.

personName = struct([]);

for p = 1:length(people)

    % ASCII, ideographic, and phonetic characters are separated by '='.
    components = tokenize(people{p}, '=');
    
    if (isempty(components))
        personName = makePerson(pnParts);
        return   
    end
        
    
    % Only use ASCII parts.
    
    if (~isempty(components{1}))
        
        % Get the separate parts of the person's name from the component.
        componentParts = tokenize(components{1}, '^');

        for q = 1:length(componentParts)
            
            personName(p).(pnParts{q}) = componentParts{q};
            
        end
        
    else
        
        % Use full string as value if no ASCII is present.
        
        if (~isempty(components))
            personName(p).FamilyName = people{p};
        end
    
    end
    
end



function personStruct = makePerson(pnParts)
%MAKEPERSON  Make an empty struct containing the PN fields.

for p = 1:numel(pnParts)
    personStruct.(pnParts{p}) = '';
end



function processedStruct = parseSequence(attrs)

numItems = countItems(attrs);
itemNames = getItemNames(numItems);

% Initialize the structure to contain this structure.
structInitializer = cat(1, itemNames, cell(1, numItems));
processedStruct = struct(structInitializer{:});

% Process each item (but not delimiters).
item = 0;
for idx = 1:numel(attrs)
  
    this = attrs(idx);
    if (~isDelimiter(this))
        item = item + 1;
        processedStruct.(itemNames{item}) = processMetadata(this.Data, false);
    end
    
end



function header = getImfinfoFields

header = {'Filename',      ''
          'FileModDate',   ''
          'FileSize',      []
          'Format',        'DICOM'
          'FormatVersion', 3.0
          'Width',         []
          'Height',        []
          'BitDepth',      []
          'ColorType',     ''}';



function metadata = setMoreImfinfoValues(metadata, d)

metadata.Filename    = d.name;
metadata.FileModDate = d.date;
metadata.FileSize    = d.bytes;



function details = getFileDetails(filename)

% Get details about the file to read.
details = dir(filename);

% Get the actual name of the file.
if (isempty(details))

    % Look for the file with a different extension.
    file = dicom_create_file_struct;
    file.Location = 'Local';
    file.Messages = filename;
    file = dicom_get_msg(file);
  
    if (isempty(file.Messages))
      msg = sprintf('File "%s" not found.', filename);
      eid = 'Images:dicominfo:noFileOrMessagesFound';
      error(eid, '%s', msg)
    end

    filename = file.Messages{1};

    fid = fopen(filename);
    filename = fopen(fid);
    fclose(fid);
    
    details = dir(filename);
    details.name = filename;
    
else
  
    details.name = filename;
  
end



function [metadata, attrNames] = createMetadataStruct(attrs, isTopLevel)

% Get the attribute names.
totalAttrs = numel(attrs);
attrNames = cell(1, totalAttrs);

for currentAttr = 1:totalAttrs
    attrNames{currentAttr} = ...
        dicomlookup_actions(attrs(currentAttr).Group, ...
                            attrs(currentAttr).Element);

    % Empty attributes indicate that a public/retired attribute was
    % not found in the data dictionary.  This used to be an error
    % condition, but is easily resolved by providing a special
    % attribute name.
    if (isempty(attrNames{currentAttr}))
        attrNames{currentAttr} = sprintf('Unknown_%04X_%04X', ...
                                         attrs(currentAttr).Group, ...
                                         attrs(currentAttr).Element);
    end
end

% Remove duplicate attribute names.  Keep the last appearance of the attribute.
[tmp, reorderIdx] = unique(attrNames);
if (numel(tmp) ~= totalAttrs)
    warning('Images:dicominfo:attrWithSameName', '%s\n%s', ...
            'This DICOM file contains multiple values with the same name.', ...
            'The last appearance is kept.')
end

uniqueAttrNames = attrNames(sort(reorderIdx));
uniqueTotalAttrs = numel(uniqueAttrNames);

% Create a metadata structure to hold the parsed attributes.  Use a
% cell array initializer, which has a populated section for IMFINFO
% data and an unitialized section for the attributes from the DICOM
% file.
if (isTopLevel)
    structInitializer = cat(2, getImfinfoFields(), ...
                            cat(1, uniqueAttrNames, cell(1, uniqueTotalAttrs)));
else
    structInitializer = cat(1, uniqueAttrNames, cell(1, uniqueTotalAttrs));
end

metadata = struct(structInitializer{:});



function str = deblankAndStripNulls(str)
%DEBLANKANDDENULL  Deblank a string, treating char(0) as a blank.

if (isempty(str))
    return
end

while (~isempty(str) && (str(end) == 0))
    str(end) = '';
end

str = deblank(str);



function vr = findVRFromTag(group, element)

% Look up the attribute.
attr = dicomlookup_helper(group, element, dicomdict('get_current'));

% Get the vr.
if (~isempty(attr))
  
    vr = attr.VR;
    
else

    % Private creator attributes should be treated as CS.
    if ((rem(group, 2) == 1) && (element == 0))
        vr = 'UL';
    elseif ((rem(group, 2) == 1) && (element < 256))
        vr = 'CS';
    else
        vr = 'UN';
    end
    
end



function out = processOverlays(in)

out = in;

% Look for overlays.
allFields = fieldnames(in);
idx = strmatch('OverlayData', allFields);

if (isempty(idx))
    return
end

% Convert each overlay data attribute.
for p = 1:numel(idx)

    olName = allFields{idx(p)};
    
    % The overlay fields can be present but empty.
    if (isempty(in.(olName)))
        continue;
    end

    % Which repeating group is this?
    [group, element] = dicomlookup_actions(olName);

    % Get relevant details.  All overlays are in groups 6000 - 60FE.
    overlay.Rows    = double(in.(dicomlookup_actions(group, '0010')));
    overlay.Columns = double(in.(dicomlookup_actions(group, '0011')));
    
    sppTag = dicomlookup_actions(group, '0012');
    if (isfield(in, sppTag))
        overlay.SamplesPerPixel = double(in.(sppTag));
    else
        overlay.SamplesPerPixel = 1;
    end
    
    bitsTag = dicomlookup_actions(group, '0100');
    if (isfield(in, bitsTag))
        overlay.BitsAllocated = double(in.(bitsTag));
    else
        overlay.BitsAllocated = 1;
    end
    
    numTag = dicomlookup_actions(group, '0015');
    if (isfield(in, numTag))
        overlay.NumberOfFrames = double(in.(numTag));
    else
        overlay.NumberOfFrames = 1;
    end
    
    % We could potential support more overlays later.
    if ((overlay.BitsAllocated > 1) || (overlay.SamplesPerPixel > 1))
      
        warning('Images:dicominfo:unsupportedOverlay', ...
                'Skipping overlay (%04X,%04X) with more than 1 bit/pixel.', ...
                group, element);
        continue;
        
    end

    % Process the overlay.
    for frame = 1:(overlay.NumberOfFrames)

        overlayData = tobits(in.(olName));
        numSamples = overlay.Columns * overlay.Rows * overlay.NumberOfFrames;
        out.(olName) = permute(reshape(overlayData(1:numSamples), ...
                                       overlay.Columns, ...
                                       overlay.Rows, ...
                                       overlay.NumberOfFrames), ...
                               [2 1 3]);
        
    end
    
end



function itemNames = getItemNames(numberOfItems)

% Create a cell array of item names, which can be quickly used.
persistent namesCell
if (isempty(namesCell))
    namesCell = generateItemNames(50);
end

% If the number of cached names is too small, expand it and recache.
if (numberOfItems > numel(namesCell))
    namesCell = generateItemNames(numberOfItems);
end

% Return the first n item names.
itemNames = namesCell(1:numberOfItems);



function namesCell = generateItemNames(numberOfItems)

namesCell = cell(1, numberOfItems);
for idx = 1:numberOfItems
    namesCell{idx} = sprintf('Item_%d', idx);
end



function tf = needToSwap(currentAttr)

switch (getMachineEndian)
case 'L'
    if (currentAttr.IsLittleEndian)
        tf = false;
    else
        tf = true;
    end
    
case 'B'
    if (currentAttr.IsLittleEndian)
        tf = true;
    else
        tf = false;
    end
  
otherwise
    error('Images:dicominfo:unknownEndian', ...
          'Unknown machine endian type: "%s".', getMachineEndian)

end
    


function tf = isDelimiter(attr)

% True if (FFFE,E00D) or (FFFE,E0DD).
tf = (attr.Group == 65534) && ...
     ((attr.Element == 57357) || (attr.Element == 57565));



function count = countItems(attrs)

if (isempty(attrs))
    count = 0;
else
    % Find the items (FFFE,E000) in the array of attributes (all of
    % which are item tags or delimiters; no normal attributes
    % appear in attrs here). 
    idx = find(([attrs(:).Group] == 65534) & ...
               ([attrs(:).Element] == 57344));
    count = numel(idx);
end
