function [angle_mse, t_mse]=RunJPMPCT_cs(kinectPly,sfmPly,T0,T1)
% Experiments for CVPR 2016
% create by Xiaoshui Huang
% Date: 2016-10-02

% given an angle theta in radians angle2rotation(theta) construtcts a 
% rotation matrix, rotating a vector with angle theta along all three axes.
% Right hand convention is used for the rotation around the perpendicular.
angle2rotation = @(theta) [1 0 0;0 cos(theta) -sin(theta);0 sin(theta) cos(theta)] ...
                         *[cos(theta) 0 sin(theta);0 1 0;-sin(theta) 0 cos(theta)] ...
                         *[cos(theta) -sin(theta) 0;sin(theta) cos(theta) 0; 0 0 1];
tic;
% colors for each view
clrmap = {[1 1 0]; [0 1 1]};
% markerSizes 
markerSize = {7; 70};
% markers
%marker = {'s'; 'x'; '.'; '^'};
marker = {'s'; 'x'};
% number of iterations to be run
maxNumIter = 100;                                         
% number of views, M files must be found in the directory ./syntheticData 
M = 2;
% cell with indexes 1:M, used as suffixes on view's filenames
idx = transpose(1:M);
% string-labels for legends in subsequent plots
strIdx = arrayfun(@(j) sprintf('duck%d',j),idx,'uniformoutput',false);

downRate2=1; downRate1=1;

%fprintf(' Data loading %s...\n',dataset);

% read ply files
%%------------------------------------------------------------------------
% V1 is SFM, V2 is Kinect,
% Transform V1 to V2. From SFM to Kinect
% 
 
%sfmPly   =sprintf('%s/%s_p1.ply',path,dataset);
% V{1,1}=read_ply(sfmPly)';
% V{2,1}=read_ply(kinectPly)';
V{1,1}=read_ply(kinectPly)';
V{2,1}=read_ply(sfmPly)';
V{1}=V{1}(1:3,:);
V{2}=V{2}(1:3,:);


% down-sample point cloud
n1=size(V{1},2);
n2=size(V{2},2);
if(n1>2000)
    downRate1=round(n1/2000);
end
if(n2>2000)
    downRate2=round(n2/2000);
end
V{1}=(downsample(V{1}',downRate1))';
V{2}=(downsample(V{2}',downRate2))';

R = T0(1:3,1:3)/T1(1:3,1:3);
t_gt =  (T1(1:3,4) - T0(1:3,4))'/T1(1:3,1:3);
angle_gt = rotm2eul(R);

% initialize GMM means Xin, using random sampling of a unit sphere. Choose
% your own initialization. You may want to initialize Xin with some of the
% sets.
%%----------------------------------------------------------------------
% set K as the 50% of the median cardinality of the views
K = ceil(0.5*median(cellfun(@(V) size(V,2),V))); 

% sample the unit sphere, by randomly selecting azimuth / elevation angles
az = 2*pi*rand(1,K);
el = 2*pi*rand(1,K);

%points on a unit sphere
Xin = [cos(az).*cos(el); sin(el); sin(az).*cos(el)];% (unit) polar to cartesian conversion

Xin = Xin/10; % it is good for the initialization to have initial cluster centers at the same order with the points
% since sigma is automatically initialized based on X and V
%%-----------------------------------------------------------------------

%fprintf('Data registration... \n\n');

% Generative GMM registration 
%%-----------------------------------------------------------------------
% call JRMPC (type jrmpc with no arguments to see the documentation).
[R,t,X,S,a,~,T] = jrmpc(V,Xin,'maxNumIter',maxNumIter,'gamma',0.1);
%%-----------------------------------------------------------------------

TV = cellfun(@(V,R_iter,t_iter) bsxfun(@plus,R_iter*V,t_iter),V,T(:,1,100),T(:,2,100),'uniformoutput',false);

RR=R{1}\R{2};
T=(t{2}-t{1})\R{2};

angle_est = rotm2eul(RR);
t_est = T;

angle_mse=norm(angle_est-angle_gt,'fro')*180/3.14;
t_mse=norm(t_est-t_gt,'fro');
 

