% Print the encoding of given graph as a full clique
%? @param{curind}:
%? @param{top_gccind}:
% @param{costGain}: cost of encoding as a near-clique - cost of encoding as a full-clique
% @param{costGain_notEnc}: cost of encoding as a full-clique - the cost of encoding as error (not encoding)
% @param{out_fid}: output file id
% @param{info}: whether to output costGain and costGain_notEnc
%
% Output is stored in the model file in the form:
% fc nodes_in_the_clique, costGain
function [] = encodeAsFClique(curind, top_gccind, costGain, costGain_notEnc, out_fid, info)

    global model;
    global model_idx;

    %% Printing the encoded structure.
    % encode as full clique
    fprintf(out_fid, 'fc');

    for i = 1:size(curind, 2)
        fprintf(out_fid, ' %d', top_gccind(curind(i)));
    end

    if info == false
        fprintf(out_fid, '\n');
    else
        fprintf(out_fid, ', %f | %f --- full clique \n', costGain, costGain_notEnc);
    end

    model_idx = model_idx + 1;
    model(model_idx) = struct('code', 'fc', 'edges', 0, 'nodes1', top_gccind(curind), 'nodes2', [], 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
    %n = size(model, 2);
    %model(n+1) = struct('code', 'fc', 'nodes1', top_gccind(curind), 'nodes2', [], 'benefit', costGain);

end
