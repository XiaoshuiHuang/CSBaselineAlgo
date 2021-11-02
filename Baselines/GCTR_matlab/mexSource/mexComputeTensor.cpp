



/*  P1 P2 nT nK -> indH valH */


#include "mex.h"
#include "math.h"
#include "mexOliUtil.h"
#include <stdlib.h>
#include <time.h>

extern void computeTensor( double* pP1, int nP1 , double* pP2, int nP2, int nT, int nK);

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
{ 
  enum{ P1i , P2i };
  enum{ indHi , valHi , nTi , nKi };
  srand( time(NULL) );
  
  oliCheckArgNumber(nrhs,4,nlhs,2);
  int nP1,nP2;
  double* pP1 = oliCheckArg(prhs,P1i,2,&nP1,oliDouble);
  double* pP2 = oliCheckArg(prhs,P2i,2,&nP2,oliDouble);
  int nT = (int)mxGetScalar(prhs[nTi]);
  int nK = (int)mxGetScalar(prhs[nKi]);
  
  int* pT = new int[nT*3];
  const int nFeature=3;
  double* pFeature1 = new double[nT*nFeature];
  double* vecX = new double[nFeature];
  double* vecY = new double[nFeature];
  for(int t=0;t<nT;t++)
  {
    for(int i=0;i<3;i++)
    {
      pT[t*3+i] = (int)(rand() % nP1);
    }
    for(int f=0;f<nFeature;f++)
    {
      vecX[f]=pP1[pT[((t+1)%3)*3]*2]-pP1[pT[t*3]*2];
      vecY[f]=pP1[pT[((t+1)%3)*3]*2+1]-pP1[pT[t*3]*2+1];
      double norm=sqrt(vecX[f]*vecX[f]+vecY[f]*vecY[f]);
      vecX[f]/=norm;
      vecY[f]/=norm;
    }
    for(int f=0;f<nFeature;f++)
      pFeature1[nT*nFeature] = vecX[((f+1)%3)]*vecY[f]-vecY[((f+1)%3)]*vecX[f];
  }
  
}














