function [] = RunGCTR(path,dataset)

tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% --------Read Ply point cloud---------%%
% These PLY are represented structure points
kinectPly=sprintf('%s/%s/sfm.ply',path,dataset);
sfmPly=sprintf('%s/%s/kinect.ply',path,dataset);

X=read_ply(kinectPly);
P1=X(:,1:3)';
Y=read_ply(sfmPly);
P2=Y(:,1:3)';

nP1=size(P1,2);
nP2=size(P2,2);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%------------Initialization:  1.Build Third and First order Tensor, 2.initialize X
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

file = fopen('pose.txt', 'r');
TT = fscanf(file, '%f', [4,4])';
R=TT(1:3,1:3);
T=TT(1:3,4);
s = fscanf(file, '%f', 1);
fclose(file);

path1=sprintf('%s/%s/GCTR_T_compute.txt',path,dataset);
TT=[T;[1]];
T_compute=[R;[0,0,0]];
T_compute=[T_compute,TT];
dlmwrite(path1,T_compute,' ');

sfmPly=sprintf('%s/%s/src_kinect.ply',path,dataset);
kinectPly=sprintf('%s/%s/src_sfm_scaled.ply',path,dataset);
cmd=sprintf('TransformPointCloudByT.exe %s %s %s',kinectPly,sfmPly,path1);
system(cmd);

toc;
fprintf('completed!\n');
%% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
