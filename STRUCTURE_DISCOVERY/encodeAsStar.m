% Print the encoding of the given graph as star
%? @param{curind}:
%? @param{top_gccind}:
% @param{hub}: the hub node
% @param{spokes}: spoke nodes
% @param{costGain}: always 0 in this function
% @param{costGain_notEnc}: cost of encoding as a near-clique - the cost of encoding as error (not encoding)
% @param{out_fid}: output file id
% @param{info}: whether to output costGain and costGain_notEnc
%
% Output is stored in the model file in the form:
% st hub, spokes_ids, costGain
function [] = encodeAsStar(curind, top_gccind, hub, spokes, costGain, costGain_notEnc, out_fid, info)

    global model;
    global model_idx;

    fprintf(out_fid, 'st %d,', top_gccind(curind(hub)));
    fprintf(out_fid, ' %d', top_gccind(curind(spokes)));

    if info == false
        fprintf(out_fid, '\n');
    else
        fprintf(out_fid, ', %f | %f --- nearStar \n', costGain, costGain_notEnc);
    end

    model_idx = model_idx + 1;
    model(model_idx) = struct('code', 'st', 'edges', 0, 'nodes1', top_gccind(curind(hub)), 'nodes2', top_gccind(curind(spokes)), 'benefit', costGain, 'benefit_notEnc', costGain_notEnc);
    %n = size(model, 2);
    %model(n+1) = struct('code', 'st', 'nodes1', top_gccind(curind(hub)), 'nodes2', top_gccind(curind(spokes)), 'benefit', costGain);

end
