 function addPath
% Add folders of predefined functions into matlab searching paths.
%
% History
%   create  -  Xiaoshui Huang (Xiaoshui.Huang@student.uts.edu.au), 28-09-2016


global footpath;
footpath = cd;

addpath('ann_mwrapper');
addpath('mex');
addpath('ReadAndRun');

