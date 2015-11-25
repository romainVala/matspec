/*
 * Copyright 1993-2006 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $  $Date: 2006/03/13 19:44:31 $
 */

/*
 * DICOM_DECODE_RLE_SEGMENT  MEX-file
 *
 * Decode run-length encoded (RLE) byte-stream.
 *
 * DATA = DICOM_DECODE_RLE_SEGMENT(COMP_SEGMENT, DECOMP_SEGMENT_SIZE)
 * decompresses the run-length encoded segment COMP_SEGMENT and returns the
 * decompressed DATA.  DECOMP_SEGMENT_SIZE is the number of elements in the
 * segment and is used to indicate when decompression is completed.
 * 
 * DATA is not necessarily a complete pixel or pixel cell.  Rather, a
 * segment is one byte in the "composite pixel code," which is a
 * concatenation of the bits from each of the samples creating a pixel.
 *
 * See PS 3.5-2001 Annex G and PS 3.3-2001 Sec. 7.6.3.1 for more details.  */

#include "mex.h"

#if !defined(MIN)
#define	MIN(A, B)	((A) < (B) ? (A) : (B))
#endif

#define DEBUG_RLE false

void mexFunction(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[] )
{

        
    mxArray *result;
    UINT8_T *result_data;

    long int segment_x, segment_y;

    UINT8_T *seg_data;

    long int decompressed_bytes;
    long int decomp_segment_size;

    long int cursor_pos;
    INT8_T source_byte;

    double out_end;

    /* 
     * Process arguments. 
     */

    if (nrhs != 2) { 
	mexErrMsgIdAndTxt("Images:dicom_decode_rle_segment:"
                          "twoInputArgsRequired",
                          "%s","Two input arguments required."); 
    } else if (nlhs > 1) {
	mexErrMsgIdAndTxt("Images:dicom_decode_rle_segment:"
                          "tooManyOutputArgs",
                          "%s","Too many output arguments."); 
    } 


    /* prhs[0]: Compressed segment. */

    segment_x = mxGetM(prhs[0]);
    segment_y = mxGetN(prhs[0]);

    if ((!mxIsUint8(prhs[0])) || 
        (MIN(segment_x, segment_y) != 1)) {
        
        mexErrMsgIdAndTxt("Images:dicom_decode_rle_segment:"
                          "segmentMustBeUint8Vector","%s",
                          "Compressed segment must be a vector of UINT8.");

    }

    /* prhs[1]: Size of decompressed segment. */

    if ((mxGetNumberOfElements(prhs[1]) != 1) || 
        (mxGetClassID(prhs[1]) != mxDOUBLE_CLASS)) {

        mexErrMsgIdAndTxt("Images:dicom_decode_rle_segment:"
                          "segmentMustBeRealScalar","%s",
                          "Decompressed segment size must be a real scalar.");

    }

    decomp_segment_size = (long int) (mxGetPr(prhs[1])[0]);


    /*
     * Decompress the segment.
     */

    /* Keep track of the position (in bytes) in compressed segment. */
    cursor_pos = 0;


    /* Create a container for the output data. */
    result = mxCreateNumericMatrix(1, decomp_segment_size,
                                   mxUINT8_CLASS, mxREAL);
    result_data = (UINT8_T *) mxGetData(result);

    
    /* Read the data from the segment and decompress. */
    seg_data = (UINT8_T *) mxGetData(prhs[0]);
    decompressed_bytes = 0;

    while (cursor_pos < (segment_x * segment_y)) 
      {

        if (DEBUG_RLE) 
          mexPrintf("%08d/%08d: ", cursor_pos, decompressed_bytes);

        /* Don't attempt to write more to the output buffer than it
           can hold. */
        if (decompressed_bytes >= decomp_segment_size)
        {
            if (DEBUG_RLE) 
              mexPrintf("\n");

            break;
        }
        
        /* Get the source byte. */
        source_byte = (INT8_T) seg_data[cursor_pos++];

        if (DEBUG_RLE) 
          mexPrintf("Source byte = %-04d  +  Next Byte = %03d  ==> ", 
                    source_byte,
                    (UINT8_T) (seg_data[cursor_pos + 1]));

        if (source_byte >= 0) {

            /* Output next (source_byte + 1) bytes literally. */
            if (DEBUG_RLE) 
              mexPrintf("Output next %03x bytes literally.\n",
                        source_byte + 1);
            
            
            out_end = decompressed_bytes + source_byte + 1;
            
            while (decompressed_bytes < out_end) {
                
                result_data[decompressed_bytes++] = seg_data[cursor_pos++];
                
            }
            
        } else if ((source_byte >= -127) && (source_byte <= -1)) {
            
            /* Output the next byte (-source_byte + 1) times. */
            if (DEBUG_RLE) 
              mexPrintf("Repeat the next byte (0x%03x) %03d times.\n",
                        (UINT8_T) seg_data[cursor_pos + 1], 
                        ((UINT8_T) -source_byte) + 1);
            
            source_byte = -source_byte;
            
            out_end = decompressed_bytes + source_byte + 1;
            
            while (decompressed_bytes < out_end) {
                
                result_data[decompressed_bytes++] = seg_data[cursor_pos];
                
            }
            
            /* Move to next source_byte. */
            cursor_pos++;
            
        } else if (source_byte == -128) {
            
            /* Do nothing. */
            if (DEBUG_RLE) 
              mexPrintf("No-op.\n");
            
        }
        
    }

    plhs[0] = result;

}
