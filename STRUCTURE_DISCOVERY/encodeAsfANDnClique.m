% Encode given graph as clique and near-clique
% @param{Asmall}:
%? @param{curind}:
%? @param{top_gccind}:
% @param{out_fid}: output file id
%
% Output is stored in the model file in the form:
% fc nodes_in_the_clique
% OR
% nc number_of_links, nodes_in_the_near_clique
function [] = encodeAsfANDnClique(Asmall, curind, top_gccind, out_fid)

    n = size(curind, 2);
    m = nnz(Asmall);

    % encode as full clique
    fprintf(out_fid, 'fc');

    for i = 1:size(curind, 2)
        fprintf(out_fid, ' %d', top_gccind(curind(i)));
    end

    fprintf(out_fid, '--- full clique \n');

    % encode as near clique
    fprintf(out_fid, 'nc %d,', m / 2);

    for i = 1:size(curind, 2)
        fprintf(out_fid, ' %d', top_gccind(curind(i)));
    end

    fprintf(out_fid, '--- nearClique \n');

end
