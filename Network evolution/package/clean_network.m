function [G, RN, db] = clean_network(G, F)
%returns the network without any 'single' nodes or unconnected nodes.

RN = {};
db = 0; k = 1;
while(any(G.degree == 1)) %Check for nodes with only one link remaining
    idxs = find(G.degree==1); %find indexes of nodes with degree 1.
    %for all idxs, remove corresponding nodes:
    while(~isempty(idxs))
        %while there are nodes in idxs, we continue:
        [G, RN{k}, db] = remove_node(G, idxs(end), F);  %Remove node
        k = k+1; %update removed node counter.
        if(db == 1)
            return; %we removed the source or drain node, then we throw an error.
        else
            idxs(end) = []; %remove corresponding idxs
        end
    end
end

