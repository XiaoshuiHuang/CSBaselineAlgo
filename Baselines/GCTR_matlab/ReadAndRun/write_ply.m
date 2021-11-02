function write_ply(fname, P,C)
% Written by Chenxi cxliu@ucla.edu
% Input: fname: output file name, e.g. 'data.ply'
%        P: 3*m matrix with the rows indicating X, Y, Z
%        C: 3*m matrix with the rows indicating R, G, B

ifColor=0;
num = size(P, 2);
m=size(C,2);
if(m>2)
    ifColor=1;
end
header = 'ply\n';
header = [header, 'format ascii 1.0\n'];
header = [header, 'comment written by XiaoshuiHuang\n'];
header = [header, 'element vertex ', num2str(num), '\n'];
header = [header, 'property float x\n'];
header = [header, 'property float y\n'];
header = [header, 'property float z\n'];
if ifColor==1
    header = [header, 'property uchar red\n'];
    header = [header, 'property uchar green\n'];
    header = [header, 'property uchar blue\n'];
end
header = [header, 'end_header\n'];

data = [P', double(C')];
%data=P';

fid = fopen(fname, 'w');
fprintf(fid, header);
dlmwrite(fname, data, '-append', 'delimiter', ' ', 'precision', 7);
fclose(fid);