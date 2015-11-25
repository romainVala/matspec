function [info, file] = dicom_read_mmeta(file, info)
%DICOM_READ_MMETA  Read message metadata from a DICOM message.
%   META = DICOM_READ_MMETA(FILE,INFO) reads the message metadata META
%   from FILE.  The previously read metadata INFO is passed in as context
%   for reading the metadata.
%
%   Note: Message metadata is metadata with a group value of 8 or
%   greater.  The result is that all remaining metadata from the DICOM
%   file (i.e., everything but PixelValues) is read.
%
%   See also DICOM_READ_FMETA, DICOM_READ_ATTR.

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:04:50 $

% Assumes that file.FID is valid.
% Assumes that file has file metadata.
% Assumes that file.FID is at the beginning of the message metadata.

[group, element] = dicom_get_next_tag(file);

while (group <= 32736)  % 32736 == 0x7FE0
    
    if ((group == 32736) && (element == 16))
        % Beginning of image pixel values (7FE0,0010).
        break
    end
    
    % Read the attributes.
    [attr, data, file] = dicom_read_attr(file, info);
    
    % Place the attributes in the info structure.
    info.(attr.Name) = data;
    
    [group, element] = dicom_get_next_tag(file);

    % If group is negative, then there are no more tags.
    if (group < 0)
      break
    end
    
end
