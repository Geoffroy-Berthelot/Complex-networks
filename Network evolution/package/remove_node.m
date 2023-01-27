function [G, removed_node, bad_news] = remove_node(G, idx, F)
%Remove node with index 'idx' from network 'G'

bad_news = 0;
if(idx == G.inflow)
    bad_news = 1; %Oops: target is the source node
end

if(idx == G.outflow)
    bad_news = 1; %Oops: target is the drain node 
end

%Additional info
removed_node.degree = G.degree(idx);
removed_node.XY = G.XY(idx);
removed_node.distance_source = F(G.adjm, idx, G.inflow);
removed_node.distance_drain = F(G.adjm, idx, G.outflow);

%Keep track of inflow and outflow nodes indexes:
if(G.inflow > idx)              %Check if idx is after the source position,
    G.inflow = G.inflow - 1;    %then update source index
end

if(G.outflow > idx)             %Check if idx is after the drain position,
    G.outflow = G.outflow - 1;  %then update drain index
end

G.XY(idx,:) = [];           %Remove node from XY table
G.Potentials(idx) = [];     %Remove nodes' potential from potential list

%Get indexes of connected nodes in 'idexs':
idexs = find(G.adjm(idx,:)); %Find connected links.

%Remove the links:
if(~isempty(idexs))
    for i=1:size(idexs,1)
        G = remove_link(G, idx, idexs(i), F);
    end
end

%Then remove from distance matrix:
G.dis_eucl(idx,:) = [];     %Remove corresponding row
G.dis_eucl(:, idx) = [];    %Remove corresponding column

%Remove node from adjacency matrix:
G.adjm(idx,:) = [];     %Remove corresponding row
G.adjm(:, idx) = [];    %Remove corresponding column

%From fluxes matrix:
G.fluxes(idx,:) = [];   %Remove corresponding row
G.fluxes(:, idx) = [];  %Remove corresponding column

%Degree table:
G.degree(idx) = [];     %Remove from degree table
