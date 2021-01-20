
.function [disind,gccind,topind] = RemHdegreeGccEncode(B,k,dir,out_fid, top_gccind, N_tot, info, minSize)


if nargin < 3
    dir = 1;
end

n = size(B, 1);

if (dir == 1) % 邻接矩阵为有向的（非对称的）
	%D = inout_degree(B);
	D = sum(B, 2); % 按行进行求和，出度
	D = D + sum(B, 1)'; % 按行求和的结果 + 按列求和的结果；出度 + 入度
else % 邻接矩阵为无向的（对称的）
	D = sum(B, 2); % 按行进行求和，出度
end
[Dsort, I] = sort(D); % 升序排列，I：Dsort的每个元素在D中的索引；

topind = flipud(I(n-k+1:n)); % 取倒数K个，然后降序排列（最大的K个）

B(topind, :) = 0;
B(:, topind) = 0;

[gccind,disind] = ExtractGccEncode(B, out_fid, topind, top_gccind, N_tot, info, minSize );
%fullind = 1:n;
%disind = setdiff(fullind, gccind);
topind = topind';

mask = ismember(disind, topind);
disind = disind(~mask);
