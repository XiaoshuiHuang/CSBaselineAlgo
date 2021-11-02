

/* feat1 feat2 <- P1 P2 t1 type */


#include "math.h"
#include <stdlib.h>
#include <time.h>
#include "stdio.h"
#include "mexComputeFeature.h"


int main()
{ 
  srand(time(NULL));
  
  int nP1=100;
  int nP2=100;
  int nT1=1000;
  double* pP1 = new double[nP1*2];
  double* pP2 = new double[nP2*2];
  int* pT1 = new int[nT1*3];

  const int nFeature=3;
  double* pF1 = new double[nT1*nFeature];;
  double* pF2 = new double[nP2*nP2*nP2*nFeature];
  
  for(int p=0;p<nP1*2;p++)
    pP1[p]=(double)(rand())/(double)(RAND_MAX);
  for(int p=0;p<nP2*2;p++)
    pP2[p]=(double)(rand())/(double)(RAND_MAX);
  for(int t=0;t<nT1*3;t++)
    pT1[t]=rand() % nP1;
  
  computeFeature(pP1,nP1,pP2,nP2,pT1,nT1,pF1,pF2);
  printf("%f\n",pF1[0]);
  printf("%f\n",pF2[0]);
 
  
  delete[] pP1;
  delete[] pP2;
  delete[] pT1;
  delete[] pF1;
  delete[] pF2;

  return 0;
}



