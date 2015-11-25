function [attr, file] = dicom_read_attr_metadata(file, info)
%DICOM_READ_ATTR_METADATA  Read the tag, VR, and length of an attribute.
%   [ATTR, FILE] = DICOM_READ_ATTR_METADATA(FILE, INFO) reads attribute
%   ATTR from FILE given the previously read metadata in INFO.  FILE is
%   returned in case some warning information has changed. 

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:04:46 $

attr = dicom_create_attr;
attr = dicom_read_attr_tag(file, attr);
[attr, file] = dicom_read_attr_vr(file, attr, info);
attr = dicom_read_attr_length(file, attr);
