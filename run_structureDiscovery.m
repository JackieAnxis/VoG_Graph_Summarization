input_file = 'DATA/cliqueStarClique.out';
unweighted_graph = input_file;
output_model_greedy = 'DATA';
output_model_top10 = 'DATA';

addpath('STRUCTURE_DISCOVERY');

% 开始构建邻接矩阵（无向无环图）
orig = spconvert(load(input_file)); % 读取图文件（将数据文件转换为稀疏矩阵）
% 上述矩阵并非是方阵，所以下面的代码将其转化为方阵
orig(max(size(orig)), max(size(orig))) = 0;
% 原始方阵+原始方阵的转置，转化为无向图
orig_sym = orig + orig';
[i, j, k] = find(orig_sym); % 返回非零cell的索引，(i, j)代表矩阵的索引坐标，k表示值
orig_sym(i(find(k == 2)), j(find(k == 2))) = 1; % 改为0, 1矩阵
orig_sym_nodiag = orig_sym - diag(diag(orig_sym)); % 去掉自环
% 邻接矩阵构建完毕

disp('==== Running VoG for structure discovery ====')
global model;
model = struct('code', {}, 'edges', {}, 'nodes1', {}, 'nodes2', {}, 'benefit', {}, 'benefit_notEnc', {});
global model_idx;
model_idx = 0;
% 1. orig_sym_nodiag: 对称邻接矩阵（无向）
% 2. 2:
% 3. output_model_greedy: 输出路径
% 4. false:
% 5. false:
% 6. 3:
% 7. unweighted_graph: 图文件的输入路径
SlashBurnEncode(orig_sym_nodiag, 2, output_model_greedy, false, false, 3, unweighted_graph);

% quit
