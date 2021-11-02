
addpath('ann_mwrapper');
addpath('mex');
tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%produce synthetic data
%number of point in image 1
nP1=50;
%number of point in image 2
nP2=nP1;

%randomly generate them
P1=randn(3,nP1);

%generate modified version of points 1
scale= 0.5+rand();
theta = 0.5*rand();
Mrot = [cos(theta) 0 sin(theta);0 1 0;-sin(theta) 0 cos(theta)]; %rotate y axis
T=[5,5,5]';
MrotR=1.0/scale*Mrot;
P2=bsxfun(@plus,scale*Mrot*P1,T);

%%write ground-truth transformation to txt file
Transformation_T=[Mrot,T];
Transformation_T=[Transformation_T;[0,0,0,1]];
Transformation_T=[Transformation_T;[scale,0,0,0]];
dlmwrite('pose_gt.txt',Transformation_T,'precision','%.6f','delimiter',' ');
%add noise
noise_DB=30;
P2 = awgn(P2,noise_DB,'measured');%add SNR = 40db Gaussian noise

%outliers
Knum=10;
V_sample= datasample(P2',Knum,'Replace',false);
%max and min element in matrix
minV=min(P2(:));
maxV=max(P2(:));
%produce row*k uniform signal
s = rng;
outlier=(5*rand(Knum,3)-1)*((maxV-minV)/10);
outlier=V_sample+outlier;
P2=[P2,outlier'];
nP2=nP2+Knum;

saveCorrespondecePath='./correspondence3.txt';
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%
% %read real data
% % read sfm ply
% dataset='corner4';
% path=sprintf('./%s/sfm.txt',dataset);
% P1=dlmread(path,' ');
% P1=P1(:,1:3)';
% nP1=size(P1,2);
% % read Kinect ply
% path=sprintf('./%s/kinect.txt',dataset);
% P2=dlmread(path,' ');
% P2=P2(:,1:3)';
% nP2=size(P2,2);
% % The last row is camera property of ply. remove it
% nP1=nP1-1;
% P1=P1(:,1:nP1);
% nP2=nP2-1;
% P2=P2(:,1:nP2);
% saveCorrespondecePath=sprintf('./%s/correspondenceTensor.txt',dataset);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [m1,n1]=size(P1);
% [m2,n2]=size(P2);
% downRate1=1;
% downRate2=1;
% if(n1>1200)
%     downRate1=int8(n1/300);
% end
% if(n2>1200)
%     downRate2=int8(n2/300);
% end
% P1=(downsample(P1',downRate1))';
% P2=(downsample(P2',downRate2))';
% nP1=size(P1,2);
% nP2=size(P2,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% served for third-order tensor
%Random triangles and ANN algorithm
%number of used triangles (results can be bad if too low)
nT=nP1*nP2;
t1=floor(rand(3,nT)*nP1);
while 1
  probFound=false;
  for i=1:3
    ind=(t1(i,:)==t1(1+mod(i,3),:));
    if(nnz(ind)~=0)
      t1(i,ind)=floor(rand(1,nnz(ind))*nP1);
      probFound=true;
    end
  end
  if(~probFound)
    break;
  end
end
% %generate features
%t1=int32(t1);
[feat1,feat2] = mexComputeFeature(P1,P2,int32(t1),'simple');

%number of nearest neighbors used for each triangle (results can be bad if
%too low)
nNN=300;    
%find the nearest neighbors
[inds, dists] = annquery(feat2, feat1, nNN, 'eps', 10);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%build third and first tensor
%%%%%%%%%----build the third tensor----%%%%%%%%%
%%
close all;
A=randperm(nT);
XXX = sort(A);

[i j k]=ind2sub([nP2,nP2,nP2],inds);
tmp=repmat(1:nT,nNN,1);
fdsfs=double(t1(:,tmp(:))');
indH = double(t1(:,tmp(:))')*nP2 + [k(:)-1 j(:)-1 i(:)-1];% ?????? ????? N1*N2
valH = exp(-dists(:)/mean(dists(:)));
%%
%%%%%%%%%------------------------------%%%%%%%%%

%%%%%%%%%----build the first tensor----%%%%%%%%%
%%
% build initial first order
% used for small dataset
% X=P1';
% Y=P2';
% used for large dataset
X= unique(t1);
Xp=P1(:,int32(X(:))+1);
t1Np1=size(Xp,2);
ij=union(i,j);
ijk=union(ij,k);
Y=unique(ijk);
Yp=P2(:,int32(Y(:)));
t1Np2=size(Yp,2);
[Idx,D] = annquery(Yp,Xp,t1Np2,'eps',10);%this is right, each colunm in Idx are K-nearest neighbors of Xp.
tmp1=repmat(1:t1Np1,t1Np2,1)-1;
indH1=double(tmp1(:))*t1Np2+ double(Idx(:)-1);
valH1=exp(-D(:)/mean(D(:)));%each row in D are the same-level nearest neighbor of Xp points (2-th nearest or 3-th nearest).
%%%%%%%%%------------------------------%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initiatialize X
X=1/nP2*ones(nP2,nP1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%Tensor graph matching
%power iteration
[X2, score]=tensorMatching(X,P1,P2,indH1,valH1,[],[],indH,valH);
%[X2, score]=tensorMatching(X,P1,P2,[],[],[],[],indH,valH);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%display the tensor graph matching  results
%draw
if 1
  figure(1);
  imagesc(X2);
  figure;
  title('Tensor-based graph matching','FontSize',20);
  hold on;
  plot(P1(1,:),P1(2,:),'r x');
  plot(P2(1,:),P2(2,:),'b o');
  [tmp match] = max(X2);
  %convert match to Xm
  indexN=size(match,2);
  A=randperm(indexN);
  hh=size(X2);
  m=size(match,2);
  Xm=zeros(hh);  
  for i=1:m
      j=match(i);
      Xm(j,i)=1;
  end
  %write correspondence to file
  writeCorrespondence(Xm', saveCorrespondecePath);
  %draw lines
  for p=1:nP1
    plot([P1(1,p),P2(1,match(p))],[P1(2,p),P2(2,match(p))],'k- ');
  end
end
toc;
fprintf('completed!\n');
%% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%