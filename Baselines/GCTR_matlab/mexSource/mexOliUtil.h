#ifndef OLI_UTILS
#define OLI_UTILS 1


#include "mex.h"
#include <sstream>
using namespace std;

void oliCheckArgNumber(int nrhs, int nIn, int nlhs = NULL , int nOut = -1)
{
  if(nIn != -1)
    if (nrhs != nIn)
    {
      stringstream errMsg;
      errMsg << nIn << " input arguments required." << endl;
      mexErrMsgTxt(errMsg.str().c_str());
    }
  if(nOut != -1)
    if (nlhs != nOut)
    {
      stringstream errMsg;
      errMsg << nOut << " output arguments required." << endl;
      mexErrMsgTxt(errMsg.str().c_str());
    }
}

enum{ oliDouble , oliInt };

double* oliCheckArg(const mxArray *prhs[],int indArg,int m = -1 ,int n = -1, int type = -1)
{
  if(m!=-1)
  {
    if(mxGetM(prhs[indArg])!=m)
    {
      stringstream errMsg;
      errMsg << "argument number " << indArg+1 << " should have " << m << " rows." << endl;
      mexErrMsgTxt(errMsg.str().c_str());
    }
  }
  if(n!=-1)
  {
    if(mxGetN(prhs[indArg])!=n)
    {
      stringstream errMsg;
      errMsg << "argument number " << indArg+1 << " should have " << n << " columns." << endl;
      mexErrMsgTxt(errMsg.str().c_str());
    }
  }
  switch(type)
  {
    case 0:
      if(!mxIsDouble(prhs[indArg]))
      {
        stringstream errMsg;
        errMsg << "argument number " << indArg+1 << " should be double." << endl;
        mexErrMsgTxt(errMsg.str().c_str());
      }
      break;
    case 1:
      if(!mxIsInt32(prhs[indArg]))
      {
        stringstream errMsg;
        errMsg << "argument number " << indArg+1 << " should be integer." << endl;
        mexErrMsgTxt(errMsg.str().c_str());
      }
      break;      
  }
//  if(mxIsDouble(prhs[indArg]))
//    return mxGetPr(prhs[indArg]);
  return mxGetPr(prhs[indArg]);
}

double* oliCheckArg(const mxArray *prhs[],int indArg, int* mOut ,int n = -1, int type = -1)
{
  *mOut = mxGetM(prhs[indArg]);
  return oliCheckArg(prhs,indArg,-1,n,type);
}
double* oliCheckArg(const mxArray *prhs[],int indArg, int m ,int* nOut, int type = -1)
{
  *nOut = mxGetN(prhs[indArg]);
  return oliCheckArg(prhs,indArg,m,-1,type);
}
double* oliCheckArg(const mxArray *prhs[],int indArg, int* mOut ,int* nOut, int type = -1)
{
  *mOut = mxGetM(prhs[indArg]);
  *nOut = mxGetN(prhs[indArg]);
  return oliCheckArg(prhs,indArg,-1,-1,type);
}




#endif











