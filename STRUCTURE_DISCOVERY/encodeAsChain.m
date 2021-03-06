% Print the encoding of the given graph as chain
%? @param{curind}:
%? @param{top_gccind}:
% @param{chain}: nodes in the chain
% @param{costGain}: cost of encoding as a near-clique - cost of encoding as a chain
% @param{costGain_notEnc}: cost of encoding as a chain - the cost of encoding as error (not encoding)
% @param{out_fid}: output file id
% @param{info}: whether to output costGain and costGain_notEnc
%
% Output is stored in the model file in the form:
% ch node_ids_in_order, costGain
function [] = encodeAsChain(curind, top_gccind, chain, costGain, costGain_notEnc, out_fid, info)

    global model;
    global model_idx;

    %% Printing the encoded structure.
    fprintf(out_fid, 'ch ');
    fprintf(out_fid, ' %d', top_gccind(curind(chain)));

    if info == false
        fprintf(out_fid, '\n');
    else
        fprintf(out_fid, ', %f  | %f --- nearChain \n', costGain, costGain_notEnc);
    end

    model_idx = model_idx + 1;
    model(model_idx) = struct('code', 'ch', 'edges', 0, 'nodes1', top_gccind(curind(chain)), 'nodes2', [], 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
    %n = size(model, 2);
    %model(n+1) = struct('code', 'ch', 'nodes1', top_gccind(curind(chain)), 'nodes2', [], 'benefit', costGain);

end
