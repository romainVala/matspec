/* dicomlookup_helper(group, element, dictionary) find the name of the
   DICOM attribute with tag (group,element) in the specified DICOM
   data dictionary.  The group and element values must be a decimal or
   hexadecimal number. */

/* Copyright 1993-2006 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $  $Date: 2006/06/15 20:10:44 $ */

#include "mex.h"
#include "dicomutils.h"
#include <stdio.h>
#include <string.h>

grouping_T *dictionary = NULL;
char *dictionaryFile = NULL;
char *previousDictionaryFile = NULL;


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  uint16_T group, element;
  ATTR_T *foundAttribute;
  
  /* Get the group and element values */
  if (nrhs != 3)
  {
    mexErrMsgIdAndTxt("Images:dicomlookup_helper:nargin", 
                      "DICOMLOOKUP_HELPER requires three input arguments.");
  }

  group = getValue(prhs[0]);
  element = getValue(prhs[1]);
  dictionaryFile = mxArrayToString(prhs[2]);

  /* Look for the input value in the data dictionary. */
  foundAttribute  = findAttrInDictionary(group, element);

  if (foundAttribute == NULL)
  {
    /* If nothing was found, return an empty array. */
    plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
  }
  else
  {
    /* Copy the attribute into a temporary value and remove it from the
       dictionary context. */
    ATTR_T outputAttribute;
    memcpy(&outputAttribute, foundAttribute, sizeof(ATTR_T));
    
    outputAttribute.Next = NULL;
    outputAttribute.Child = NULL;
    
    /* Store the output. */
    plhs[0] = storeAttrs(&outputAttribute);
  }
}
