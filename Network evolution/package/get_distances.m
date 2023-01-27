function d = get_distances(XY, adjm, beta)
%%%%%%%%%%%%%%%%%%%%%%%%%%
% VERSION #1 
% Gather the euclidean distance for each node (more efficient than version
% #2).
% Also sets source (inflow) and sink (outflow) nodes. If distance == 0 then 
% assign random nodes, otherwise try to find the requested distance.
%%%%%%%%%%%%%%%%%%%%%%%%%

%****** COMPUTE EUCLIDEAN DISTANCES
%Pre-alloc:
d = zeros(size(adjm))*NaN; %NaN values will be used when nodes are not connected.

%Compute euclidean distances:
for i=1:size(adjm,1)
    xy=XY(i,:);
    
    %Find connected nodes (adj matrix):
    idx = find(adjm(i,:));
    S = size(idx,2); %dimension of the node.
    
    %Gather coordinates of other nodes:
    list = XY(idx,:);
    
    %Repmat according to S:
    D = repmat(xy, S, 1);
    
    %Compute euclidean distances for each link:
    d(i,idx) = sqrt((list(:,1) - D(:,1)) .* (list(:,1) - D(:,1)) + (list(:,2) - D(:,2)) .* (list(:,2) - D(:,2)));
    %NOTE: @bsxfun may be a faster solution?
end

%****** ASSIGN BETA TO DISTANCE MATRIX
% Second, use 'beta' to affect the distance:
d(~isnan(d)) = d(~isnan(d)).^beta;
% one (slower) alternative is:
% d = triu(d) + triu(d,1)';
