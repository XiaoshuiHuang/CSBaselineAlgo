function annquery_demo()
%ANNQUERY_DEMO A demo to show how to search and plot with ANN Wrapper
%
% [ History ]
%   - Created by Dahua Lin, on Aug 10, 2007
%

%%  Prepare Data Points
ref_pts = rand(2, 300);
query_pts = rand(2, 100);

%% Do ANN query
k = 4;
nnidx = annquery(ref_pts, query_pts, 3);

%% Plot the results
anngplot(ref_pts, query_pts, nnidx);
axis([0 1 0 1]);
