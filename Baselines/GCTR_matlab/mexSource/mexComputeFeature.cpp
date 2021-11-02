

/* feat1 feat2 <- P1 P2 t1 type */


#include "mex.h"
#include "math.h"
#include "mexOliUtil.h"
#include <stdlib.h>
#include <time.h>

#include "mexComputeFeature.h"


void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
{ 
  enum{ P1i , P2i , t1i , typei };
  enum{ feat1i , feat2i };
  
  oliCheckArgNumber(nrhs,4,nlhs,2);
  int nP1,nP2,nT1;
  double* pP1 = oliCheckArg(prhs,P1i,3,&nP1,oliDouble);
  double* pP2 = oliCheckArg(prhs,P2i,3,&nP2,oliDouble);
  int* pT1 = (int*)oliCheckArg(prhs,t1i,3,&nT1,oliInt);

  const int nFeature=3;
  plhs[feat1i] = mxCreateDoubleMatrix(nFeature, nT1, mxREAL);
  double* pF1 = mxGetPr(plhs[feat1i]);
  plhs[feat2i] = mxCreateDoubleMatrix(nFeature, nP2*nP2*nP2, mxREAL);
  double* pF2 = mxGetPr(plhs[feat2i]);
  
  computeFeature(pP1,nP1,pP2,nP2,pT1,nT1,pF1,pF2);

}

