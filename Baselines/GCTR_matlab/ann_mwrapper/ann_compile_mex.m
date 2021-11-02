function ann_compile_mex()
%ANN_COMPILE_MEX Compiles the core-mex files of the ANN Lib
%
% [ Syntax ]
%   - ann_compile_mex
%
% [ Description ]
%   - ann_compile_mex re-compiles the mex files.
%     
% [ History ]
%   - Created by Dahua Lin, on Jul 06, 2007
%


%% configurations

% When you intend to change the configuration, please modify the following
% lines

ann_lib_root = 'ann_1.1.1';

ann_src_dir = [ann_lib_root, '/src'];
ann_inc_dir = [ann_lib_root, '/include'];

options = {'-O', '-v'};


%% main

main_file = 'private/ann_mex.cpp';
output_dir = 'private';

src_files = { ...
    'ANN.cpp', ...
    'bd_fix_rad_search.cpp', ...
    'bd_pr_search.cpp', ...
    'bd_search.cpp', ...
    'bd_tree.cpp', ...
    'brute.cpp', ...
    'kd_dump.cpp', ...
    'kd_fix_rad_search.cpp', ...
    'kd_pr_search.cpp', ...
    'kd_search.cpp', ...
    'kd_split.cpp', ...
    'kd_tree.cpp', ...
    'kd_util.cpp', ...
    'perf.cpp' };

check_exist(main_file);

src_paths = cell(size(src_files));
for i = 1 : length(src_files)
    src_paths{i} = [ann_src_dir '/' src_files{i}];
    check_exist(src_paths{i});
end

mex(options{:}, ['-I', ann_inc_dir], '-outdir', output_dir, main_file, src_paths{:});    


function check_exist(path)

if ~exist(path, 'file')
    error('ann_mwrapper:ann_compile_mex:filenotfound', ...
        'The file %s is not found', path);
end
    
    
    