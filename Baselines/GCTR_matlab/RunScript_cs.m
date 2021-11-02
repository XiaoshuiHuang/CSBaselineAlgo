% Experimnts for CVPR 2017
% create by Xiaoshui Huang
% date: 2016-09-28

addPath;

%Run for T_data
folder='../cross-source-dataset';
filelist = dir(fullfile(folder, '**\*.*'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

names =  struct2cell(filelist(:,1));
[col, num] = size(names);

recall = 0;
ave_rot = 0;
ave_t = 0;
ave_rot_in = 0;
ave_t_in = 0;
ave_time = 0;
num_success = 0;
rot_threashold = 15;
t_threashold = 0.3;
for i = 0:num/4-1
    tic;
    folder = cell2mat(names(2,i*4+1));
    filename = cell2mat(names(1,i*4+1));
    T0_path= sprintf('%s/%s',folder,filename);
    T0 = importdata(T0_path);
    
    filename = cell2mat(names(1,i*4+2));
    T1_path= sprintf('%s/%s',folder,filename);
    T1 = importdata(T1_path);
    

    filename = cell2mat(names(1,i*4+3));
    kinect_path= sprintf('%s/%s',folder,filename);
    
    filename = cell2mat(names(1,i*4+4));
    lidar_sfm_path= sprintf('%s/%s',folder,filename);
 
    try
        [angle_mse, t_mse] = RunGCTR_CS(kinect_path,lidar_sfm_path,T0,T1);
    catch exception
        fprintf("error\n")
        angle_mse = 50;
        t_mse = 1.0;
    end

    timeelaps = toc;
    if angle_mse<=rot_threashold && t_mse <= t_threashold
        ave_rot_in = ave_rot_in + angle_mse; 
        ave_t_in = ave_t_in + t_mse; 
        num_success = num_success + 1;
    end
    
    ave_rot = ave_rot + angle_mse;
    ave_t = ave_t + t_mse;
    ave_time = ave_time + timeelaps;
    fprintf("pair%d: rot_error = %.3f, t_erro = %.3f, time=%.3f\n",i,angle_mse,t_mse,ave_time/(i+1));
end

recall = num_success/202;
ave_time = ave_time/202;
% display the output
fprintf("recall=%.5f, rot_err = %.3f, trans_err=%.3f, time=%.3f",recall,ave_rot_in/num_success, ave_t_in/num_success, ave_time);
