function metadata = dicom_prep_GeneralSeries(metadata)
%DICOM_PREP_DICOM_PREP_GENERALSERIES  Fill values for General Study module.
%
%   See PS 3.3 Sec. C.7.2.1

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:04:39 $

name = dicom_name_lookup('0008', '0060');
if (~isfield(metadata, name))
    metadata.(name) = 'OT';
end

name = dicom_name_lookup('0020', '000E');
if (~isfield(metadata, name))
    metadata.(name) = dicomuid;
end
