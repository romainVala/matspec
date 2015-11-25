function [X, map, alpha, overlays] = dicomread(msgname, varargin)
%DICOMREAD  Read DICOM image.
%   X = DICOMREAD(FILENAME) reads the image data from the compliant
%   DICOM file FILENAME.  For single-frame grayscale images, X is
%   an M-by-N array.  For single-frame true-color images, X is an
%   M-by-N-by-3 array.  Multiframe images are always 4-D arrays.
%
%   X = DICOMREAD(INFO) reads the image data from the message
%   referenced in the DICOM metadata structure INFO.  The INFO
%   structure is produced by the DICOMINFO function.
%
%   [X, MAP] = DICOMREAD(...) returns the colormap MAP for the
%   image X.  If X is a grayscale or true-color image, MAP is
%   empty.
%
%   [X, MAP, ALPHA] = DICOMREAD(...) returns an alpha channel
%   matrix for X.  The values of ALPHA are 0 if the pixel is
%   opaque; otherwise they are row indices into MAP.  The RGB value
%   in MAP should be substituted for the value in X to use ALPHA.
%   ALPHA has the same height and width as X and is 4-D for a
%   multiframe image.
%
%   [X, MAP, ALPHA, OVERLAYS] = DICOMREAD(...) also returns any
%   overlays from the DICOM file.  Each overlay is a 1-bit black
%   and white image with the same height and width as X.  If
%   multiple overlays are present in the file, OVERLAYS is a 4-D
%   multiframe image.  If no overlays are in the file, OVERLAYS is
%   empty.
%
%   [...] = DICOMREAD(FILENAME, 'Frames', V) reads only the frames
%   in the vector V from the image.  V must be an integer scalar, a
%   vector of integers, or the string 'all'.  The default value is
%   'all'.
%
%   Examples
%   --------
%   Use DICOMREAD to retrieve the data array, X, and colormap
%   matrix, MAP, needed to create a montage.
%
%      [X, map] = dicomread('US-PAL-8-10x-echo.dcm');
%      montage(X, map);
%
%   Call DICOMREAD with the information retrieved from the DICOM file
%   using DICOMINFO.  Display the image with IMSHOW using its autoscaling
%   syntax.
%
%      info = dicominfo('CT-MONO2-16-ankle.dcm');
%      Y = dicomread(info);
%      figure, imshow(Y,[]);
%      imcontrast(gca);
%
%   Class support
%   -------------
%   X can be uint8, int8, uint16, or int16.  MAP will be double.  ALPHA
%   has the same size and type as X.  OVERLAYS is a logical array.
%
%   See also DICOMINFO, DICOMWRITE, DICOMDICT.

%   This function (along with DICOMINFO) implements the M-READ service.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2006/06/15 20:10:35 $


% Parse the input arguments.
if (nargin < 1)
  
  error('Images:dicomread:numInputs', ...
        'DICOMREAD requires at least one argument.');

end

  
if (hasObsoleteSyntax(varargin{:}))

  % Use the older, slower version.
  [X, map, alpha, overlays] = oldDicomread(msgname, varargin{:});

else
  
  % Use the newer, faster version.
  [X, map, alpha, overlays] = newDicomread(msgname, varargin{:});
  
end



function tf = hasObsoleteSyntax(varargin)

% A function has an obsolete syntax iff it references one of the
% obsolete parameter-value pairs.

if (nargin == 0)
  
  tf = false;
  return
  
end

% These are the obsolete syntaxes.
paramStrings = {'dictionary'
                'raw'
                'frames'};
    
% Look through the input parameters.
tf = false;
for k = 1:2:length(varargin)
  
  param = lower(varargin{k});
  
  if (~ischar(param))
    
    % Let noncharacter parameter names fall through to the old syntax.
    tf = true;
    return
    
  end
  
  idx = strmatch(param, paramStrings);
  
  if (isempty(idx))
    
    eid = 'Images:dicomread:unrecognizedParameterName';
    msg = sprintf('Unrecognized parameter name "%s"', param);
    error(eid, '%s', msg);
    
  elseif (length(idx) > 1)
    
    eid = 'Images:dicomread:ambiguousParameterName';
    msg = sprintf('Ambiguous parameter name "%s"', param);
    error(eid, '%s', msg);
    
  else

    % "Frames" is not supported by the fast DICOMREAD, but is not obsolete.
    if (~isequal(paramStrings{idx(1)}, 'frames'))
      
      warning('Images:dicomread:obsoleteSyntax', ...
              'Parameter ''%s'' is obsolete.  Using a slower version of DICOMREAD.', ...
              paramStrings{idx(1)});
    
    end
      
    tf = true;
    return
    
  end
  
end



function [X, map, alpha, overlays] = newDicomread(msgname)

% Get the filename.
if (isstruct(msgname))

  filename = msgname.Filename;
  
elseif (~ischar(msgname))

  error('Images:dicomread:badMessage', ...
        'The first input argument must be a filename or DICOM info struct.');

else
  
  filename = msgname;
  
end

% Get details about the file to read.
d = dir(filename);

if (isempty(d))

  fid = fopen(filename);

  if (fid < 0)
    
    error('Images:dicomread:fileNotFound', ...
          'File "%s" not found.', filename);
    
  end

  filename = fopen(fid);
  d = dir(filename);
  d.name = filename;
  fclose(fid);

else
  
  d.name = filename;
  
end

% Parse the DICOM file into a set of tags containing "raw" UINT8 data.
dictionaryFile = dicomdict('get_current');
attrs = dicomparse(d.name, d.bytes, getEndian, true, dictionaryFile);

if (isempty(attrs))

  error('Images:dicomread:parseError', 'Trouble parsing DICOM file.')

end

% Get the tags necessary for decoding the pixel data.
hasRepeatedGroups([], 'reset');
metadata = getTagsForPixels(attrs);
metadata = convertToDouble(metadata);

% Decompress/decode the pixel data and get the finished frame(s).
if (~isSupportedSyntax(metadata.TransferSyntaxUID))

  error('dicomquickread:unsupportedEncoding', ...
        'Unsupported data encoding.')
  
elseif (isCompressedData(metadata.TransferSyntaxUID))
  
  X = processEncapsulatedPixels(metadata);

else
  
  X = processRawPixels(metadata);
  
end

% Convert colorspace if necessary.
if (requiresColorspaceConversion(metadata.TransferSyntaxUID))
  
  switch (metadata.PhotometricInterpretation)
  case {'YBR_FULL', 'YBR_FULL_422'}
    
      % YCbCr full:  Convert and rescale in one step.
      X = ybr2rgb(X, 'full', metadata.BitsStored);
    
  case {'YBR_PARTIAL_422'}
    
      % YCbCr partial (4:2:2):  Convert and rescale in one step.
      X = ybr2rgb(X, 'partial', metadata.BitsStored);
  
  end
  
end
  
% Only get colormap, alpha channel and overlay if they're requested.
if (nargout >= 2)
  map = getColormap(metadata);
else
  map = [];
end

if (nargout >= 3)
  
  alpha = getAlpha(X, metadata);
  if (~isempty(alpha))
    X(:,:,1,:) = [];
  end
  
else
  
  alpha = [];
  
end

if (nargout >= 4)
  [overlays, X] = getOverlays(X, metadata);
else
  overlays = [];
end



function byteOrder = getEndian

persistent endian

if (~isempty(endian))
  byteOrder = endian;
  return
end

[c, m, endian] = computer;
byteOrder = endian;



function metadata = getTagsForPixels(attrs)

persistent dictionary
if (isempty(dictionary))
  dictionary = newMiniDictionary;
end

metadata = newMetadata(dictionary);

grp = [attrs(:).Group];
elt = [attrs(:).Element];

for p = 1:numel(dictionary)
  metadata = addAttrToMeta(metadata, attrs, grp, elt, dictionary(p));
end

% Post-process any attributes as necessary.
metadata.NumberOfFrames = getNumberOfFrames(metadata);



function dictionary = newMiniDictionary
%NEWMINIDICTIONARY  Create a mini DICOM dictionary for image reading.

d = {'0002', '0010', 'TransferSyntaxUID',         'char',   ''
     '0028', '0002', 'SamplesPerPixel',           'uint16', 1
     '0028', '0004', 'PhotometricInterpretation', 'char',   ''
     '0028', '0006', 'PlanarConfiguration',       'uint16', []
     '0028', '0008', 'NumberOfFrames',            'char',   ''
     '0028', '0010', 'Rows',                      'uint16', []
     '0028', '0011', 'Columns',                   'uint16', []
     '0028', '0100', 'BitsAllocated',             'uint16', []
     '0028', '0101', 'BitsStored',                'uint16', []
     '0028', '0102', 'HighBit',                   'uint16', []
     '0028', '0103', 'PixelRepresentation',       'uint16', []
     '0028', '1101', 'RedPaletteLUTDescriptor',   'uint16', []
     '0028', '1102', 'GreenPaletteLUTDescriptor', 'uint16', []
     '0028', '1103', 'BluePaletteLUTDescriptor',  'uint16', []
     '0028', '1201', 'RedPaletteLUTData',         'uint16', []
     '0028', '1202', 'GreenPaletteLUTData',       'uint16', []
     '0028', '1203', 'BluePaletteLUTData',        'uint16', []
     '60XX', '0010', 'OverlayRows',               'uint16cell', {}
     '60XX', '0011', 'OverlayColumns',            'uint16cell', {}
     '60XX', '0012', 'OverlayPlanes',             'uint16cell', {}
     '60XX', '0015', 'NumberOfFramesInOverlay',   'uint16cell', {}
     '60XX', '0100', 'OverlayBitsAllocated',      'uint16cell', {}
     '60XX', '0102', 'OverlayBitPosition',        'uint16cell', {}
     '60XX', '3000', 'OverlayData',               'uint16cell', {}
     '7FE0', '0010', 'InstanceData',              'uint8',  []};

dictionary = struct('Group', d(:,1), ...
                    'Element', d(:,2), ...
                    'Name', d(:,3), ...
                    'Datatype', d(:,4), ...
                    'Default', d(:,5));



function nFrames = getNumberOfFrames(metadata)

if (~isempty(metadata.NumberOfFrames))

  % Process multiple frame data, which is like encapsulated data.
  nFrames = sscanf(metadata.NumberOfFrames, '%d');
  if (isempty(nFrames))
    
    nFrames = 1;
    warning('Images:dicomread:badNumberOfFrames', ...
            'Could not determine number of frames.');
    
  end

else
  
  nFrames = 1;
  
end



function out = addAttrToMeta(out, in, allGroups, allElements, dictionaryEntry)

swap = needToSwapData(out, dictionaryEntry);

if (isequal(dictionaryEntry.Group(3:4), 'XX'))
  
  % Repeated group attribute.
  out.(dictionaryEntry.Name) = processRepGroup(out, in, dictionaryEntry, ...
                                               allElements);
  
else
  
  % Normal attribute.
  grp = sscanf(dictionaryEntry.Group, '%x');
  elt = sscanf(dictionaryEntry.Element, '%x');

  % Look for the dictionary entry in the data set, and process it.
  idx = find((grp == allGroups) & (elt == allElements));
  if (~isempty(idx))
    
    if (numel(idx) > 1)
        
      % Attributes should only appear once at a particular level.
      % Warn and use the last one (consistent with DICOMINFO).
      warning('Images:dicomread:repeatedAttribute', ...
              'Attribute (%04X,%04X) appears more than once.  Using the last one.', ...
              grp, elt)
      
      idx = idx(end);
      
    end
    
    out.(dictionaryEntry.Name) = getData(in(idx), dictionaryEntry, swap);
  
  end

end



function data = processRepGroup(metadata, attr, dictionaryEntry, allElements)

% No sense looking for data in subsequent entries if there isn't any.
if (~hasRepeatedGroups(attr, dictionaryEntry.Group))
  
  data = dictionaryEntry.Default;
  return
  
end

swap = needToSwapData(metadata, dictionaryEntry);

% Find the indices to the repeated dictionary entry in the data set.
elt = sscanf(dictionaryEntry.Element, '%x');
idx = find((findRepeatedGroup(attr, dictionaryEntry.Group) & ... 
            (elt == allElements)));

% Add each occurrence to the output array/cell.
count = 0;
data = dictionaryEntry.Default;
for p = idx
  
  count = count + 1;
  data(count) = getData(attr(p), dictionaryEntry, swap);
  
end



function tf = hasRepeatedGroups(attr, group)

persistent mask;
persistent lookedForAttrs;

if ((isempty(attr)) && (isequal(group, 'reset')))
  
  findRepeatedGroup([], 'reset');
  
  mask = [];
  lookedForAttrs = false;

  tf = true;
  
elseif (~lookedForAttrs)
  
  mask = findRepeatedGroup(attr, group);

  lookedForAttrs = true;
  tf = any(mask);
  
else
  
  tf = any(mask);
  
end



function mask = findRepeatedGroup(attr, group)

persistent groupMask;

if ((isempty(attr)) && (isequal(group, 'reset')))
  
  groupMask = [];
  mask = groupMask;
  return

elseif (isempty(groupMask))
  
  repStart = sscanf([group(1:2) '00'], '%x');
  
  allGroups = [attr(:).Group];
  groupMask = ((allGroups >= repStart) & (allGroups < (repStart + 256)));
  mask = groupMask;
  
else
  
  mask = groupMask;
  
end


function data = getData(attr, dictionaryEntry, swap)

switch (dictionaryEntry.Datatype)
 case 'char'
  
  value = char(attr.Data);
  value(value == 0) = [];
  data = value;
  
 case 'uint8'
  
  data = attr.Data;
  
 case 'uint16'
  
  if (swap)
    attr.Data = swap16Bit(attr.Data);
  end
  
  data = dicom_typecast(attr.Data, 'uint16');
  
 case 'uint16cell'
  
  if (swap)
    attr.Data = swap16Bit(attr.Data);
  end
  
  data = {dicom_typecast(attr.Data, 'uint16')};
  
 case 'uint32'
  
  if (swap)
    attr.Data = swap32Bit(attr.Data);
  end
  
  data = dicom_typecast(attr.Data, 'uint32');
  
end



function metadata = newMetadata(dictionary)

for p = 1:numel(dictionary)
  metadata.(dictionary(p).Name) = dictionary(p).Default;
end



function tf = isSupportedSyntax(UID)

details = getUidDetails(UID);
tf = details.Supported;



function tf = isCompressedData(UID)

details = getUidDetails(UID);
tf = details.Compressed;



function tf = requiresColorspaceConversion(UID)

details = getUidDetails(UID);
tf = details.RequiresPostProcessing;



function details = getUidDetails(UID)

% Try to support fragmentary images as best as we can.
if (isempty(UID))
  
  details.Supported = true;
  details.Compressed = false;
  details.DecompressFcn = '';
  details.RequiresPostProcessing = true;
  return
  
end

% Get specific UID details.
switch (UID)
 case {'1.2.840.10008.1.2'
       '1.2.840.10008.1.2.1'
       '1.2.840.10008.1.2.2'
       '1.2.840.113619.5.2'}
  
  details.Supported = true;
  details.Compressed = false;
  details.DecompressFcn = '';
  details.RequiresPostProcessing = true;
  
 case '1.2.840.10008.1.2.5' 
  
  details.Supported = true;
  details.Compressed = true;
  details.DecompressFcn = @decompressRleFrame;
  details.RequiresPostProcessing = true;

 case {'1.2.840.10008.1.2.4.50'
       '1.2.840.10008.1.2.4.57'
       '1.2.840.10008.1.2.4.70'}
  
  details.Supported = true;
  details.Compressed = true;
  details.DecompressFcn = @decompressJpegFrame;
  details.RequiresPostProcessing = false;
  
 otherwise
  
  details.Supported = false;
  details.Compressed = false;
  details.DecompressFcn = '';
  details.RequiresPostProcessing = false;
  
end
  


function X = processRawPixels(metadata)

% Stop if there isn't any image data stored in the file.
if (isempty(metadata.InstanceData))
    
    X = [];
    return

end

% Pixel values need to be swapped on big-endian transfer syntaxes.
swap = needToSwapPixelData(metadata.TransferSyntaxUID);

% Convert the raw pixel bytes to the correct data type.
if (metadata.BitsAllocated == 16)
  
  % Is the data signed?
  if (metadata.PixelRepresentation == 0)
    metadata.InstanceData = dicom_typecast(metadata.InstanceData, ...
                                           'uint16', swap);
  else
    metadata.InstanceData = dicom_typecast(metadata.InstanceData, ...
                                           'int16', swap);
  end
  
elseif (metadata.BitsAllocated == 32)
  
  % Is the data signed?
  if (metadata.PixelRepresentation == 0)
    metadata.InstanceData = dicom_typecast(metadata.InstanceData, ...
                                           'uint32', swap);
  else
    metadata.InstanceData = dicom_typecast(metadata.InstanceData, ...
                                           'int32', swap);
  end
  
elseif (metadata.BitsAllocated == 8)

  if (metadata.PixelRepresentation == 1)
    metadata.InstanceData = dicom_typecast(metadata.InstanceData, 'int8');
  end
  
else
  
  metadata.InstanceData = bitparse(metadata.InstanceData, ...
                                   metadata.BitsAllocated);
  
end
  
% Reshape the data and reorient.
numPixels = metadata.Columns * metadata.Rows * metadata.SamplesPerPixel ...
    * metadata.NumberOfFrames;

if (numPixels < numel(metadata.InstanceData))
  
  warning('Images:dicomread:tooMuchData', ...
          'Extra pixel data ignored.');
  
elseif (numPixels > numel(metadata.InstanceData))
  
  error('Images:dicomread:notEnoughData', ...
        'Not enough pixel data.');
  
end

if (metadata.SamplesPerPixel == 1)

  % Single sample and indexed images.    
  X = reshape(metadata.InstanceData(1:numPixels), metadata.Columns, ...
              metadata.Rows, 1, metadata.NumberOfFrames);
  
  X = permute(X, [2 1 3 4]);
    
else
  
  % Multi-sample images.
  if (metadata.PlanarConfiguration == 0)
        
    % Interleaved by pixel.
    X = reshape(metadata.InstanceData(1:numPixels), ...
                metadata.SamplesPerPixel, ...
                metadata.Columns, metadata.Rows, ...
                metadata.NumberOfFrames);
    X = permute(X, [3 2 1 4]);
    
  else
    
    % Interleaved by sample band.
    X = reshape(metadata.InstanceData(1:numPixels), ...
                metadata.Columns, metadata.Rows, metadata.SamplesPerPixel, ...
                metadata.NumberOfFrames);
    X = permute(X, [2 1 3 4]);
    
  end
    
end



function X = processEncapsulatedPixels(metadata)

% Stop if there isn't any image data stored in the file.
if (isempty(metadata.InstanceData))
    
    X = [];
    return

end

% Set the decoder to use.
details = getUidDetails(metadata.TransferSyntaxUID);
decodeFcn = details.DecompressFcn;

% Decode the encapsulation layer: Offset table, delimiters, etc.
[offsetTable, offset] = processOffsetTable(metadata);

% Process each element in the offsetTable.
if (isempty(offsetTable))
    
  % No offset table implies only one frame.
  X = decodeFcn(metadata, offset);
  
else
  
  % Preallocate the output array and fill it with each fragment.
  X(metadata.Rows, ...
    metadata.Columns, ...
    metadata.SamplesPerPixel, ...
    metadata.NumberOfFrames) = getOutputType(metadata);
  
  for p = 1:numel(offsetTable)
    
    fragmentStart = offset + offsetTable(p);
    X(:,:,:,p) = decodeFcn(metadata, fragmentStart);
    
  end
  
end



function [offsetTable, offsetDelta] = processOffsetTable(metadata)

% All encapsulated data is stored little-endian.
persistent swap;
if (isempty(swap))
  swap = isequal(getEndian, 'B');
end

% Skip the item delimiter (4 bytes).
offsetDelta = 4;

% Length of the offset table.
len = dicom_typecast(metadata.InstanceData((1:4) + offsetDelta), ...
                     'uint32', swap);
offsetDelta = offsetDelta + 4;

% If present the offset table is len/4 UINT32 values.
offsetTable = metadata.InstanceData((1:len) + offsetDelta);

if (~isempty(offsetTable))
  offsetTable = dicom_typecast(offsetTable, 'uint32', swap);
end

offsetTable = double(offsetTable);

% Compute the location in the instance data where the offset table ends.
offsetDelta = offsetDelta + double(len);

  
  
function X = decompressJpegFrame(metadata, offset)
  
% All compressed data is stored little-endian.
persistent swap;
if (isempty(swap))
  swap = isequal(getEndian, 'B');
end

% Skip the item delimiter, moving to the start of the codestream.
offset = offset + 4;

% Get the length of the encoded data segment.
len = metadata.InstanceData((1:4) + offset);
if (swap)
  len = swap32Bit(len);
end
len = dicom_typecast(len, 'uint32');

offset = offset + 4;

% Write the encapsulated data to a temporary file.
tempfile = getTempfileName;

fid = fopen(tempfile, 'w');

if (fid < 0)
  error('Images:dicomread:tempfileCreation', ...
        'Couldn''t create temporary file to decode encapsulated data.')
end

fwrite(fid, metadata.InstanceData((1:len) + offset), 'uint8');
fclose(fid);

% Read the data and clean up.
X = imread(tempfile);

% IMREAD always returns unsigned values.  Convert if necessary.
if (metadata.PixelRepresentation == 1)
  X = convertJpegType(X);
end

delete(tempfile)



function out = convertJpegType(in)

switch (class(in))
 case 'uint8'
  out = reshape(dicom_typecast(in(:), 'int8'), size(in));
  
 case 'uint16'
  out = reshape(dicom_typecast(in(:), 'int16'), size(in));
  
end


function X = decompressRleFrame(metadata, startOfFragment)

% All compressed data is stored little-endian.
persistent swap;
if (isempty(swap))
  swap = isequal(getEndian, 'B');
end

% Skip the item delimiter, moving to the start of the codestream.
offset = startOfFragment + 4;

% Get the length of the current RLE fragment.
fragmentLength = dicom_typecast(metadata.InstanceData((1:4) + offset), ...
                                'uint32', swap);

offset = offset + 4;

% The first 64 bytes comprise the segment offset table, which
% contains the RLE segment locations relative to the beginning of
% the RLE codestream (i.e., the segment's offset).  The first
% number is the number of segments and the remaining 15 numbers are
% the offsets to the segments or 0 for unused entries.  This RLE
% offset table is different than the basic offset table.
segmentOffsets = double(dicom_typecast(metadata.InstanceData((1:64) ...
                                                  + offset),  'uint32', swap));

% Create an output array for the decompressed data.
decompSegmentSize = metadata.Rows * metadata.Columns;
pixCodes = repmat(uint8(0), [segmentOffsets(1), decompSegmentSize]);

% Decompress each segment into the byte buffer.  The result is a
% set of "composite pixel codes," or the individual bytes comprising
% the pixel data.  This step re-interleaves the bytes from the
% individual RLE-compressed segments to produce the pixel codes.
for p = 1:segmentOffsets(1)
  
  % Compute the range of data between the start of this segment and
  % the end of the fragment.  This is the easiest way to determine
  % what data could be of use to the decoder.
  start = offset + segmentOffsets(p+1) + 1;
  stop = offset + fragmentLength;
  
  % Decode this segment of the composite pixel code.
  pixCodes(p,:) = dicom_decode_rle_segment(metadata.InstanceData(start:stop), ...
                                           decompSegmentSize);
  
end

% Convert the "composite pixel codes" into "pixel cells," the same
% representation MATLAB uses for images.
oneFrame = getMinimumMetadataForRLE(metadata);
oneFrame.InstanceData = pixCodes(:);
oneFrame.NumberOfFrames = 1;
oneFrame.PlanarConfiguration = 0;
X = processRawPixels(oneFrame);



function sample = getOutputType(metadata)

if (metadata.BitsStored <= 8)
  
  if (metadata.PixelRepresentation == 0)
    sample = uint8(0);
  else
    sample = int8(0);
  end
  
else
  
  if (metadata.PixelRepresentation == 0)
    sample = uint16(0);
  else
    sample = int16(0);
  end
  
end



function tf = needToSwapData(metadata, attr)

endian = getEndian;

if ((isequal(attr.Group, '0002')) && (isequal(endian, 'B')))
  
  tf = true;
  
else
  
  if ((isequal(metadata.TransferSyntaxUID, '1.2.840.10008.1.2.2')) && ...
      (isequal(endian, 'L')))
    
    tf = true;
    
  elseif (~isequal(metadata.TransferSyntaxUID, '1.2.840.10008.1.2.2') && ...
          isequal(endian, 'B'))
    
    tf = true;
    
  else
    
    tf = false;
    
  end
  
end



function tf = needToSwapPixelData(transferSyntaxUID)

endian = getEndian();

if (isempty(transferSyntaxUID))
  
  % Handle the case of fragmentary DICOM files, which we assume to
  % have little-endian pixels.
  tf = isequal(endian, 'B');
  return
  
end

% Decide whether to swap based on the file's transfer syntax UID.
txfrDetails = dicom_uid_decode(transferSyntaxUID);

if (isempty(txfrDetails.Value))
  
  error('Images:dicomread:unrecognizedTxfrUID', ...
        'Unrecognized DICOM transfer syntax (''%s'').  Cannot decode.', ...
        transferSyntaxUID)
  
else
  
  tf = (isequal(endian, 'B') && ...
        isequal(txfrDetails.PixelEndian, 'ieee-le')) || ...
       (isequal(endian, 'L') && ...
        isequal(txfrDetails.PixelEndian, 'ieee-be'));
  
end



function out = swap16Bit(in)

out = reshape(in, [2, numel(in) / 2]);
out = flipud(out);
out = out(:)';



function out = swap32Bit(in)

out = reshape(in, [4, numel(in) / 4]);
out = flipud(out);
out = out(:)';



function map = getColormap(metadata)

% See PS 3.3-2000 Sec. C.7.6.3.1.5 and C.7.6.3.1.6.

% If there are no descriptors, there is no colormap.
if (isempty(metadata.RedPaletteLUTDescriptor))
  
  map = [];
  return
  
end

% Reconstitute the MATLAB-style colormap from the color data and
% descriptor values.
red = double(metadata.RedPaletteLUTData) ./ ...
      (2 ^ double(metadata.RedPaletteLUTDescriptor(3)) - 1);

green = double(metadata.GreenPaletteLUTData) ./ ...
        (2 ^ double(metadata.GreenPaletteLUTDescriptor(3)) - 1);

blue = double(metadata.BluePaletteLUTData) ./ ...
       (2 ^ double(metadata.BluePaletteLUTDescriptor(3)) - 1);

map = [red' green' blue'];



function alpha = getAlpha(X, metadata)

if (isequal(metadata.PhotometricInterpretation, 'ARGB'))
  
  alpha = X(:,:,1,:);
  
else
  
  % No alpha channel.
  alpha = [];
    
end



function [overlays, X] = getOverlays(X, metadata)

if ((isempty(metadata.OverlayBitsAllocated)) || ...
    (isempty(metadata.OverlayBitsAllocated{1})))
  
  overlays = [];
  return

end

overlays(metadata.OverlayRows{1}, metadata.OverlayColumns{1}, ...
         1, numel(metadata.OverlayRows)) = false;

% Process each of the overlays.
attrOverlayCount = 0;
for p = 1:numel(metadata.OverlayRows)
  
  if (metadata.OverlayBitPosition{p} == 0)
    
    % The overlay is located in the next (60xx,3000) attribute.
    % Separate its bits into the overlay, reshape it, and
    % transpose.
    %
    % Because of padding, not all bits may be used.
    attrOverlayCount = attrOverlayCount + 1;

    cols = double(metadata.OverlayColumns{p});
    rows = double(metadata.OverlayRows{p});
    
    tmp = tobits(metadata.OverlayData{attrOverlayCount});
    overlays(:,:,1,p) = reshape(tmp(1:(cols * rows)), [cols, rows])';
  
  else
    
    % The overlay is with the rest of the instance data (pixels).
    % Mask out the overlay bits and remove from the instance data.
    overlays(:,:,1,p) = bitget(X(:,:,1,1), ...
                               metadata.OverlayBitPosition{p} + 1);
    X = bitset(X(:,:,:,:), metadata.OverlayBitPosition{p} + 1, 0);
    
  end
  
end



function tempfile = getTempfileName

nFiles = 1;

persistent tempfiles counter;
if (isempty(tempfiles))
  
  for p = 1:nFiles
    tempfiles{p} = tempname;
  end
  
  counter = 0;
end

counter = rem(counter, nFiles) + 1;
tempfile = tempfiles{counter};



function [X, map, alpha, overlays] = oldDicomread(msgname, varargin)
% This is the old DICOMREAD that we should keep around until the
% new syntax supports all of the various transfer syntaxes and follies.

if (nargin < 1)
    
    eid = 'Images:dicomread:tooFewInputs';
    error(eid, '%s', 'DICOMREAD requires at least one argument.')
    
end

args = parse_inputs(varargin{:});
dicomdict('set_current', args.Dictionary);

try
    
    [X, map, alpha, overlays] = read_messages(args, msgname);

catch

    dicomdict('reset_current');
    rethrow(lasterror)
    
end

dicomdict('reset_current');



function [X, map, alpha, overlays] = read_messages(args, msgname)
%READ_MESSAGES  Read the DICOM messages.

% Determine what to do based on message / info structure.

if (isstruct(msgname))

    %
    % Use output from DICOMINFO.
    %
    
    % Only handle single message structs.
    if (length(msgname) > 1)

        eid = 'Images:dicomread:nonscalarMessageStruct';
        error(eid, '%s', 'Info structure must contain only one message''s metadata.');
        
    end
    
    % Make sure it is a DICOM info struct.
    if ((~isfield(msgname, 'Format')) || ...
        ((~isequal(msgname.Format, 'DICOM')) && ...
         (~isequal(msgname.Format, 'ACR/NEMA'))))
        
        eid = 'Images:dicomread:invalidFirstInput';
        error(eid, '%s', 'First argument must be a file name or DICOM info structure.');

    end
    
    % Use previous message.
    file = dicom_create_file_struct;

    % This takes the place of DICOM_GET_MSG.
    file.Messages = {msgname.Filename};
    file.Location = 'Local';
    file.Current_Message = 0;
    
    % Reset number of warnings.
    file = dicom_warn('reset', file);

else
    
    %
    % Create File structure with uninitialized values.
    %
    
    file = dicom_create_file_struct;
    
    file.Messages = msgname;
    file.Location = args.Location;
    
    % Reset number of warnings.
    file = dicom_warn('reset', file);

    %
    % Get message to read.
    %
    
    file = dicom_get_msg(file);
    
    if (isempty(file.Messages))

        if (isequal(file.Location, 'Local'))
            msg = sprintf('File "%s" not found.', msgname);
        else
            msg = 'Query returned no matches.';
        end
        
        eid = 'Images:dicomread:noFileOrMessageFound';
        error(eid, '%s', msg)
        
    end

end  % isstruct.

numMessages = numel(file.Messages);

% Create containers for the output.
X = cell(1, numMessages);
info = cell(1, numMessages);
map = cell(1, numMessages);
alpha = cell(1, numMessages);
overlays = cell(1, numMessages);

%
% Read the metadata and image data for each message.
%

for p = 1:numMessages
    
    %
    % Open the message.
    %

    file = dicom_open_msg(file, 'r');
    
    %
    % Acquire metadata.
    %
    
    % Create container for metadata.
    info{p} = dicom_create_meta_struct(file);
    
    % Find the location of the required tags and the transfer
    % syntax.  After this step we'll be at the pixel data or EOF.
    [tags, pos, info{p}, file] = dicom_get_tags(file, info{p});
    fpos = ftell(file.FID);
    
    % Image tags (0028,xxxx).
    idx_1 = find(tags(:,1) == 40);
    
    % Overlay attributes (60xx,xxxx)
    idx_2 = find(((tags(:,1) >= 24576) & ...
                 (tags(:,1) <  24832)));
        
    image_attrs = [idx_1; idx_2];
        
    if (image_attrs(end) == (image_attrs(end-1)))
        image_attrs(end) = [];
    end
        
    for q = 1:length(image_attrs)
            
        idx = image_attrs(q);
            
        [info{p}, file] = dicom_read_attr_by_pos(file, ...
                                                 pos(idx), ...
                                                 info{p});
            
    end
        
    info{p} = dicom_set_imfinfo_values(info{p}, file);
        
    % Go to the beginning of the pixel data or EOF.
    fseek(file.FID, fpos, 'bof');
        
    % Make sure required fields are double.
    info{p} = convertToDouble(info{p});
    
    %
    % Extract the image data.
    %
    
    % Don't try to read past the end of the file.  Unfortunately, FEOF
    % doesn't register EOF until after you've driven off the end of the
    % highway.

    % See if we're at EOF.
    fread(file.FID, 1, 'uint8');
    
    if (feof(file.FID))
        
        % No image data present.
        X{p} = [];
        map{p} = [];
        alpha{p} = [];
        overlays{p} = logical([]);
        
    else
        
        % Rewind last read byte.
        fseek(file.FID, -1, 'cof');
        
        % Extract image data.
        [X{p} map{p} alpha{p} overlays{p} info{p} file] = dicom_read_image(file, ...
                                                  info{p}, ...
                                                  args.Frames);
    
    end
    
    %
    % Close the message.
    %
    
    file = dicom_close_msg(file);
    
    %
    % Apply transformations.
    %
    
    if (~isempty(X{p}))
        [X{p}, file] = dicom_xform_image(X{p}, info{p}, args.Raw, file);
    end
    
    %
    % Remove unwanted frames from native images.
    %
    
    if ((~isempty(X{p})) && (size(X{p}, 4) ~= length(info{p}.SelectedFrames)))

        % Native image.  Extra frames have not been removed yet.
        all_frames = 1:(info{p}.NumberOfFrames);
        
        % Find frames which are to be tossed.
        toss = setdiff(all_frames, info{p}.SelectedFrames);
        
        % Remove frames.
        if (~isempty(toss))
            X{p}(:,:,:,toss) = [];
        end
        
    end
    
    %
    % Store the overlays.
    %
    
    % Look for overlays in pixel cells (which are now in overlays{p}).
    if (isempty(overlays{p}))
        
        % Extraneous dimensions always have size >= 1.
        % Explicitly set it to 0.
        num_overlaycells = 0;
        
    else
        
        num_overlaycells = size(overlays{p}, 4);
        
    end
    
    % Look for overlays stored in metadata.
    fields = fieldnames(info{p});
    ol_data_fields = strmatch('OverlayData', fields);

    num_overlaydata = length(ol_data_fields);
    
    % Store the metadata overlays with the pixel cell overlays.
    if (num_overlaydata > 0)
        
        % Pad out the overlay array to accomodate all overlays.
        overlays{p}(info{p}.Rows, info{p}.Columns, 1, ...
                    (num_overlaydata + num_overlaycells)) = false;

        % Put each overlay in the output array.
        count = num_overlaycells;

        for q = ol_data_fields'

            plane = info{p}.(fields{q});
            
            if (~isempty(plane))
                
                count = count + 1;
                overlays{p}(:,:,:,count) = plane;
                
            end
            
        end
        
        % Remove unfilled overlay frames.
        if ((num_overlaycells + num_overlaydata) ~= count)
           
            overlays{p}(:,:,:,((count+1):end)) = [];
            
        end
        
    end

    % Collapse a 4-D empty array to 2-D for consistency.  This only
    % happens when the DICOM file contains bogus overlay data.
    if (isempty(overlays{p}))
        overlays{p} = [];
    end
    
end  % For each message.

% Remove from cell arrays if only one message.
if (file.Current_Message == 1)
    
    if (~isempty(X))
        
        X = X{1};
        map = map{1};
        alpha = alpha{1};
        overlays = overlays{1};
        
    end
    
end


%%%
%%% Function parse_inputs
%%%
function args = parse_inputs(varargin)

% Set default values
args.Frames = 'all';
args.Dictionary = dicomdict('get_current');
args.Raw = 1;

% Determine if messages are local or network.
% Currently only local messages are supported.
args.Location = 'Local';

% Parse arguments based on their number.
if (nargin > 1)
    
    paramStrings = {'frames'
                    'dictionary'
                    'raw'};
    
    % For each pair
    for k = 1:2:length(varargin)
       param = lower(varargin{k});
       
            
       if (~ischar(param))
           eid = 'Images:dicomread:parameterNameNotString';
           msg = 'Parameter name must be a string';
           error(eid, '%s', msg);
       end

       idx = strmatch(param, paramStrings);
       
       if (isempty(idx))
           eid = 'Images:dicomread:unrecognizedParameterName';
           msg = sprintf('Unrecognized parameter name "%s"', param);
           error(eid, '%s', msg);
       elseif (length(idx) > 1)
           eid = 'Images:dicomread:ambiguousParameterName';
           msg = sprintf('Ambiguous parameter name "%s"', param);
           error(eid, '%s', msg);
       end
    
       switch (paramStrings{idx})
       case 'dictionary'

           if (k == length(varargin))
               eid = 'Images:dicomread:missingDictionary';
               msg = 'No data dictionary specified.';
               error(eid, '%s', msg);
           else
               args.Dictionary = varargin{k + 1};
           end

       case 'frames'

           if (k == length(varargin))
               eid = 'Images:dicomread:missingFrames';
               msg = 'No frames specified.';
               error(eid, '%s', msg);
           else
               frames = varargin{k + 1};
           end
           
           if (((~ischar(frames)) && (~isa(frames, 'double'))) || ...
               (length(frames) ~= numel(frames)) || ...
               ((ischar(frames)) && (~isequal(lower(frames), 'all'))) || ...
               ((isa(frames, 'double')) && (any(rem(frames, 1)))))
               
               eid = 'Images:dicomread:badFrameParameter';
               msg = 'Frames must be a vector of integers or ''All''';
               error(eid, '%s', msg);
               
           else
               
               args.Frames = frames;
               
           end
           
       case 'raw'
           args.Raw = varargin{k + 1};
           
       end  % switch
       
    end  % for
           
end



function metadata = convertToDouble(metadata)
%CONVERTDATATYPES  convert required numeric types to double.

metadata.BitsAllocated = double(metadata.BitsAllocated);
metadata.BitsStored = double(metadata.BitsStored);
metadata.HighBit = double(metadata.HighBit);
metadata.Rows = double(metadata.Rows);
metadata.Columns = double(metadata.Columns);

if (isfield(metadata, 'SamplesPerPixel'))
  metadata.SamplesPerPixel = double(metadata.SamplesPerPixel);
end

if (isfield(metadata, 'NumberOfFrames'))
  metadata.NumberOfFrames = double(metadata.NumberOfFrames);
end



function out = ybr2rgb(in, format, bits)
% Convert YCbCr images to RGB and rescale values to fill range

% 4:2:2 data should have already been upsampled to 4:4:4.
%
% For the RGB -> YCbCr conversion matrices see PS 3.3-2000 Sec C.7.6.3.1.2.


% Rescale data to [0, 255] and convert to double.
switch (class(in))
case {'uint8'}

    if (rem(bits, 8) == 0)
        tmp = double(in);
    else
        tmp = double(bitshift(in, (8 - bits)));
    end
        
case 'uint16'

    if (rem(bits, 8) == 0)
        tmp = double(in)/(2^8 + 1);
    else
        tmp = double(bitshift(in, (16 - bits)));
        tmp = tmp/(2^8 + 1);
    end
        
case 'uint32'

    if (rem(bits, 8) == 0)
        tmp = double(in)/(2^24 + 1);
    else
        tmp = double(bitshift(in, (32 - bits)));
        tmp = tmp/(2^24 + 1);
    end
        
end

switch (format)
case 'full'
    
    scale = [0 128 128]';

    RGB = [ 0.2990  0.5870  0.1140;
           -0.1687 -0.3313  0.5000;
            0.5000 -0.4187 -0.0813];

case 'partial'
    
    scale = [16 128 128]';
    
    RGB = [ 0.2568  0.5041  0.0979;
           -0.1482 -0.2910  0.4392;
            0.4392 -0.3678 -0.0714];

end
    
Ybr = inv(RGB);

% Convert values.

for p = 1:size(in, 4)

    tmp(:,:,1,p) = tmp(:,:,1,p) - scale(1);
    tmp(:,:,2,p) = tmp(:,:,2,p) - scale(2);
    tmp(:,:,3,p) = tmp(:,:,3,p) - scale(3);
    
    out(:,:,1,p) = Ybr(1,1) * tmp(:,:,1,p) + Ybr(1,2) * tmp(:,:,2,p) + ...
        Ybr(1,3) * tmp(:,:,3,p);
    out(:,:,2,p) = Ybr(2,1) * tmp(:,:,1,p) + Ybr(2,2) * tmp(:,:,2,p) + ...
        Ybr(2,3) * tmp(:,:,3,p);
    out(:,:,3,p) = Ybr(3,1) * tmp(:,:,1,p) + Ybr(3,2) * tmp(:,:,2,p) + ...
        Ybr(3,3) * tmp(:,:,3,p);
    
end 

% Convert to original type.
switch (class(in))
case {'uint8'}
    out = uint8(out);
case 'uint16'
    out = uint16(out * (2^8 + 1));
case 'uint32'
    out = uint32(out * (2^24 + 1));
end



function metadataOut = getMinimumMetadataForRLE(metadataIn)

metadataOut = struct('TransferSyntaxUID', metadataIn.TransferSyntaxUID, ...
                     'BitsAllocated', metadataIn.BitsAllocated, ...
                     'PixelRepresentation', metadataIn.PixelRepresentation, ...
                     'Columns', metadataIn.Columns, ...
                     'Rows', metadataIn.Rows, ...
                     'SamplesPerPixel', metadataIn.SamplesPerPixel, ...
                     'NumberOfFrames', metadataIn.NumberOfFrames, ...
                     'InstanceData', []);
