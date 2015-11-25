#include "mex.h"

/* BITS = TOBITS(BYTES) converts a vector of elements to a logical
   vector of BITS.  BYTES can be any numeric MATLAB data type.  The
   BITS vector contains the interleaved bits from the BYTES vector.
   All of the bits from the first element appear before the bits from
   the next element.

   Bits appear according to the native bit ordering of the machine
   (not to be confused with byte-order, or endianness), usually least
   significant bit to most significant.

   The number of elements in BITS is determined by the size of
   elements in BYTES, with eight elements in bits for each byte that
   an element in BYTES needs.  For example if BYTES is a 1-by-10
   vector of UINT32 values, BITS is a 1-by-320 logical vector. */

/* Copyright 1993-2005 The MathWorks, Inc. */
/* $Revision: 1.1.6.2 $ $Date: 2005/11/15 01:05:03 $ */

#define MAX(A, B)	((A) > (B) ? (A) : (B))


void split8Bits(uint8_T *outData, uint8_T *inData, long totalElements);
void split16Bits(uint8_T *outData, uint16_T *inData, long totalElements);
void split32Bits(uint8_T *outData, uint32_T *inData, long totalElements);
void split64Bits(uint8_T *outData, uint64_T *inData, long totalElements);


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  mxClassID elementClass;
  long rows, cols;
  long outRows, outCols;
  size_t elementSize;
  mxArray *outArray;
  uint8_T *outData;
  void *inData;
  int totalBits;

  /* Check input and output arguments. */
  if (nlhs > 1)
    mexErrMsgIdAndTxt("Images:toBits:oneOutputVariableRequired",
                      "%s","This function requires one output argument.");
  if (nrhs != 1)
    mexErrMsgIdAndTxt("Images:toBits:twoInputArgsRequired",
                      "%s","This function requires one input argument.");

  if ((!mxIsNumeric(prhs[0])) || (mxIsSparse(prhs[0])))
    mexErrMsgIdAndTxt("Images:toBits:firstArgMustBeFullNumArray",
                      "%s", "The first input argument must"
                      " be a full numeric array.");

  rows = mxGetM(prhs[0]);
  cols = mxGetN(prhs[0]);

  if ((((rows * cols) != MAX(rows, cols)) ||
       (mxGetNumberOfDimensions(prhs[0]) != 2)) &&
      (rows * cols) != 0)
    mexErrMsgIdAndTxt("Images:toBits:firstArgMustBeVector",
                      "%s","The first input argument must be a vector.");
   
 
  /* Create an output array for the input data's bits.
   * Preserve the vector's orientation. */
  elementClass = mxGetClassID(prhs[0]);
  elementSize = mxGetElementSize(prhs[0]); /* In bytes */

  totalBits = elementSize * 8;

  if (rows > cols) {
    outRows = rows * totalBits;
    outCols = 1;
  } else {
    outRows = 1;
    outCols = cols * totalBits;
  }

  outArray = mxCreateLogicalMatrix(outRows, outCols);
  plhs[0] = outArray;

  /* Slice the data into bits, using the native byte- and bit-ordering. */
  if (mxIsEmpty(prhs[0]))
    return;

  inData = mxGetData(prhs[0]);
  outData = (uint8_T *) mxGetData(outArray);

  switch (totalBits)
  {
  case 8:
    split8Bits(outData, (uint8_T *) inData, (rows * cols));
    break;

  case 16:
    split16Bits(outData, (uint16_T *) inData, (rows * cols));
    break;

  case 32:
    split32Bits(outData, (uint32_T *) inData, (rows * cols));
    break;

  case 64:
    split64Bits(outData, (uint64_T *) inData, (rows * cols));
    break;

  default:
    break;
  }

}



void split8Bits(uint8_T *outData, uint8_T *inData, long totalElements)
{

  int     bitPos;
  int     totalBits = 8;
  long    elementPos;

  for (elementPos = 0; elementPos < totalElements; elementPos++)
  {
    
    for (bitPos = 0; bitPos < totalBits; bitPos++)
    {

      if (inData[elementPos] < ((uint8_T) (1 << bitPos)))
        break;

      outData[elementPos * totalBits + bitPos] =
        ((inData[elementPos] >> bitPos) & 1);
    }

  }

}



void split16Bits(uint8_T *outData, uint16_T *inData, long totalElements)
{

  int     bitPos;
  int     totalBits = 16;
  uint16_T mask = 0;
  long    elementPos;


  for (elementPos = 0; elementPos < totalElements; elementPos++)
  {
    
    for (bitPos = 0; bitPos < totalBits; bitPos++)
    {

      if (inData[elementPos] < ((uint16_T) (1 << bitPos)))
        break;

      outData[elementPos * totalBits + bitPos] =
        (uint8_T) ((inData[elementPos] >> bitPos) & 1);
    }

  }

}



void split32Bits(uint8_T *outData, uint32_T *inData, long totalElements)
{

  int     bitPos;
  int     totalBits = 32;
  uint32_T mask = 0;
  long    elementPos;


  for (elementPos = 0; elementPos < totalElements; elementPos++)
  {
    
    for (bitPos = 0; bitPos < totalBits; bitPos++)
    {

      if (inData[elementPos] < ((uint32_T) (1 << bitPos)))
        break;

      outData[elementPos * totalBits + bitPos] =
        (uint8_T) ((inData[elementPos] >> bitPos) & 1);
    }

  }

}



void split64Bits(uint8_T *outData, uint64_T *inData, long totalElements)
{

  int     bitPos;
  int     totalBits = 64;
  uint64_T mask = 0;
  long    elementPos;


  for (elementPos = 0; elementPos < totalElements; elementPos++)
  {
    
    for (bitPos = 0; bitPos < totalBits; bitPos++)
    {

      if (inData[elementPos] < ((uint64_T) (1 << bitPos)))
        break;

      outData[elementPos * totalBits + bitPos] =
        (uint8_T) ((inData[elementPos] >> bitPos) & 1);
    }

  }

}
