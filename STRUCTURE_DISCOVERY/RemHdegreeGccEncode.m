% Remove nodes with degree in top k, and encode connected components with different basic subgraph types (fc, bc, ...)
% @param{B}: adjacency matrix of a graph. We assume symmetric matrix with both upper- and lower- diagonal elements are set.
% @param{k}(2): # of nodes to cut in SlashBurn
% @param{dir}(0): direction, 0 means undirected, 1 means directed.
% @param{out_fid}: file id to output the model
% @param{top_gccind}([1:n]): node IDs of greatest connected components;
% @param{N_tot}(n):
% @param{info}(false): true for detailed output (encoding gain reported); false for brief output (no encoding gain reported)
% @param{minSize}(3): minimum size of structure that we want to encode
%
% @return{disind}: connected components nodes array (except the largest connected component)
% @return{gccind}: largest connected components nodes
% @return{topind}: nodes with degrees in top k, removed
function [disind, gccind, topind] = RemHdegreeGccEncode(B, k, dir, out_fid, top_gccind, N_tot, info, minSize)

    if nargin < 3
        dir = 1;
    end

    n = size(B, 1);

    if (dir == 1)% 邻接矩阵为有向的（非对称的）
        %D = inout_degree(B);
        D = sum(B, 2); % 按行进行求和，出度
        D = D + sum(B, 1)'; % 按行求和的结果 + 按列求和的结果；出度 + 入度
    else % 邻接矩阵为无向的（对称的）
        D = sum(B, 2); % 按行进行求和，出度
    end

    [Dsort, I] = sort(D); % 升序排列，I：Dsort的每个元素在D中的索引；

    topind = flipud(I(n - k + 1:n)); % 取倒数K个，然后降序排列（度数最大的K个节点）

    % 度数最大的K个节点的邻接表都置为0
    B(topind, :) = 0;
    B(:, topind) = 0;

    [gccind, disind] = ExtractGccEncode(B, out_fid, topind, top_gccind, N_tot, info, minSize); % encode connected components with different subgraph types
    %fullind = 1:n;
    %disind = setdiff(fullind, gccind);
    topind = topind';

    mask = ismember(disind, topind);
    disind = disind(~mask);
