% Experimnts for CVPR 2017
% create by Xiaoshui Huang
% date: 2016-09-28

addPath;

Experiment=1;%% Experiment: 1 T_Data, 2 Syn_CS, 3 Real_CS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(Experiment==1)
% folder='../../Data/T_data/data';
% tic;
% for j=1:10
%    name=sprintf('Data_%d_%d',40,j);
%    RunGCTRT(folder,name);
% end
% for j=1:10
%    name=sprintf('Data_%d_%d',50,j);
%    RunGCTRT(folder,name);
% end
% end
% toc;
%Run for T_data
folder='../../Data/T_data/dataOut';
for i=1:10
    for j=1:10
        name=sprintf('Data_%d_%d',i*10,j);
        RunGCTRTT(folder,name);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Experiment==2
%Run for Synthetic cross-source point clouds
folder='../../Data/Syn_CS/CrossSyn/';
RunGCTRS(folder,'angel');
RunGCTRS(folder,'armadillo');
RunGCTRS(folder,'bun_zipper');
RunGCTRS(folder,'dragon');
RunGCTRS(folder,'hand');
RunGCTRS(folder,'happy');
RunGCTRS(folder,'horse');
RunGCTRS(folder,'lucy');
RunGCTRS(folder,'xyzrgb_dragon');
RunGCTRS(folder,'xyzrgb_statuette');
end

if Experiment==4
    %Run for Synthetic cross-source point clouds
    folder='../../Data/Syn_CS/CVPR2017/';
    RunGCTRN(folder,'angel');
    RunGCTRN(folder,'armadillo');
    RunGCTRN(folder,'bun_zipper');
    RunGCTRN(folder,'dragon');
    RunGCTRN(folder,'hand');
    RunGCTRN(folder,'happy');
    RunGCTRN(folder,'horse');
    RunGCTRN(folder,'lucy');
    RunGCTRN(folder,'xyzrgb_dragon');
    RunGCTRN(folder,'xyzrgb_statuette');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Experiment==3
%Run for Real cross-source point clouds
folder='../../Data/Real_CS/';
% RunGCTR(folder,'1dustbin');
% RunGCTR(folder,'2fourchair');
% RunGCTR(folder,'3LabOver');
% RunGCTR(folder,'4sofapart');
% RunGCTR(folder,'5threechair');
% RunGCTR(folder,'6TM');
RunGCTR(folder,'computercluster1');
RunGCTR(folder,'corner2');
RunGCTR(folder,'lab31');
RunGCTR(folder,'oldercomputer2');
end