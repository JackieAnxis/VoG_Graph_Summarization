% Encode given graph as star
% @param{Asmall}: the adjacent matrix of the subgraph
% ? @param{curind}: not needed
% @param{N_tot}: # of whole graph nodes (total)
%
% @return{MDLcost}: the cost of encode the subgraph as a star
% @return{idxMaxDeg}: the index of the node with the max degree in Asmall
% @return{satellitesIdx}: indeces of the satellite nodes in Asmall
function [MDLcost, idxMaxDeg, satellitesIdx] = mdlCostAsStar(Asmall, curind, N_tot)

    n = size(Asmall, 2);
    deg = full(sum(Asmall));

    if n < 3
        return
    end

    [~, idxMaxDeg] = max(deg);

    if idxMaxDeg ~= 1 && idxMaxDeg ~= n
        satellitesIdx = [1:(idxMaxDeg - 1), (idxMaxDeg + 1):n];
    elseif idxMaxDeg == 1
        satellitesIdx = 2:n;
    elseif idxMaxDeg == n
        satellitesIdx = 1:(n - 1);
    end

    %% Creating the adjacency matrix for the star model (w/o noise).
    % % M(n,n) = 0;
    % % for i = 1 : length( satellitesIdx )
    % %    M( idxMaxDeg, satellitesIdx(i) ) = 1;
    % %    M( satellitesIdx(i), idxMaxDeg ) = 1;
    % % end
    % % % Error matrix.
    % % E1 = xor(M,Asmall);
    % %
    % % Einc1 = nnz(E1)
    % % Eexc1 = sum(E1(:)==0)

    % 1s in the error matrix
    % wrong edges: missing edges in star + extra edges not in star
    E(1) = 2 * (n - 1 - nnz(Asmall(idxMaxDeg, :))) + nnz(Asmall(satellitesIdx, satellitesIdx));
    % right edges
    E(2) = n^2 - E(1);

    if E(1) < 0 || E(2) < 0
        E
        n
        nnz(Asmall(idxMaxDeg, :))
    end

    %% MDL cost of encoding given substructure as a star
    MDLcost = compute_encodingCost('st', N_tot, n, E);

    % % %% Printing the encoded structure.
    % % fprintf(out_fid, 'st %d,', top_gccind( curind(idxMaxDeg) ) );
    % % fprintf(out_fid, ' %d', top_gccind( curind(satellitesIdx) ) );
    % % fprintf(out_fid, '  --- nearStar \n');

    % % check if we have a tie (multiple highest-degree nodes)
    % idx_center = find( deg == deg(idxMaxDeg) );
    %
    % for i = 1 : length(idx_center)
    %  :   idxMaxDeg = idx_center(i);
    %     fprintf(out_fid, 'st %d,', top_gccind( curind(idxMaxDeg) ) );
    %
    %     if idxMaxDeg ~= 1 && idxMaxDeg ~= n
    %         satellitesIdx = curind( [1 : (idxMaxDeg-1), (idxMaxDeg+1):n] );
    %     elseif idxMaxDeg == 1
    %         satellitesIdx = curind( 2:n );
    %     elseif idxMaxDeg == n
    %         satellitesIdx = curind( 1:(n-1) );
    %     end
    %     fprintf(out_fid, ' %d', top_gccind( satellitesIdx ) );
    %     fprintf(out_fid, '\n');
    % end

end
