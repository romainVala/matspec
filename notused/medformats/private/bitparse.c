#include "mex.h"

/** bitparse - Extract n-bit values from a UINT8 array.
 *
 * Y = BITPARSE(X, BITSPERSAMPLE) extracts values from the UINT8
 * vector X.  X is treated as a packed array of bits that can span
 * multiple bytes.  The bitsPerSample input argument contains the
 * number of contiguous bits in X that correspond to a single value in
 * Y.
 */

/* Copyright 2006 The MathWorks, Inc. */
/* $Revision: 1.1.6.1 $  $Date: 2006/03/13 19:44:30 $ */

#define MAX(A, B)  ((A) > (B) ? (A) : (B))



bool isVector(const mxArray *array)
{

  /* Vectors are 2-D arrays that are 1-by-n or n-by-1. */
  return (mxGetNumberOfDimensions(array) == 2) &&
         (MAX(mxGetM(array), mxGetN(array)) == mxGetNumberOfElements(array));
}



mxClassID computeOutputType(int bitsPerInputSample)
{
  
  /* Store bitwise samples in the right-sized output class. */
  if (bitsPerInputSample <= 8)
  {
    return mxUINT8_CLASS;
  }
  else if (bitsPerInputSample <= 16)
  {
    return mxUINT16_CLASS;
  }
  else if (bitsPerInputSample <= 32)
  {
    return mxUINT32_CLASS;
  }
  else
  {
    mexErrMsgIdAndTxt("Images:bitparse:unsupportedBPS", 
                      "Unsupported number of bits per sample.");
  }

}



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  int bitsPerOutputSample;
  int bitsPerInputSample = 8;
  mxClassID outputType;
  
  const mxArray *inputArray = prhs[0];
  const mxArray *bpsArray = prhs[1];
  
  uint8_T *inDataPtr;
  size_t numberOfSamples;
  mxArray *outputArray;
  void *outDataPtr;
  
  int  currentBit;
  size_t currentSample;
  
  /* Input checking. */
  mxAssert(nlhs <= 1, "Too many output arguments.");
  mxAssert(nrhs == 2, "Two input arguments expected.");
  mxAssert(mxIsUint8(inputArray) && isVector(inputArray),
           "First argument must be a UINT8 vector.");
  mxAssert(mxIsNumeric(bpsArray) && (mxGetNumberOfElements(bpsArray) == 1),
           "Second argument must be a numeric scalar.");
  
  /* Allocate the output buffer based on the number of elements and
     size of the output buffer.  Preserve data orientation. */
  bitsPerOutputSample = (int) mxGetScalar(bpsArray);

  numberOfSamples = (mxGetNumberOfElements(inputArray) * bitsPerInputSample) /
    bitsPerOutputSample;

  outputType = computeOutputType(bitsPerOutputSample);
  if (mxGetM(inputArray) > 1)
  {
    outputArray = mxCreateNumericMatrix(numberOfSamples, 1, 
                                        outputType, mxREAL);
  }
  else
  {
    outputArray = mxCreateNumericMatrix(1, numberOfSamples,
                                        outputType, mxREAL);
  }
  outDataPtr = mxGetData(outputArray);
  
  /* Get a pointer to the input buffer. */
  inDataPtr = (uint8_T *) mxGetData(inputArray);

  /* Loop over all of the bits building up the output samples. */
  for (currentSample = 0; currentSample < numberOfSamples; currentSample++)
  {
    
    uint32_T outputValue = 0;

    for (currentBit = 0; currentBit < bitsPerOutputSample; currentBit++)
    {

      size_t currentInputBit;
      size_t currentInputByte;
      int  currentBitInCurrentInputByte;

      uint8_T inputByte;
      uint8_T bitMask;
      uint32_T bitValue;

      /* Determine where in the entire input buffer this part of the
         sample begins. */
      currentInputBit = currentSample * bitsPerOutputSample + currentBit;
      currentInputByte = currentInputBit / 8;
      currentBitInCurrentInputByte = currentInputBit % 8;
      
      /* Get the value of this bit and augment the current output
         sample's bit pattern. */
      inputByte = inDataPtr[currentInputByte];
      bitMask = 1 << currentBitInCurrentInputByte;
      bitValue = (inputByte & bitMask) != 0;
      outputValue |= bitValue << currentBit;
    }

    /* Assign the sample to the output buffer. */
    switch (outputType) {
    case mxUINT8_CLASS :
      ((uint8_T *) outDataPtr)[currentSample] = outputValue;
      break;

    case mxUINT16_CLASS :
      ((uint16_T *) outDataPtr)[currentSample] = outputValue;
      break;

    case mxUINT32_CLASS :
      ((uint32_T *) outDataPtr)[currentSample] = outputValue;
      break;
    }
  }

  /* Return the parsed samples. */
  plhs[0] = outputArray;
  
}
