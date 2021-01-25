% Encode(output) the connected component from SlashBurn: find whether it is clique, near-clique, star, chain or bipartite-core
% @param{B}: adjacency matrix of a graph. We assume symmetric matrix with both upper- and lower- diagonal elements are set.
% ? @param{curind}: nodes of the subgraph you want to encode
% ? @param{top_gccind}:
% @param{N_tot}: # of total nodes
% @param{out_fid}: file id to output the model
% @param{info}: true for detailed output (encoding gain reported) OR false for brief output (no encoding gain reported)
% @param{minSize}: minimum size of structure that we want to encode

function [] = EncodeSubgraph(B, curind, top_gccind, N_tot, out_fid, info, minSize)

    Asmall = B(curind, curind);

    n = size(curind, 2);
    m = nnz(Asmall); % 2 * # of links

    % If the structure has less than 10 nodes, do not report it in the
    % model file
    if n < minSize
        return;
    end

    %fprintf('n=%d, m=%d\n', n, m);

    %% First try to find one of the synthetic structures (vocab words):
    %   clique, star, chain, bipartite core
    exact_found = ExactStructure(Asmall, curind, top_gccind, N_tot, out_fid, info, minSize);

    %% If it is not, try encoding it as near-structure (mispelled word)
    %   and compute the MDL cost of each encoding.
    %%%%% TO DO: add some heuristics before we try to encode as chain for
    %%%%% instance -- check the degree distribution.
    maxint = 2147483647
    MDLcosts = ones(1, 5) * maxint;

    if (exact_found == false)
        % not exactly found, computing mdl encoding of different types
        [MDLcostFC, MDLcostNC] = mdlCostAsfANDnClique(Asmall, N_tot);
        [MDLcostST, hub, spokes] = mdlCostAsStar(Asmall, curind, N_tot);
        [MDLcostBC, MDLcostNB, set1, set2] = mdlCostAsBCorNB(Asmall, N_tot);
        MDLcosts = [MDLcostFC, MDLcostNC, MDLcostST, MDLcostBC, MDLcostNB];

        if m < 1.5 * n
            %? it does not make sense. "m" means twice the number of links, "n" means number of nodes.
            %? Thus, "m < 1.5 * n" means the number of links is less than 75% of the number of nodes.
            %? I dont think such un-connected subgraph can be encoded as chain
            [MDLcostCH, chain] = mdlCostAsChain(Asmall, N_tot);
            MDLcosts = [MDLcosts, MDLcostCH];
        end

        % Find which structure best describes the given submatrix: i.e., find the
        % structure that has the minimum MDL cost. Then output to the model file
        % this structure and its encoding gain in bits (mdlcostNC -
        % mdlCostStructure).
        [~, idxMin] = min(MDLcosts);

        cost_notEnc = compute_encodingCost('err', 0, 0, [nnz(Asmall) n^2 - nnz(Asmall)]);

        if isinf(MDLcosts(idxMin)) || isinf(MDLcosts(2))
            % if minimun cost or the near-clique cost are not infinity
            costGain_notEnc = cost_notEnc - MDLcostNC;
            encodeAsNClique(curind, top_gccind, m, 0, costGain_notEnc, out_fid, info);
            %fprintf(out_fid, ' nan\n');
        else

            switch idxMin
                case 1
                    costGain = MDLcostNC - MDLcostFC;
                    costGain_notEnc = cost_notEnc - MDLcostFC;
                    encodeAsFClique(curind, top_gccind, costGain, costGain_notEnc, out_fid, info);
                case 2
                    costGain = MDLcostNC - MDLcostNC;
                    costGain_notEnc = cost_notEnc - MDLcostNC;
                    m = nnz(Asmall);
                    encodeAsNClique(curind, top_gccind, m, costGain, costGain_notEnc, out_fid, info);
                case 3
                    costGain = MDLcostNC - MDLcostST;
                    costGain_notEnc = cost_notEnc - MDLcostST;
                    encodeAsStar(curind, top_gccind, hub, spokes, costGain, costGain_notEnc, out_fid, info);
                case 4
                    costGain = MDLcostNC - MDLcostBC;
                    costGain_notEnc = cost_notEnc - MDLcostBC;
                    encodeAsBC(curind, top_gccind, set1, set2, costGain, costGain_notEnc, out_fid, info);
                case 5
                    costGain = MDLcostNC - MDLcostNB;
                    costGain_notEnc = cost_notEnc - MDLcostNB;
                    encodeAsNB(curind, top_gccind, set1, set2, costGain, costGain_notEnc, out_fid, info);
                case 6
                    costGain = MDLcostNC - MDLcostCH;
                    costGain_notEnc = cost_notEnc - MDLcostCH;
                    encodeAsChain(curind, top_gccind, chain, costGain, costGain_notEnc, out_fid, info);
                otherwise
                    error_message = 'error: impossible to get this error...\n'
            end

        end

    end

end
