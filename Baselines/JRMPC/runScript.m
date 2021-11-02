% Experimnts for TIP
% create by Xiaoshui Huang
% date: 2016-06-29

addpath(genpath(pwd));

Experiment=2;%% Experiment: 1 T_Data, 2 Syn_CS, 3 Real_CS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Experiment==1 
folder='../../Data/T_data/data';
tic;
% for j=1:10
%    name=sprintf('Data_%d_%d',40,j);
%    RunJPMPCT(folder,name);
% end
% for j=1:10
%    name=sprintf('Data_%d_%d',50,j);
%    RunJPMPCT(folder,name);
% end
% end
% toc;
%Run for T_data
folder='../../Data/T_data/dataOut';
for i=1:10
    for j=1:10
        name=sprintf('Data_%d_%d',i*10,j);
        RunJPMPCT(folder,name);
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Experiment==10 
%Run for Synthetic cross-source point clouds
folder='../../Data/Syn_CS/';
RunJRMPC(folder,'Twobox');
RunJRMPC(folder,'chair2part');
RunJRMPC(folder,'TM');
RunJRMPC(folder,'monitor');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Experiment==2
%Run for Synthetic cross-source point clouds
folder='../../Data/Syn_CS/CrossSyn/';
RunJRMPCS(folder,'angel');
RunJRMPCS(folder,'armadillo');
RunJRMPCS(folder,'bun_zipper');
RunJRMPCS(folder,'dragon');
RunJRMPCS(folder,'hand');
RunJRMPCS(folder,'happy');
RunJRMPCS(folder,'horse');
RunJRMPCS(folder,'lucy');
RunJRMPCS(folder,'xyzrgb_dragon');
RunJRMPCS(folder,'xyzrgb_statuette');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Experiment==3
%Run for Real cross-source point clouds
folder='../../Data/Real_CS/';
RunJRMPC(folder,'1dustbin');
RunJRMPC(folder,'2fourchair');
RunJRMPC(folder,'3LabOver');
RunJRMPC(folder,'4sofapart');
RunJRMPC(folder,'5threechair');
RunJRMPC(folder,'6TM');

end
