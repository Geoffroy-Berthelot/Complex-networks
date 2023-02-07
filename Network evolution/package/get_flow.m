function [F, M, is_warning] = get_flow(netw, is_mex)
% Returns the matrix of fluxes M and flow potentials F
% An alternative of the following code is to compute the Laplacian matrix
% using the built-in L = laplacian(G) function. However, for small networks
% (i.e. N0 < 1600), this code seems faster.
% This needs further investigations for assessing runtime differences.
% Also, handling warnings is a much faster way to proceed than computing the 
% determinant / rank of the adjacency matrix before solving P\S.

%Handle warnings:
is_warning = 0;
lastwarn('') % Clear last warning message

%Preallocs:
sized = size(netw.adjm,1);

if(is_mex)
    %Use MEX version (C) (much faster!, but only for full matrixs)
    [P, S] = prepare_sys_full(netw, sized);
else
    %use MATLAB version:
    [P,S] = prepare_linsys(netw, sized);
end

%Remove both source and drain entries from P:
P([netw.inflow, netw.outflow],:) = [];
P(:,[netw.inflow, netw.outflow]) = [];
S([netw.inflow, netw.outflow]) = [];

%Solve the linear system:
FF = P\S;

[warnMsg, ~] = lastwarn;
if ~isempty(warnMsg) %catch singular matrix exception (due to the creation of subgraphs for instance)
    is_warning = 1;
    % create null dummy structures, which contains 0's values only
    % because we cannot compute the flow anymore:
    F = zeros(netw.n_nodes,1);
    M = zeros(netw.n_nodes, netw.n_nodes);
else
    %Re-insert source and drain nodes:
    F(1:min([netw.inflow, netw.outflow])-1) = FF(1:min([netw.inflow, netw.outflow])-1);
    F(min([netw.inflow, netw.outflow])+1:max([netw.inflow, netw.outflow])-1) = FF(min([netw.inflow, netw.outflow]):max([netw.inflow, netw.outflow])-2);
    F(max([netw.inflow, netw.outflow])+1:size(netw.adjm,1)) = FF(max([netw.inflow, netw.outflow])-1:size(netw.adjm,1)-2);

    %Insert:
    if(min([netw.inflow, netw.outflow]) == netw.inflow)
        F(min([netw.inflow, netw.outflow]))=1;
        F(max([netw.inflow, netw.outflow]))=0;
    else
        F(min([netw.inflow, netw.outflow]))=0;
        F(max([netw.inflow, netw.outflow]))=1;
    end
    F = F';
    
    %Then compute the fluxes matrix M, according to F (flow potentials):
    if(is_mex)
        %Use MEX version (C) (faster! only for full matrices)
        M = compute_q_full(netw, sized, F);
    else
        %use MATLAB version:
        M = compute_q(netw, sized, F);
    end
end


function M = compute_q(netw, sized, F)
% Prealloc (warning: because 0 can possibly be a minimum value, but in
% remove_weakest_link() we actually do: min(netw.fluxes(netw.fluxes > 0)))
M = zeros(sized, sized); 

for i=1:size(netw.adjm,1)
    idx = netw.adjm(i,:) == 1;          %for each connected nodes
    D = netw.dis_eucl(i, idx);          %gather the distances
    M(i, idx) = -(F(i) - F(idx)) ./ D'; %then compute the associated flow
end

function [P, S] = prepare_linsys(netw, sized)
%prepare Linear system for solving:

%Prealloc:
P = zeros(sized, sized); %Matrix of Pi's (without source and drain entries)
S = zeros(sized, 1);  %Conservation of mass, thus outputs are 0's

%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VERSION #1
%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:size(netw.adjm,1)
    idx = netw.adjm(i,:) == 1;   %gather indexes of connected nodes.
    D = netw.dis_eucl(i, idx);   %gather corresponding euclidean distances

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Standard Node (neither a source or drain node)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Check if there is link to the source node:
    if(any(find(idx) == netw.inflow))
        D2 = D; %save D.
        S(i) = -1/D(find(idx) == netw.inflow); %alter output accordingly (we know source node Potential value = 1)
        D(find(idx) == netw.inflow) = []; %remove source node from distances
        idx(netw.inflow) = 0; %then erase coefficient from idx
        %Finally, perform standard computation
        P(i,i) = -sum(1./D2);
    else
        %Standard computation (ie. current node 'i' is not linked to the source node):
        P(i,i) = -sum(1./D);
    end
    
    %Assign coefficients values to connected nodes:
    P(i,idx) = 1./D;
end

