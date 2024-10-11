function cnet = build_UCMgraph(N0, p_gamma)
%Returns a complex (ie. scale free) graph/network using the uncorrelated
%configuration model(UCM) on the unit square with lineary spaced nodes.
%
%Refs:
%see Michele Catanzaro, 2004

%-----Check for perfect square (since the graph is mapped on a lattice N*N)
if(~check_perfect_square(N0))
    warning('''n_nodes'' is not a perfect square number: sqrt(n_nodes) will be rounded.');
    n_nodes_squarred = round(sqrt(N0));
    N0 = n_nodes_squarred^2;
else
    n_nodes_squarred = sqrt(N0); %check for real square roots values
end

%-----Compute network side array 
% use sqrt(n_nodes)-1 for a spacing of '1' between node (remember the networks are 0-index based)
net_size = n_nodes_squarred-1;  %'size' of the network (1 means the unit square)

%Build X,Y layout, such that node i is at Xi, Yi:
S = linspace(0, net_size, n_nodes_squarred);

%Build nodes structure:
cnet.layout = S;
X = ndgrid(S, S);
Y = X'; 
cnet.XY = [X(:), Y(:)];
cnet.gamma = p_gamma;
cnet.degree = get_degree(p_gamma, N0);

%Wire newtork:
cnet = wire(cnet);

function cnet = wire(cnet)
% Wire the corresponding cnet using cm_net from MIT/CNM toolboxes.
% but cnet.adjm = cm_net(cnet.degree); is very slow
% Self and multiple connexions are not allowed in this configuration.
cnet.adjm = graph_from_degree_sequence(cnet.degree');

function r = get_degree(gamma, n_nodes)
% Generate degree network with probability 1,
% from the discrete power law distribution:
% (much similar to the zeta distribution)
% According to POWER-LAW DISTRIBUTIONS IN EMPIRICAL DATA (Clauset et al.)
% see: http://stats.stackexchange.com/questions/88496/accurately-generating-variates-from-discrete-power-law-distribution
% Suggest to round according to: d = floor(1/2*(1-r).^(-1/(1-alpha)) + 1/2);

a = 2; %a = m in the article
b = n_nodes-1; %maximum number of nodes is one node connected to all other nodes to the exception of itself

%1) Normalisation coefficient C:
%C_{a,b,\gamma}= \sum_{i=a}^b i^{-\gamma}:
C = sum((a:b).^-gamma);

%2) draw 'n_nodes' independant U_j ~ U[0,1] that fall into the [B1, B2[ interval:
r = zeros(n_nodes, 1);
r(1) = 1; %to make sure that sum(r) is odd at first.

while(mod(sum(r), 2) ~= 0) %to ensure an even sum.

    r = rand(n_nodes, 1);   %draw uniform random U_j

    % first, assign r = 1 to 'b' values (if any).
    r(r == 1) = b;

    for k = a:b
        %[\sum_{i=a}^{k-1} i^{-\gamma}/C_{a,b,\gamma}
        %will return 0 if k==a
        B1 = 1/C * sum((a:k-1).^-gamma);
        %\sum_{i=a}^{k} i^{-\gamma}/C_{a,b,\gamma}[
        B2 = 1/C * sum((a:k).^-gamma);
        
        %Find the ones who fall into the [B1, B2[ interval:
        %and assign k to these values:
        r(B1 <= r & r < B2) = k;
    end

end

function c = check_perfect_square(n_nodes)
%Return 1 (true) if it is a perfect square.
whole=sqrt(n_nodes);
natural=fix(whole);
diff=whole-natural;
c = diff==0;

% %This function draws degrees from the continuous power law distribution:
% function d = get_degree_continous(gamma, n_nodes)
% %Generate degree network with probability 1,
% %from the continuous bounded power law distribution:
% 
% m = 2; 
% b = sqrt(n_nodes);
% 
% n = rand(n_nodes,1);
% r =((b^(-gamma+1) - m^(-gamma+1))*n + m^(-gamma+1)).^(1/(-gamma+1));
