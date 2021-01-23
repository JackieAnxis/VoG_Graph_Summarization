% Test whether Asmall is exactly a pre-defined structure, if so, output it with its nodes into out_fid
% @param{Asmall}: adjacency matrix of the subgraph.
% ? @param{curind}: nodes of the subgraph you want to encode
% ? @param{top_gccind}:
% @param{N_tot}: # of total nodes
% @param{out_fid}: file id to output the model
% @param{info}: true for detailed output (encoding gain reported) OR false for brief output (no encoding gain reported)
% @param{minSize}: minimum size of structure that we want to encode
%
% @return{exact_found}: whether Asmall is exactly a pre-defined structure (fc, bc, ...)
function [exact_found] = ExactStructure(Asmall, curind, top_gccind, N_tot, out_fid, info, minSize)

    global model;
    global model_idx;

    % Asmall = B(curind,curind);

    exact_found = false;
    n = size(curind, 2);
    m = nnz(Asmall);

    if n == 1
        return;
    end

    %fprintf('n=%d, m=%d\n', n, m);

    % cost of encoding the structure as near-clique
    MDLcost_nc = compute_encodingCost('nc', N_tot, n, Asmall);
    % cost of not encoding the structure at all (noise)
    cost_notEnc = compute_encodingCost('err', 0, 0, [nnz(Asmall) n^2 - nnz(Asmall)]);

    if (m == n * n - n)
        % full clique

        if n >= 2
            % more than two nodes
            MDLcost_fc = compute_encodingCost('fc', N_tot, n, zeros(n, n));
            costGain = MDLcost_nc - MDLcost_fc;
            costGain_notEnc = cost_notEnc - MDLcost_fc;
            fprintf(out_fid, 'fc');

            for i = 1:size(curind, 2)
                fprintf(out_fid, ' %d', top_gccind(curind(i)));
            end

            if info == false
                fprintf(out_fid, '\n');
            else
                fprintf(out_fid, ', %f | %f -- exact \n', costGain, costGain_notEnc);
            end

            exact_found = true;
            model_idx = model_idx + 1;
            model(model_idx) = struct('code', 'fc', 'edges', 0, 'nodes1', top_gccind(curind), 'nodes2', [], 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
        else
            % 2-nodes clique: a chain
            MDLcost_ch = compute_encodingCost('ch', N_tot, n, zeros(n, n));
            costGain = MDLcost_nc - MDLcost_ch;
            costGain_notEnc = cost_notEnc - MDLcost_ch;
            fprintf(out_fid, 'ch');
            fprintf(out_fid, ' %d', top_gccind(curind(1:2)));

            if info == false
                fprintf(out_fid, '\n');
            else
                fprintf(out_fid, ', %f | %f -- exact \n', costGain, costGain_notEnc);
            end

            exact_found = true;
            model_idx = model_idx + 1;
            model(model_idx) = struct('code', 'ch', 'edges', 0, 'nodes1', top_gccind(curind), 'nodes2', [], 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
        end

    elseif (m == 2 * (n - 1))
        % maybe chain or star
        degree = sum(Asmall); % degree of each node
        ind = find(degree > 0); % un-isolated nodes
        d1count = 0; % count nodes with 1-degree
        d2count = 0; % count nodes with 2-degree
        dn1count = 0; % count nodes with (n - 1)-degree

        for i = 1:size(degree, 2)

            if (degree(i) == 1)
                d1count = d1count + 1;
            elseif degree(i) == 2
                d2count = d2count + 1;
            elseif degree(i) == n - 1
                dn1count = dn1count + 1;
            end

        end

        if d1count == 2 && d2count == n - 2
            % chain, with 2 nodes with 1-degree and n - 2 nodes with 2-degree
            MDLcost_ch = compute_encodingCost('ch', N_tot, n, zeros(n, n));
            costGain = MDLcost_nc - MDLcost_ch;
            costGain_notEnc = cost_notEnc - MDLcost_ch;
            fprintf(out_fid, 'ch');
            d1ind = find(degree == 1);
            fprintf(out_fid, ' %d', top_gccind(curind(d1ind(1))));

            d2ind = find(degree == 2);
            % output 2-degree nodes id
            fprintf(out_fid, ' %d', top_gccind(curind(d2ind(1:size(d2ind, 2)))));
            % output the two 1-degree nodes id
            fprintf(out_fid, ' %d', top_gccind(curind(d1ind(2))));

            if info == false
                fprintf(out_fid, '\n');
            else
                fprintf(out_fid, ', %f | %f -- exact \n', costGain, costGain_notEnc);
            end

            exact_found = true;
            model_idx = model_idx + 1;
            model(model_idx) = struct('code', 'ch', 'edges', 0, 'nodes1', [top_gccind(curind(d1ind(1))) top_gccind(curind(d2ind(1:size(d2ind, 2)))) top_gccind(curind(d1ind(2)))], 'nodes2', [], 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
        end

    else
        opts.tol = 1e-2;
        evals = eigs(Asmall, 2, 'lm', opts); % 2 eigenvalues with largest maganitudes

        if (max(evals) == -min(evals))
            % if the opposite of the max eigenvalue is also Asmall's eigenvalue,
            % it is a bipartite graph (special case: star) maybe not a bipartite cire.
            [set1, set2] = BFScoloring(Asmall);

            if length(set1) + length(set2) < minSize
                exact_found = true;
                return;
            end

            if length(set1) == 1 && length(set2) == 1
                % 2-nodes chain is also a special case
                MDLcost_ch = compute_encodingCost('ch', N_tot, n, zeros(n, n));
                costGain = MDLcost_nc - MDLcost_ch;
                costGain_notEnc = cost_notEnc - MDLcost_ch;
                fprintf(out_fid, 'ch');
                fprintf(out_fid, ' %d', top_gccind(curind([set1, set2])));

                if info == false
                    fprintf(out_fid, '\n');
                else
                    fprintf(out_fid, ', %f | %f -- exact \n', costGain, costGain_notEnc);
                end

                exact_found = true;
                model_idx = model_idx + 1;
                model(model_idx) = struct('code', 'ch', 'edges', 0, 'nodes1', top_gccind(curind([set1, set2])), 'nodes2', [], 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
            elseif length(set1) == 1
                % star
                MDLcost_st = compute_encodingCost('st', N_tot, n, zeros(n, n));
                costGain = MDLcost_nc - MDLcost_st;
                costGain_notEnc = cost_notEnc - MDLcost_st;
                fprintf(out_fid, 'st %d,', top_gccind(curind(set1)));
                fprintf(out_fid, ' %d', top_gccind(curind(set2)));

                if info == false
                    fprintf(out_fid, '\n');
                else
                    fprintf(out_fid, ', %f | %f -- exact \n', costGain, costGain_notEnc);
                end

                exact_found = true;
                model_idx = model_idx + 1;
                model(model_idx) = struct('code', 'fc', 'edges', 0, 'nodes1', top_gccind(curind), 'nodes2', [], 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
            elseif length(set2) == 1
                % star
                MDLcost_st = compute_encodingCost('st', N_tot, n, zeros(n, n));
                costGain = MDLcost_nc - MDLcost_st;
                costGain_notEnc = cost_notEnc - MDLcost_st;
                fprintf(out_fid, 'st %d,', top_gccind(curind(set2)));
                fprintf(out_fid, ' %d', top_gccind(curind(set1)));

                if info == false
                    fprintf(out_fid, '\n');
                else
                    fprintf(out_fid, ', %f | %f -- exact \n', costGain, costGain_notEnc);
                end

                exact_found = true;
                model_idx = model_idx + 1;
                model(model_idx) = struct('code', 'st', 'edges', 0, 'nodes1', top_gccind(curind(set1)), 'nodes2', top_gccind(curind(set1)), 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
            else
                % bipartite graph
                degrees = sum(Asmall, 2);
                % First check if it is bipartite core:
                % The degrees of the nodes in the first set should be
                % equal to the number of nodes in the second set, and vice versa.
                if sum(full(degrees(set1)) ~= length(set2) * ones(length(set1), 1)) && ...
                        sum(full(degrees(set2)) ~= length(set1) * ones(length(set2), 1)) == 0
                    MDLcost_bc = compute_encodingCost('bc', N_tot, length(set1), zeros(n, n), length(set2));
                    costGain = MDLcost_nc - MDLcost_bc;
                    costGain_notEnc = cost_notEnc - MDLcost_bc;
                    fprintf(out_fid, 'bc');
                    fprintf(out_fid, ' %d', top_gccind(curind(set1)));
                    fprintf(out_fid, ',');
                    fprintf(out_fid, ' %d', top_gccind(curind(set2)));

                    if info == false
                        fprintf(out_fid, '\n');
                    else
                        fprintf(out_fid, ', %f | %f -- exact \n', costGain, costGain_notEnc);
                    end

                    exact_found = true;
                    model_idx = model_idx + 1;
                    model(model_idx) = struct('code', 'bc', 'edges', 0, 'nodes1', top_gccind(curind(set1)), 'nodes2', top_gccind(curind(set2)), 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
                else
                    % it's not a bipartite core (full bipartite graph) -
                    % However, it is a bipartite graph. Let's see if we should
                    % encode it as a bipartite core or a near bipartite core.
                    MDLcost_bc = compute_encodingCost('bc', N_tot, length(set1), zeros(n, n), length(set2));
                    MDLcost_nb = compute_encodingCost('nb', N_tot, length(set1), zeros(n, n), length(set2));

                    if MDLcost_bc <= MDLcost_nb
                        costGain = MDLcost_nc - MDLcost_bc;
                        costGain_notEnc = cost_notEnc - MDLcost_bc;
                        fprintf(out_fid, 'bc');
                        fprintf(out_fid, ' %d', top_gccind(curind(set1)));
                        fprintf(out_fid, ',');
                        fprintf(out_fid, ' %d', top_gccind(curind(set2)));

                        if info == false
                            fprintf(out_fid, '\n');
                        else
                            fprintf(out_fid, ', %f | %f -- not exact \n', costGain, costGain_notEnc);
                        end

                        exact_found = true;
                        model_idx = model_idx + 1;
                        model(model_idx) = struct('code', 'bc', 'edges', 0, 'nodes1', top_gccind(curind(set1)), 'nodes2', top_gccind(curind(set2)), 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
                    else
                        % better to encode it as near-bipartite core
                        costGain = MDLcost_nc - MDLcost_nb;
                        costGain_notEnc = cost_notEnc - MDLcost_nb;
                        fprintf(out_fid, 'nb');
                        fprintf(out_fid, ' %d', top_gccind(curind(set1)));
                        fprintf(out_fid, ',');
                        fprintf(out_fid, ' %d', top_gccind(curind(set2)));

                        if info == false
                            fprintf(out_fid, '\n');
                        else
                            fprintf(out_fid, ', %f | %f -- not exact \n', costGain, costGain_notEnc);
                        end

                        exact_found = true;
                        model_idx = model_idx + 1;
                        model(model_idx) = struct('code', 'nb', 'edges', 0, 'nodes1', top_gccind(curind(set1)), 'nodes2', top_gccind(curind(set2)), 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
                    end

                end

            end

        end

    end

end
