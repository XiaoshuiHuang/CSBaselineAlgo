






#include "math.h"
#include "time.h"
#include <stdlib.h>
#include "time.h"
#include "stdio.h"


#include "mexTensorMatching.h"

int main()
{

  srand(time(NULL));
  
  int N1=50;
  int N2=50;
  int Nt=10000;
  int NN = N1*N2;
  double* pX = new double[NN];
  int* pIndH = new int[Nt*3];
  double* pValH = new double[Nt];

  double* pXout = new double[NN];
  
  for(int i=0;i<NN;i++)
    pX[i]=(double)(rand())/(double)(RAND_MAX);
  for(int i=0;i<Nt*3;i++)
    pIndH[i]=rand() % N1;
  for(int i=0;i<Nt;i++)
    pValH[i]=(double)(rand())/(double)(RAND_MAX);

  
  tensorMatching(pX,N1,N2,pIndH,pValH,Nt,pXout);
  
  printf("%f\n",pXout[0]);
  
  delete[] pX;
  delete[] pIndH;
  delete[] pValH;
  delete[] pXout;
  
}


