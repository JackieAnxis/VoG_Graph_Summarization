%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
%                                                                           %
% Parameter                                                                 %
%   B: adjacency matrix of a graph. We assume symmetric matrix with    		%
%           both upper- and lower- diagonal elements are set.               %
%   k(2): # of nodes to cut in SlashBurn                                    %
%	dir(0): direction, 0 means undirected, 1 means directed.				%
%   out_fid: file id to output the model                               		%
%   topind: top k nodes with largest degree                                 %
%	top_gccind([1:n]): node IDs of greatest connected components; 			%
%	N_tot(n): 																%
%   info(false): true for detailed output (encoding gain reported)			%
%		         false for brief output (no encoding gain reported)			%
%   minSize(3): minimum size of structure that we want to encode			%
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cur_gccind,cur_disind] = ExtractGccEncode(B, out_fid, topind, top_gccind, N_tot, info, minSize)

% Find strongly or weakly connected components in graph
% A weakly connected component is a maximal group of nodes that are mutually reachable by violating the edge directions.
% Find the number of strongly connected components in the directed graph and determine to which component each of the 10 nodes belongs.
% S: 连通子图的个数；C：数组，表示每个节点属于哪个连通子图
[S, C] = graphconncomp(B, 'WEAK', true);

maxind = -1;
maxsize = 0;

% 记录不同的connected components的size
size_v = zeros(0, S);
for k = 1:S
    size_v(k) = size(find(C == k), 2);
end

[size_sort, I] = sort(size_v, 'descend'); % 降序排列

cur_gccind = find(C == I(1)); % 属于最大的连通子图的节点

cur_disind = zeros(0, 0);

for k = 2:S
    curind = find(C == I(k)); % 属于第k个连通子图的节点
    if (size(curind, 2) == 1) % size为1，孤立节点
        % 判断该孤立节点是否在topind（度数最大的几个节点）中
        % 是为1，不是为0
        mask = ismember(curind, topind);
        if sum(mask) == 1 % 该节点在topind中，也即说明度数为0的孤立节点已经是最高的K个节点了
            continue;
        end
    end
    % TODO
    if length(curind) > minSize
        % EncodeConnComp(B, curind, top_gccind, out_fid);
        EncodeSubgraph(B, curind, top_gccind, N_tot, out_fid, info, minSize);
    end
    cur_disind = [cur_disind curind];
end

% fprintf('\tgccsize\t%d\n', size(cur_gccind,2));

