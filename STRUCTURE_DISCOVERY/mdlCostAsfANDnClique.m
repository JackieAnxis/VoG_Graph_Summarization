% Encode given graph as Full clique and Near-clique
% @param{Asmall}: the adjacent matrix of the subgraph
% @param{N_tot}: # of whole graph nodes (total)
%
% @return{MDLcost_fc}: the cost of encode the subgraph as a clique
% @return{MDLcost_nc}: the cost of encode the subgraph as a near-clique
function [MDLcost_fc, MDLcost_nc] = mdlCostAsfANDnClique(Asmall, N_tot)

    n = size(Asmall, 2);

    %% Creating the adjacency matrix for the clique model (w/o noise).
    % Note that there is no Error matrix for the near-clique model.
    %M = ones(n,n) - eye(n);
    % Error matrix.
    %E1 = xor(M,Asmall);

    % 0s in the error matrix  --- edges included in the structure (full clique)
    E(2) = nnz(Asmall); % # of NoNZero elements, included edges
    % 1s in the error matrix  --- edges excluded from the structure (full clique)
    E(1) = n^2 - n - E(2); % # of zero elements (except the diagonal), excluded edges

    %% MDL cost of encoding given substructure as a full clique
    MDLcost_fc = compute_encodingCost('fc', N_tot, n, E);
    %% MDL cost of encoding given substructure as a near clique
    MDLcost_nc = compute_encodingCost('nc', N_tot, n, Asmall);

    % % %% Printing the encoded structure.
    % % % encode as full clique
    % % fprintf(out_fid, 'fc');
    % % for i=1:size(curind, 2)
    % %     fprintf(out_fid, ' %d', top_gccind( curind(i) ) );
    % % end
    % % fprintf(out_fid, '--- full clique \n');
    % %
    % % % encode as near clique
    % % fprintf(out_fid, 'nc %d,', m/2);
    % % for i=1:size(curind, 2)
    % %     fprintf(out_fid, ' %d', top_gccind( curind(i) ) );
    % % end
    % % fprintf(out_fid, '--- nearClique \n');

end
