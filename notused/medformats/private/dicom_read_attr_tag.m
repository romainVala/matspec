function attr = dicom_read_attr_tag(file, attr)
%DICOM_READ_ATTR_TAG  Read the group and element values of the attribute.
%   ATTR = DICOM_READ_ATTR_TAG(FILE, ATTR) updates the attribute ATTR by
%   reading the ordered pair (group, element) from FILE.
%
%   See also DICOM_REAT_ATTR_METADATA.

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:04:47 $


attr.Group = fread(file.FID, 1, 'uint16', file.Current_Endian);
attr.Element = fread(file.FID, 1, 'uint16', file.Current_Endian);

