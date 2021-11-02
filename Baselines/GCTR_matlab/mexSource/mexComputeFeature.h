

/* feat1 feat2 <- P1 P2 t1 type */



void computeFeatureSimple( double* pP1, int i , int j, int k , double* pF);
void computeFeature( double* pP1 , int nP1 , double* pP2 , int nP2 ,
                      int* pT1 , int nT1 , double* pF1 , double* pF2);

void computeFeature( double* pP1 , int nP1 , double* pP2 , int nP2 ,
                      int* pT1 , int nT1 , double* pF1 , double* pF2)
{ 
  const int nFeature=3;
  //printf("nTi= %d\n",nT1);
  //nT1 = np1
  for(int t=0;t<nT1;t++)
  {
    computeFeatureSimple(pP1,pT1[t*3],pT1[t*3+1],pT1[t*3+2],pF1+t*nFeature);
  }
  
  for(int i=0;i<nP2;i++)
    for(int j=0;j<nP2;j++)
      for(int k=0;k<nP2;k++)
        computeFeatureSimple(pP2,i,j,k,pF2+((i*nP2+j)*nP2+k)*nFeature);
  
}

void computeFeatureSimple( double* pP1, int i , int j, int k , double* pF)
{ 
  const int nFeature=3;
  double vecX[nFeature];
  double vecY[nFeature];
  double vecZ[nFeature];

  int ind[nFeature];
  ind[0]=i;ind[1]=j;ind[2]=k;
  double n;
  double dot,norm1,norm2;
  if((ind[0]==ind[1])||(ind[0]==ind[2])||(ind[1]==ind[2]))
  {
    pF[0]=pF[1]=pF[2]=-10;
    return;
  }
  for(int f=0;f<nFeature;f++)
  {
    vecX[f]=pP1[ind[((f+1)%3)]*3]-pP1[ind[f]*3]+0.00001;
    vecY[f]=pP1[ind[((f+1)%3)]*3+1]-pP1[ind[f]*3+1]+0.00001;
    vecZ[f]=pP1[ind[((f+1)%3)]*3+2]-pP1[ind[f]*3+2]+0.00001;
   
//     double norm=sqrt(vecX[f]*vecX[f]+vecY[f]*vecY[f]+vecZ[f]*vecZ[f]);//cross correlation
//     
//     if(norm!=0)
//     {
//       vecX[f]/=norm;
//       vecY[f]/=norm;
//       vecZ[f]/=norm;
//     }else{
//       vecX[f]=0;
//       vecY[f]=0;
//       vecZ[f]=0;
//     }
  }
  int f=0;
  for(f=0;f<nFeature;f++)
  {
    //pF[f] = vecX[((f+1)%3)]*vecY[f]-vecY[((f+1)%3)]*vecX[f];
    dot = vecX[((f+1)%3)] * vecX[f] + vecY[((f+1)%3)] * vecY[f] + vecZ[((f+1)%3)] * vecZ[f]; 
    norm1 = sqrt(vecX[((f+1)%3)]*vecX[((f+1)%3)] + vecY[((f+1)%3)]*vecY[((f+1)%3)] + vecZ[((f+1)%3)] *vecZ[((f+1)%3)]);
    norm2 = sqrt(vecX[f]*vecX[f] + vecY[f]*vecY[f] + vecZ[f]*vecZ[f]);
    pF[f] = dot/(norm1*norm2);
  }
//   //add the edge length to the later
//   vecX[f]=abs(pP1[ind[((f+1)%3)]*3]-pP1[ind[f]*3]);
//   vecY[f+1]=abs(pP1[ind[((f+1)%3)]*3+1]-pP1[ind[f]*3+1]);
//   vecZ[f+2]=abs(pP1[ind[((f+1)%3)]*3+2]-pP1[ind[f]*3+2]);
}

void computeFeature( double* pP1, int i , int j, int k , double* pF)
{ 
  const int nFeature=3;
  double vecX[nFeature];
  double vecY[nFeature];
  double vecZ[nFeature];

  int ind[nFeature];
  ind[0]=i;ind[1]=j;ind[2]=k;
  double n;
  double dot,norm1,norm2;
  if((ind[0]==ind[1])||(ind[0]==ind[2])||(ind[1]==ind[2]))
  {
    pF[0]=pF[1]=pF[2]=-10;
    return;
  }
  for(int f=0;f<nFeature;f++)
  {
    vecX[f]=pP1[ind[((f+1)%3)]*3]-pP1[ind[f]*3];
    vecY[f]=pP1[ind[((f+1)%3)]*3+1]-pP1[ind[f]*3+1];
    vecZ[f]=pP1[ind[((f+1)%3)]*3+2]-pP1[ind[f]*3+2];
   
//     double norm=sqrt(vecX[f]*vecX[f]+vecY[f]*vecY[f]+vecZ[f]*vecZ[f]);//cross correlation
//     
//     if(norm!=0)
//     {
//       vecX[f]/=norm;
//       vecY[f]/=norm;
//       vecZ[f]/=norm;
//     }else{
//       vecX[f]=0;
//       vecY[f]=0;
//       vecZ[f]=0;
//     }
  }
  for(int f=0;f<nFeature;f++)
  {
    //pF[f] = vecX[((f+1)%3)]*vecY[f]-vecY[((f+1)%3)]*vecX[f];
    dot = vecX[((f+1)%3)] * vecX[f] + vecY[((f+1)%3)] * vecY[f] + vecZ[((f+1)%3)] * vecZ[f]; 
    norm1 = sqrt(vecX[((f+1)%3)]*vecX[((f+1)%3)] + vecY[((f+1)%3)]*vecY[((f+1)%3)] + vecZ[((f+1)%3)] *vecZ[((f+1)%3)]);
    norm2 = sqrt(vecX[f]*vecX[f] + vecY[f]*vecY[f] + vecZ[f]*vecZ[f]);
    pF[f] = dot/(norm1*norm2);
  }
}
















