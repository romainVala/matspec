function pixel_cells = dicom_decode_rle(comp_fragment, decomp_segment_size)
%DICOM_DECODE_RLE  Decode a run-length encoded byte-stream.
%   PIXEL_CELLS = DICOM_DECODE_RLE(COMP_FRAGMENT, DECOMP_SEGMENT_SIZE)
%   decompresses the run-length encoded fragment COMP_FRAGMENT and
%   returns the decompressed PIXEL_CELLS.  DECOMP_SEGMENT_SIZE is the
%   number of elements in the decompressed fragment and is used to
%   indicate when decompression is completed.

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:04:19 $

%#mex
eid = sprintf('Images:%s:missingMexFile',mfilename);
error(eid,'Missing MEX-file: %s', mfilename);
