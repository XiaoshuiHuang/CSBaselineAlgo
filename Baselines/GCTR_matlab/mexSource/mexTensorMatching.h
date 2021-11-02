#include "Eigen/Geometry"
#include "Eigen/Dense"
using namespace Eigen;

//X is the correspondece matrix,
//H1 is the tensor output
//pX is the matrix store P1 and P2
//N1 and N2 is the rows and cols of the X or H1
void computeH1(double* X, double *H1, double *P1, int N1, double *P2, int N2, float& scale_,Eigen::Matrix<float, 4, 4>& T)
{
    int npts=(N1<N2)? N1:N2;  
	Eigen::Matrix<float, 3, Eigen::Dynamic> cloud_src(3, npts);
	Eigen::Matrix<float, 3, Eigen::Dynamic> cloud_tgt(3, npts);
	Eigen::Matrix<float, 3, Eigen::Dynamic> cloud_output(3, npts);

	Eigen::Matrix<float, 4, 4> Transformation(4,4);
    
    //the scale is computed by statistic the distance ratio of two points and their correspondences.
    // For example:   dist1= p2-p3;   dist2= p2'-p3'
    int m,n;
    int pairNum=0;
    float x2(0),y2(0),z2(0),dist1(0),dist2(0),ratio(0);
    
    for(m=0;m<N2;m++)//N2 correspondent to P1
    {
        for(n=0;n<N1;n++)// N1 correspondent to p2
        {
			//if it is a correspondence
			if (X[n + m*N1])
			{
                //add the correspondence to cloud_src   cloud_tgt
				cloud_src(0, pairNum) = P1[m * 3];
				cloud_src(1, pairNum) = P1[m * 3 + 1];
				cloud_src(2, pairNum) = P1[m * 3 + 2];
				//cloud_src(3, pairNum) = 1;
                
				cloud_tgt(0, pairNum) = P2[n * 3];
				cloud_tgt(1, pairNum) = P2[n * 3 + 1];
				cloud_tgt(2, pairNum) = P2[n * 3 + 2];
				//cloud_tgt(3, pairNum) = 1;
                
                pairNum++;
                
                //compute scale
                if(pairNum>1)
                {
					x2 = pow((cloud_src(0, pairNum - 1) - cloud_src(0, pairNum - 2)), 2);
					y2 = pow((cloud_src(1, pairNum - 1) - cloud_src(1, pairNum - 2)), 2);
					z2 = pow((cloud_src(2, pairNum - 1) - cloud_src(2, pairNum - 2)), 2);
                    dist1=sqrt(x2+y2+z2);
					x2 = pow((cloud_tgt(0, pairNum - 1) - cloud_tgt(0, pairNum - 2)), 2);
					y2 = pow((cloud_tgt(1, pairNum - 1) - cloud_tgt(1, pairNum - 2)), 2);
					z2 = pow((cloud_tgt(2, pairNum - 1) - cloud_tgt(2, pairNum - 2)), 2);
                    dist2=sqrt(x2+y2+z2);
                    if(dist1!=0)
                        ratio+=dist2/dist1;
                    else
                        int ff=0;
                }
			}//end of if
        }//end of for
    }//end of for
    
    float scale=ratio/(pairNum-1);
    
    //cloud_src=cloud_src*scale;
    cloud_src=cloud_src;
    
    //tgt-(cR*src+t)    is the objective function
	// cloud_ouput is the same dimension with cloud_src.
	Transformation = umeyama(cloud_src, cloud_tgt, cloud_output, false, scale);
	
	T = Transformation;
	scale_ = scale;

    //compute updated H1
	float meanDistance = 0.0;
	int meanNum = 0;
    for(m=0;m<N1;m++)
        for(n=0;n<N2;n++)
        {
			////if it is a correspondence
			//if (X[n + m*N2])
			////if (X[m + n*N1])
			//{
			//  //distance of two points
			//	float xDelSquare = pow(P1[m * 3] - cloud_output(0, n) - Transformation(0,3), 2);
			//	float yDelSquare = pow(P1[m * 3 + 1] - cloud_output(1, n) - Transformation(1,3), 2);
			//	float zDelSquare = pow(P1[m * 3 + 2] - cloud_output(2, n) - Transformation(2,3), 2);
			//	float distance=sqrt(xDelSquare+yDelSquare+zDelSquare);
			//	H1[n + m*N2] = distance;                
			//	//H1[m + n*N1] = distance;

			//	meanDistance += distance;
			//	meanNum += 1;
			//}

			//if it is a correspondence
			//if (X[m + n*N1])
			{
				//distance of two points
				float xDelSquare = pow(P2[m * 3] - cloud_output(0, n) - Transformation(0, 3), 2);
				float yDelSquare = pow(P2[m * 3 + 1] - cloud_output(1, n) - Transformation(1, 3), 2);
				float zDelSquare = pow(P2[m * 3 + 2] - cloud_output(2, n) - Transformation(2, 3), 2);
				float distance = sqrt(xDelSquare + yDelSquare + zDelSquare);
				//H1[n + m*N2] = distance;                
				H1[m + n*N1] = distance;

				meanDistance += distance;
				meanNum += 1;
			}
        }

	meanDistance /= meanNum;
	//compute updated H1
	for (m = 0; m<N1; m++)
	for (n = 0; n<N2; n++)
	{
		H1[n + m*N2] = 0;
		//if it is a correspondence
	    //if (X[n + m*N2])
		{
			H1[n + m*N2] = exp(-H1[n + m*N2] / meanDistance);
		}
		//H1[m + n*N1] = 0;
		////if it is a correspondence
		//if (X[m + n*N1])
		//{
		//	H1[m + n*N1] = exp(-H1[m + n*N1] / meanDistance);
		//}
	}
    
}

void tensorMatching(double* pX, double* P1, int N1, double* P2, int N2,
                          int* pIndH1, double* pValH1, int Nt1 ,
                          int* pIndH2, double* pValH2, int Nt2 ,
                          int* pIndH3, double* pValH3, int Nt3 ,
                          int nIter, int sparse, int stoc,
                          double* pXout, double* pScoreOut)
{
  //MatrixXd m = MatrixXd::Random(3,3);  
  Eigen::Matrix<float, 4, 4> Transformation(4, 4);
  float scale = 1.0;
  int NN=N1*N2;
  double* pXtemp = new double[NN];
  double* H1= new double[NN];
  double* Xtemp01 = new double[NN];
  for (int n = 0; n < NN; n++)
  {
	  pXout[n] = pX[n];
	  Xtemp01[n] = 0;
	  H1[n] = 0;
  }
  double score;
  int maxIter=100;
  int maxIter2=1;
  if( stoc == 2)
    maxIter2=10;
  //iterate 100 times for tensor matching
  for(int iter=0;iter<maxIter;iter++)
  {
    *pScoreOut=0;
    for(int n=0;n<NN;n++)
      pXtemp[n]=1*pX[n];
    //for first order
    for(int t=0;t<Nt1;t++)
    {
      if(sparse==1)
        score=pXout[pIndH1[t]];

	  else
        score=1;
      pXtemp[pIndH1[t]] += score* pValH1[t];
      if(iter==(maxIter-1))
      {
        score=pXout[pIndH1[t]];
        *pScoreOut=*pScoreOut-score*score;
      }
    }
    //for second order
    for(int t=0;t<Nt2;t++)
    {
      if(sparse==1)
        score=pXout[pIndH2[t]]*pXout[pIndH2[t+Nt2]];
      else
        score=1;
      pXtemp[pIndH2[t]] += score*pValH2[t]*pXout[pIndH2[t+Nt2]];
      pXtemp[pIndH2[t+Nt2]] += score*pValH2[t]*pXout[pIndH2[t]];
      if(iter==(maxIter-1))
      {
        score=pXout[pIndH2[t]]*pXout[pIndH2[t+Nt2]];
        *pScoreOut=*pScoreOut+2*score*score;
      }
    }
    //for third order
    for(int t=0;t<Nt3;t++)
    {
      if(sparse==1)
        score=pXout[pIndH3[t]]*pXout[pIndH3[t+Nt3]]*pXout[pIndH3[t+2*Nt3]];
      else
        score=1;
	  //for every triangle, X  Y  Z three features
	  //the node is arranged by columns
      pXtemp[pIndH3[t]] += score*
        pValH3[t]*pXout[pIndH3[t+Nt3]]*pXout[pIndH3[t+2*Nt3]];
      pXtemp[pIndH3[t+Nt3]] += score*
        pValH3[t]*pXout[pIndH3[t+2*Nt3]]*pXout[pIndH3[t]];
      pXtemp[pIndH3[t+2*Nt3]] += score*
        pValH3[t]*pXout[pIndH3[t]]*pXout[pIndH3[t+Nt3]];
      if(iter==(maxIter-1))
      {
        score= pXout[pIndH3[t]]*pXout[pIndH3[t+Nt3]]*pXout[pIndH3[t+2*Nt3]];
        *pScoreOut=*pScoreOut+3*score*score;
      }
    }
/// normalization    
    if (stoc == 0 )
    {
      double pXnorm=0;
      for(int n2=0;n2<N2;n2++)
        for(int n1=0;n1<N1;n1++)
          pXnorm+=pXtemp[n1+n2*N1]*pXtemp[n1+n2*N1];
      pXnorm=sqrt(pXnorm);
      for(int n2=0;n2<N2;n2++)
        for(int n1=0;n1<N1;n1++)
          pXout[n1+n2*N1]=pXtemp[n1+n2*N1]/pXnorm;
    }
    else
    {
      for(int n=0;n<NN;n++)
        pXout[n]=pXtemp[n];
      for(int iter2=0;iter2<maxIter2;iter2++)
      {
		int Imax;
		//normalize for each row
        for(int n2=0;n2<N2;n2++)
        {
		  //find max for each row. So initialize before each row
		  double Xmax = 0;
          double pXnorm=0;
		  //add columns together
          for(int n1=0;n1<N1;n1++)
            pXnorm+=pXout[n1+n2*N1]*pXout[n1+n2*N1];
          pXnorm=sqrt(pXnorm);
          if(pXnorm!=0)
			//normalize for each elements in this column
			for (int n1 = 0; n1 < N1; n1++)
			{
			  pXout[n1 + n2*N1] = pXout[n1 + n2*N1] / pXnorm;
			  //find the maxmum index of each column in pXout
			  Xtemp01[n1 + n2*N1] = 0;
			  if (Xmax < pXout[n1 + n2*N1])
			  {
				  Xmax = pXout[n1 + n2*N1];
				  Imax = n1 + n2*N1;
			  }

			}
			//put the max value place into 1,other place is 0
			Xtemp01[Imax] = 1;

        }
		//need to add normalize for each column. maybe        
        if( stoc == 2)
		  //normalize for each column
          for(int n1=0;n1<N1;n1++)
          {
			//find max for each row. So initialize before each row
			double Xmax = 0;
            double pXnorm=0;
			//add rows together
            for(int n2=0;n2<N2;n2++)
				pXnorm += pXout[n1 + n2*N1] * pXout[n1 + n2*N1];
            pXnorm=sqrt(pXnorm);
            if(pXnorm!=0)
			  //normalize for each elements in this row
		      for (int n2 = 0; n2 < N2; n2++)
			  {
				  pXout[n1 + n2*N1] = pXout[n1 + n2*N1] / pXnorm;
				  ////find the maxmum index of each row in pXout
				  //Xtemp01[n1 + n2*N1] = 0;
				  //if (Xmax < pXout[n1 + n2*N1])
				  //{
					 // Xmax = pXout[n1 + n2*N1];
					 // Imax = n1 + n2*N1;
				  //}
  			  }
			  ////put the max value place into 1,other place is 0
			  //Xtemp01[Imax] = 1;
          }
         
      }

    }
    
    //Xtemp1 is the correspondence, so use this correspondence to compute S R T
    //compute the new H1
	//computeH1(Xtemp01, H1, P1, N1, P2, N2, scale, Transformation);
    //pValH1=H1;//need pValH1 has memory allocated.
  }
  computeH1(Xtemp01, H1, P1, N1, P2, N2, scale, Transformation);
  FILE *fp;
  fp =fopen("pose.txt", "wt+");
  if (fp != NULL){
	  for (int i = 0; i < 4; i++)
	  {
		for (int j = 0; j < 4;j++)
		  fprintf(fp,"%f ",Transformation(i,j));
		fprintf(fp,"\n");
	  }
	  fprintf(fp,"%f",scale);
	  fclose(fp);
  }
  delete[] pXtemp;
  delete[] H1;
}



