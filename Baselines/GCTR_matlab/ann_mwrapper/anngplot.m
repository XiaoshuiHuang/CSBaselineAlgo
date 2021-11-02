function anngplot(Xr, Xq, nnidx)
%ANNGPLOT Plots the nearest neighbor graph 
%
% [ Syntax ]
%   - anngplot(Xr, Xq, nnidx)
%   - anngplot -doc
%
% [ Arguments ]
%   - Xr:       the set of reference points (2 x n matrix)
%   - Xq:       the set of query points (2 x nq matrix)
%   - nnidx:    the indices of the neighbors (k x n)
%   - linespec: the specification of line plotting
%
% [ Description ]
%   - anngplot(Xr, Xq, nnidx) plots the graph showing the neighboring
%     relations, in which the neighboring points are linked with lines.
%
%     In the graph, the blue markers depict the reference points, the
%     red markers depict the query points. The neighboring relations
%     are expressed by the solid line sections in magenta color.
%
%   - anngplot -doc or anngplot('-doc') shows the HTML document of anngplot 
%     in the MATLAB embedded browser.
%
% [ Remarks ]
%   - Only 2D points are supported for plotting.
%
% [ History ]
%   - Created by Dahua Lin, on Jul 6, 2007
%

%% For help

if nargin == 1 && ischar(Xr) && strcmpi(Xr, '-doc')
    showdoc(mfilename('fullpath'));
    return;
end

%% parse and verify input arguments

error(nargchk(3, 3, nargin));

is_normal_matrix = @(x) isnumeric(x) && ndims(x) == 2 && isreal(x) && ~issparse(x);

assert(is_normal_matrix(Xr), 'ann_mwrapper:anngplot:invalidarg', 'Xr should be a numeric matrix');
assert(is_normal_matrix(Xq), 'ann_mwrapper:anngplot:invalidarg', 'Xq should be a numeric matrix');
assert(is_normal_matrix(nnidx), 'ann_mwrapper:anngplot:invalidarg', 'nnidx should be a numeric matrix');

d = size(Xr, 1);
[dq, nq] = size(Xq);

assert(d == dq, 'ann_mwrapper:anngplot:dimmismatch', 'The point dimension of Xr and Xq are not the same.');
assert(d == 2, 'ann_mwrapper:anngplot:illegaldim', 'The point dimension should be 2 for visualization.');
assert(size(nnidx, 2) == nq, 'ann_mwrapper:anngplot:sizmismatch', ...
    'The number of columns in nnidx does not equal that in Xq');
    
%% draw the graph

k = size(nnidx, 1);
qidx = repmat(1:nq, k, 1);

idx_q = qidx(nnidx > 0);
idx_r = nnidx(nnidx > 0);
ne = numel(idx_r);

x_coords = reshape([Xq(1, idx_q); Xr(1, idx_r); nan(1, ne)], 1, 3*ne);
y_coords = reshape([Xq(2, idx_q); Xr(2, idx_r); nan(1, ne)], 1, 3*ne);

edge_spec = 'm-';
qnode_spec = 'r.';
rnode_spec = 'b.';

plot(x_coords, y_coords, edge_spec, ...
     Xr(1, :), Xr(2, :), rnode_spec, ...
     Xq(1, :), Xq(2, :), qnode_spec);
 
axis equal;
